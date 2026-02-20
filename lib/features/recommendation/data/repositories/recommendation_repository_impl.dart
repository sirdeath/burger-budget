import '../../../../core/constants/app_constants.dart';
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

  @override
  Future<Result<List<Recommendation>>> getRecommendations({
    required int budget,
    required List<String> franchises,
    SortMode sort = SortMode.bestValue,
    int personCount = 1,
  }) async {
    try {
      final perPersonBudget =
          personCount > 1 ? budget ~/ personCount : budget;
      final candidates = await _datasource.getCandidates(
        perPersonBudget,
        franchises,
      );
      final combos =
          _buildAllCombos(candidates, perPersonBudget);
      final diverse = _selectDiverse(combos);
      final sorted = _applySortMode(diverse, sort);
      return Success(sorted);
    } on Exception catch (e) {
      return Failure('추천 생성 실패', e);
    }
  }

  // ── 1단계: 모든 가능한 조합 생성 + 점수 산정 ──

  List<_ScoredCombo> _buildAllCombos(
    List<MenuItem> candidates,
    int budget,
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
        if (setItem.price > budget) continue;
        _generateCombos(
          scored,
          setItem,
          sides,
          drinks,
          desserts,
          budget,
          skipSide: setItem.includesSide,
          skipDrink: setItem.includesDrink,
        );
      }

      for (final burger in burgers) {
        if (burger.price > budget) continue;
        _generateCombos(
          scored,
          burger,
          sides,
          drinks,
          desserts,
          budget,
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
    bool skipSide = false,
    bool skipDrink = false,
  }) {
    final remaining = budget - mainItem.price;

    // 사이드 후보: null(미선택) + 가격 내 상위 N개
    final sideOptions = skipSide
        ? <MenuItem?>[null]
        : <MenuItem?>[
            null,
            ...sides
                .where((s) => s.price <= remaining)
                .take(_maxSideOptions),
          ];

    for (final side in sideOptions) {
      final afterSide = remaining - (side?.price ?? 0);

      // 음료 후보: null(미선택) + 남은 예산 내 상위 N개
      final drinkOptions = skipDrink
          ? <MenuItem?>[null]
          : <MenuItem?>[
              null,
              ...drinks
                  .where((d) => d.price <= afterSide)
                  .take(_maxDrinkOptions),
            ];

      for (final drink in drinkOptions) {
        final afterDrink = afterSide - (drink?.price ?? 0);

        // 디저트: 남은 예산 내 가장 비싼 하나
        MenuItem? dessert;
        for (final d in desserts) {
          if (d.price <= afterDrink) {
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

        final score = _scoreCombo(combo, budget);
        results.add(_ScoredCombo(combo, score));
      }
    }
  }

  // ── 2단계: 점수 산정 ──
  //
  // 가성비 앱의 핵심: 예산을 알뜰하게 쓰면서 균형잡힌 한끼를 추천
  // - 예산 활용도 (55%): 예산 대비 총 가격 비율이 높을수록 좋음
  // - 구성 완성도 (30%): 메인+사이드+음료+디저트 4가지 중 몇 개인지
  // - 잔액 페널티 (15%): 예산의 30% 이상 남으면 감점

  double _scoreCombo(Recommendation combo, int budget) {
    if (budget <= 0) return 0;

    final utilization = combo.totalPrice / budget;
    final componentCount = 1 +
        (combo.sideItem != null ? 1 : 0) +
        (combo.drinkItem != null ? 1 : 0) +
        (combo.dessertItem != null ? 1 : 0);
    final completeness = componentCount / 4.0;

    final leftover = 1.0 - utilization;
    final leftoverPenalty = leftover > 0.3 ? (leftover - 0.3) : 0.0;

    return utilization * 0.55 +
        completeness * 0.30 -
        leftoverPenalty * 0.15;
  }

  // ── 3단계: 다양성 보장 선택 ──
  //
  // 점수 높은 순으로 선택하되:
  // - 동일 메인 아이템 최대 2개
  // - 동일 조합(메인+사이드+음료+디저트) 중복 제거
  // - 프랜차이즈가 여러 개면 분산 선택

  List<Recommendation> _selectDiverse(
    List<_ScoredCombo> scored,
  ) {
    if (scored.isEmpty) return [];

    // 점수 높은 순 정렬
    scored.sort((a, b) => b.score.compareTo(a.score));

    final limit = AppConstants.maxRecommendations;
    final result = <Recommendation>[];
    final mainCounts = <String, int>{};
    final seen = <String>{};

    // 1차: 다양성 제약 적용하며 선택
    for (final entry in scored) {
      if (result.length >= limit) break;

      final combo = entry.combo;
      final key = _comboKey(combo);
      if (!seen.add(key)) continue;

      final mainId = combo.mainItem.id;
      final count = mainCounts[mainId] ?? 0;
      if (count >= _maxPerMain) continue;

      result.add(combo);
      mainCounts[mainId] = count + 1;
    }

    // 2차: 아직 자리가 남으면 제약 완화하여 채움
    if (result.length < limit) {
      for (final entry in scored) {
        if (result.length >= limit) break;

        final key = _comboKey(entry.combo);
        if (seen.contains(key)) continue;
        seen.add(key);
        result.add(entry.combo);
      }
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
  ) {
    final sorted = List<Recommendation>.from(recommendations);
    switch (sort) {
      case SortMode.bestValue:
        sorted.sort(
          (a, b) => b.totalPrice.compareTo(a.totalPrice),
        );
      case SortMode.lowestCalories:
        sorted.sort((a, b) {
          final aCal = a.totalCalories ?? 0x7FFFFFFF;
          final bCal = b.totalCalories ?? 0x7FFFFFFF;
          return aCal.compareTo(bCal);
        });
    }
    return sorted
        .take(AppConstants.maxRecommendations)
        .toList();
  }
}

/// 점수가 매겨진 추천 조합 (내부 정렬용)
class _ScoredCombo {
  const _ScoredCombo(this.combo, this.score);

  final Recommendation combo;
  final double score;
}
