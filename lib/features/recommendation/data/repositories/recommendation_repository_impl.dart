import '../../../../core/errors/result.dart';
import '../../../menu/domain/entities/menu_item.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  const RecommendationRepositoryImpl(this._datasource);

  final RecommendationDatasource _datasource;

  /// 메인당 생성할 최대 사이드/음료 조합 후보 수
  static const _maxSideOptions = 3;
  static const _maxDrinkOptions = 3;

  /// 같은 메인 아이템이 최종 결과에 최대 몇 개 포함될 수 있는지
  static const _maxPerMain = 2;

  /// 최종 결과 상한 (세트/단품 필터링 시에도 충분한 결과 보장)
  static const _maxResults = 150;

  @override
  Future<Result<List<Recommendation>>> getRecommendations({
    required int budget,
    required List<String> franchises,
    SortMode sort = SortMode.recommended,
    int personCount = 1,
    bool deliveryMode = false,
  }) async {
    try {
      final perPersonBudget =
          personCount > 1 ? budget ~/ personCount : budget;
      final candidates = await _datasource.getCandidates(
        perPersonBudget,
        franchises,
        deliveryMode: deliveryMode,
      );
      final combos =
          _buildAllCombos(candidates, perPersonBudget, deliveryMode);
      final diverse = _selectDiverse(combos);
      final sorted = _applySortMode(
        diverse,
        sort,
        perPersonBudget,
        deliveryMode,
      );
      return Success(sorted);
    } on Exception catch (e) {
      return Failure('추천 생성 실패', e);
    }
  }

  /// 배달 모드면 deliveryPrice, 없으면 매장가 폴백
  static int _itemPrice(MenuItem item, bool deliveryMode) =>
      deliveryMode ? (item.deliveryPrice ?? item.price) : item.price;

  // ── 1단계: 모든 가능한 조합 생성 + 점수 산정 ──

  List<_ScoredCombo> _buildAllCombos(
    List<MenuItem> candidates,
    int budget,
    bool deliveryMode,
  ) {
    // 프랜차이즈별 그룹핑 → 같은 가게 메뉴끼리만 조합
    final byFranchise = <String, List<MenuItem>>{};
    for (final item in candidates) {
      byFranchise
          .putIfAbsent(item.franchise, () => [])
          .add(item);
    }

    final scored = <_ScoredCombo>[];

    for (final items in byFranchise.values) {
      final sets = items
          .where((i) => i.type == MenuType.set_)
          .toList();
      final burgers = items
          .where((i) => i.type == MenuType.burger)
          .toList();
      final sides = items
          .where((i) => i.type == MenuType.side)
          .toList();
      final drinks = items
          .where((i) => i.type == MenuType.drink)
          .toList();
      final desserts = items
          .where((i) => i.type == MenuType.dessert)
          .toList();

      for (final setItem in sets) {
        if (_itemPrice(setItem, deliveryMode) > budget) continue;
        _generateCombos(
          scored,
          setItem,
          sides,
          drinks,
          desserts,
          budget,
          deliveryMode: deliveryMode,
          skipSide: setItem.includesSide,
          skipDrink: setItem.includesDrink,
        );
      }

      for (final burger in burgers) {
        if (_itemPrice(burger, deliveryMode) > budget) continue;
        _generateCombos(
          scored,
          burger,
          sides,
          drinks,
          desserts,
          budget,
          deliveryMode: deliveryMode,
        );
      }
    }

    return scored;
  }

  void _generateCombos(
    List<_ScoredCombo> results,
    MenuItem mainItem,
    List<MenuItem> sides,
    List<MenuItem> drinks,
    List<MenuItem> desserts,
    int budget, {
    bool deliveryMode = false,
    bool skipSide = false,
    bool skipDrink = false,
  }) {
    final remaining =
        budget - _itemPrice(mainItem, deliveryMode);

    // 사이드 후보: null(미선택) + 가격 내 상위 N개
    final sideOptions = skipSide
        ? <MenuItem?>[null]
        : <MenuItem?>[
            null,
            ...sides
                .where(
                  (s) => _itemPrice(s, deliveryMode) <= remaining,
                )
                .take(_maxSideOptions),
          ];

    for (final side in sideOptions) {
      final afterSide =
          remaining - (side != null ? _itemPrice(side, deliveryMode) : 0);

      // 음료 후보: null(미선택) + 남은 예산 내 상위 N개
      final drinkOptions = skipDrink
          ? <MenuItem?>[null]
          : <MenuItem?>[
              null,
              ...drinks
                  .where(
                    (d) =>
                        _itemPrice(d, deliveryMode) <= afterSide,
                  )
                  .take(_maxDrinkOptions),
            ];

      for (final drink in drinkOptions) {
        final afterDrink = afterSide -
            (drink != null ? _itemPrice(drink, deliveryMode) : 0);

        // 디저트: 남은 예산 내 가장 비싼 하나
        MenuItem? dessert;
        for (final d in desserts) {
          if (_itemPrice(d, deliveryMode) <= afterDrink) {
            dessert = d;
            break;
          }
        }

        // 메인만 있는 조합은 사이드/음료가 있을 때보다 우선도 낮음
        // → null+null 조합도 생성하되 점수로 후순위 처리
        final combo = Recommendation(
          mainItem: mainItem,
          sideItem: side,
          drinkItem: drink,
          dessertItem: dessert,
        );

        final score =
            _scoreCombo(combo, budget, deliveryMode);
        results.add(_ScoredCombo(combo, score));
      }
    }
  }

  // ── 2단계: 점수 산정 ──
  //
  // 예산 활용도 (55%): 예산 대비 총 가격 비율
  // 구성 완성도 (30%): 메인+사이드+음료+디저트 (세트 포함분 인정)
  // 잔액 페널티 (15%): 예산의 30% 이상 남으면 감점

  /// 조합의 실효 가격 (배달 모드면 배달가, 아니면 매장가)
  static int _comboPrice(
    Recommendation combo,
    bool deliveryMode,
  ) =>
      deliveryMode
          ? (combo.totalDeliveryPrice ?? combo.totalPrice)
          : combo.totalPrice;

  double _scoreCombo(
    Recommendation combo,
    int budget,
    bool deliveryMode,
  ) {
    if (budget <= 0) return 0;

    final utilization =
        _comboPrice(combo, deliveryMode) / budget;
    final main = combo.mainItem;
    final componentCount = 1 +
        (combo.sideItem != null || main.includesSide ? 1 : 0) +
        (combo.drinkItem != null || main.includesDrink ? 1 : 0) +
        (combo.dessertItem != null ? 1 : 0);
    final completeness = componentCount / 4.0;

    final leftover = 1.0 - utilization;
    final leftoverPenalty = leftover > 0.3 ? (leftover - 0.3) : 0.0;

    return utilization * 0.55 +
        completeness * 0.30 -
        leftoverPenalty * 0.15;
  }

  // ── 3단계: 다양성 보장 선택 (프랜차이즈 라운드로빈) ──
  //
  // - 프랜차이즈별 그룹 → 점수순 정렬
  // - 라운드로빈으로 각 프랜차이즈에서 1개씩 번갈아 선택
  // - 동일 메인 아이템 최대 _maxPerMain개
  // - 동일 조합 중복 제거

  List<Recommendation> _selectDiverse(
    List<_ScoredCombo> scored,
  ) {
    if (scored.isEmpty) return [];

    scored.sort((a, b) => b.score.compareTo(a.score));

    // 프랜차이즈별 큐 (중복 조합 제거)
    final seen = <String>{};
    final queues = <String, List<_ScoredCombo>>{};
    for (final entry in scored) {
      final key = _comboKey(entry.combo);
      if (!seen.add(key)) continue;
      queues
          .putIfAbsent(entry.combo.mainItem.franchise, () => [])
          .add(entry);
    }

    final result = <Recommendation>[];
    final mainCounts = <String, int>{};
    final indices = <String, int>{
      for (final k in queues.keys) k: 0,
    };

    // 라운드로빈: 각 프랜차이즈에서 순서대로 1개씩
    while (result.length < _maxResults) {
      var added = false;
      for (final franchise in queues.keys) {
        if (result.length >= _maxResults) break;
        final queue = queues[franchise]!;
        var idx = indices[franchise]!;

        while (idx < queue.length) {
          final entry = queue[idx];
          idx++;

          final mainId = entry.combo.mainItem.id;
          final count = mainCounts[mainId] ?? 0;
          if (count >= _maxPerMain) continue;

          result.add(entry.combo);
          mainCounts[mainId] = count + 1;
          added = true;
          break;
        }
        indices[franchise] = idx;
      }
      if (!added) break;
    }

    return result;
  }

  String _comboKey(Recommendation combo) =>
      '${combo.mainItem.id}'
      ':${combo.sideItem?.id ?? ''}'
      ':${combo.drinkItem?.id ?? ''}'
      ':${combo.dessertItem?.id ?? ''}';

  // ── 4단계: 사용자 선택 정렬 모드 적용 ──

  List<Recommendation> _applySortMode(
    List<Recommendation> recommendations,
    SortMode sort,
    int budget,
    bool deliveryMode,
  ) {
    final sorted = List<Recommendation>.from(recommendations);
    switch (sort) {
      case SortMode.recommended:
        sorted.sort((a, b) {
          final aScore =
              _recommendedScore(a, budget, deliveryMode);
          final bScore =
              _recommendedScore(b, budget, deliveryMode);
          return bScore.compareTo(aScore);
        });
      case SortMode.saving:
        sorted.sort((a, b) {
          final aComp = _componentCount(a);
          final bComp = _componentCount(b);
          if (aComp != bComp) return bComp.compareTo(aComp);
          return _comboPrice(a, deliveryMode)
              .compareTo(_comboPrice(b, deliveryMode));
        });
      case SortMode.lowestCalories:
        sorted.sort((a, b) {
          final aCal = a.totalCalories ?? 0x7FFFFFFF;
          final bCal = b.totalCalories ?? 0x7FFFFFFF;
          return aCal.compareTo(bCal);
        });
    }
    return sorted;
  }

  /// 추천 순 점수:
  /// 예산 활용도(45%) + 세트 보너스(20%) + 시그니쳐(20%) + 구성(15%)
  double _recommendedScore(
    Recommendation r,
    int budget,
    bool deliveryMode,
  ) {
    if (budget <= 0) return 0;
    final utilization =
        (_comboPrice(r, deliveryMode) / budget).clamp(0.0, 1.0);
    final setBonus = r.isSet ? 1.0 : 0.0;
    final isSignature =
        r.mainItem.tags.contains('시그니처') ? 1.0 : 0.0;
    final completeness = _componentCount(r) / 4.0;
    return utilization * 0.45 +
        setBonus * 0.20 +
        isSignature * 0.20 +
        completeness * 0.15;
  }

  int _componentCount(Recommendation r) {
    final m = r.mainItem;
    return 1 +
        (r.sideItem != null || m.includesSide ? 1 : 0) +
        (r.drinkItem != null || m.includesDrink ? 1 : 0) +
        (r.dessertItem != null ? 1 : 0);
  }
}

/// 점수가 매겨진 추천 조합 (내부 정렬용)
class _ScoredCombo {
  const _ScoredCombo(this.combo, this.score);

  final Recommendation combo;
  final double score;
}
