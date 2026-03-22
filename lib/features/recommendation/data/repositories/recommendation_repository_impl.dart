import 'dart:math';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/result.dart';
import '../../../menu/domain/entities/menu_item.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/user_preference.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../../domain/repositories/user_preference_repository.dart';
import '../datasources/recommendation_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  const RecommendationRepositoryImpl(
    this._datasource,
    this._prefRepo,
  );

  final RecommendationDatasource _datasource;
  final UserPreferenceRepository _prefRepo;

  /// 같은 메인 아이템이 최종 결과에 최대 몇 개 포함될 수 있는지
  static const _maxPerMain = 2;

  /// 최종 결과 상한
  static const _maxResults = 150;

  /// 디저트 부착 시 최소 스코어 상승폭
  static const _dessertThreshold = 0.05;

  @override
  Future<Result<List<Recommendation>>> getRecommendations({
    required int budget,
    required List<String> franchises,
    SortMode sort = SortMode.recommended,
    int personCount = 1,
    bool deliveryMode = false,
  }) async {
    try {
      final perPerson =
          personCount > 1 ? budget ~/ personCount : budget;
      final candidates = await _datasource.getCandidates(
        perPerson,
        franchises,
        deliveryMode: deliveryMode,
      );
      final pref = await _prefRepo.getUserPreference();
      final combos = _buildAllCombos(
        candidates,
        perPerson,
        deliveryMode,
        pref,
      );
      final diverse = _selectDiverse(combos);
      final sorted = _applySortMode(
        diverse,
        sort,
        perPerson,
        deliveryMode,
        pref,
      );
      return Success(sorted);
    } on Exception catch (e) {
      return Failure('추천 생성 실패', e);
    }
  }

  /// 배달 모드면 deliveryPrice, 없으면 매장가 폴백
  static int _itemPrice(MenuItem item, bool deliveryMode) =>
      deliveryMode
          ? (item.deliveryPrice ?? item.price)
          : item.price;

  /// 조합의 실효 가격
  static int _comboPrice(
    Recommendation combo,
    bool deliveryMode,
  ) =>
      deliveryMode
          ? (combo.totalDeliveryPrice ?? combo.totalPrice)
          : combo.totalPrice;

  // ── utilization: 예산 구간별 타겟 ──

  static double _targetUtilization(int budgetPerPerson) {
    if (budgetPerPerson < 8000) return 0.75;
    if (budgetPerPerson < 13000) return 0.82;
    return 0.87;
  }

  // ══════════════════════════════════════════════
  // 1단계: 조합 생성 (사이드/음료 전체 확장 + 디저트 후처리)
  // ══════════════════════════════════════════════

  List<_ScoredCombo> _buildAllCombos(
    List<MenuItem> candidates,
    int budget,
    bool deliveryMode,
    UserPreference pref,
  ) {
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
        if (_itemPrice(setItem, deliveryMode) > budget) {
          continue;
        }
        _generateCombos(
          scored,
          setItem,
          sides,
          drinks,
          desserts,
          budget,
          pref,
          deliveryMode: deliveryMode,
          skipSide: setItem.includesSide,
          skipDrink: setItem.includesDrink,
        );
      }

      for (final burger in burgers) {
        if (_itemPrice(burger, deliveryMode) > budget) {
          continue;
        }
        _generateCombos(
          scored,
          burger,
          sides,
          drinks,
          desserts,
          budget,
          pref,
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
    int budget,
    UserPreference pref, {
    bool deliveryMode = false,
    bool skipSide = false,
    bool skipDrink = false,
  }) {
    final remaining =
        budget - _itemPrice(mainItem, deliveryMode);

    // 사이드: 예산 내 전체 (상위 N개 제한 제거)
    final sideOptions = skipSide
        ? <MenuItem?>[null]
        : <MenuItem?>[
            null,
            ...sides.where(
              (s) =>
                  _itemPrice(s, deliveryMode) <= remaining,
            ),
          ];

    for (final side in sideOptions) {
      final afterSide = remaining -
          (side != null
              ? _itemPrice(side, deliveryMode)
              : 0);

      // 음료: 예산 내 전체 (상위 N개 제한 제거)
      final drinkOptions = skipDrink
          ? <MenuItem?>[null]
          : <MenuItem?>[
              null,
              ...drinks.where(
                (d) =>
                    _itemPrice(d, deliveryMode) <=
                    afterSide,
              ),
            ];

      for (final drink in drinkOptions) {
        final afterDrink = afterSide -
            (drink != null
                ? _itemPrice(drink, deliveryMode)
                : 0);

        // ── 디저트 후처리 부착 ──
        final comboBase = Recommendation(
          mainItem: mainItem,
          sideItem: side,
          drinkItem: drink,
        );
        final baseFeatures = _computeFeatures(
          comboBase,
          budget,
          deliveryMode,
          pref,
        );
        final scoreBase = _scoreFromFeatures(baseFeatures);

        // base features 재사용: dessert 필드만 변경해서 스코어 비교
        MenuItem? bestDessert;
        double bestScore = scoreBase;
        Map<String, double> bestFeatures = baseFeatures;

        for (final d in desserts) {
          if (_itemPrice(d, deliveryMode) > afterDrink) {
            continue;
          }
          final withDessertFeatures = {
            ...baseFeatures,
            'dessert': 1.0,
          };
          final s = _scoreFromFeatures(withDessertFeatures);
          if (s - scoreBase > _dessertThreshold &&
              s > bestScore) {
            bestDessert = d;
            bestScore = s;
            bestFeatures = withDessertFeatures;
          }
        }

        final finalCombo = bestDessert != null
            ? Recommendation(
                mainItem: mainItem,
                sideItem: side,
                drinkItem: drink,
                dessertItem: bestDessert,
              )
            : comboBase;

        results.add(
          _ScoredCombo(finalCombo, bestScore, bestFeatures),
        );
      }
    }
  }

  // ══════════════════════════════════════════════
  // 2단계: 통합 스코어링 (단일 함수)
  // ══════════════════════════════════════════════
  //
  // 가중치 (preferenceFit 미구현 → 비례 재분배):
  //   mealCompleteness: 0.30
  //   utilization:      0.25
  //   setBonus:         0.15
  //   signatureBonus:   0.15
  //   dessertBonus:     0.15
  //
  // preferenceFit 구현 시:
  //   meal 0.25, util 0.20, set 0.10, sig 0.10,
  //   pref 0.25, dessert 0.10

  /// feature vector 계산 (단일 함수로 통합)
  Map<String, double> _computeFeatures(
    Recommendation combo,
    int budget,
    bool deliveryMode,
    UserPreference pref,
  ) {
    final util =
        (_comboPrice(combo, deliveryMode) / budget)
            .clamp(0.0, 1.0);
    final target = _targetUtilization(budget);
    final rawUtil =
        max(0.0, 1.0 - (util - target).abs() / 0.20);
    final utilization = pow(rawUtil, 0.7).toDouble();

    final m = combo.mainItem;
    final hasSide =
        (combo.sideItem != null || m.includesSide)
            ? 1.0
            : 0.0;
    final hasDrink =
        (combo.drinkItem != null || m.includesDrink)
            ? 1.0
            : 0.0;
    final mealCompleteness =
        0.55 + hasSide * 0.25 + hasDrink * 0.20;

    double setBonus = 0;
    if (m.type == MenuType.set_) {
      if (m.includesSide && m.includesDrink) {
        setBonus = 1.0;
      } else if (m.includesSide || m.includesDrink) {
        setBonus = 0.5;
      }
    }

    return {
      'util': utilization,
      'utilPct': util,
      'meal': mealCompleteness,
      'set': setBonus,
      'sig': AppConstants.isSignatureMenu(
              m.franchise, m.name)
          ? 1.0
          : 0.0,
      'pref': _calcPreferenceFit(combo, pref),
      'dessert': combo.dessertItem != null ? 1.0 : 0.0,
    };
  }

  static double _scoreFromFeatures(
    Map<String, double> f,
  ) =>
      f['meal']! * 0.25 +
      f['util']! * 0.20 +
      f['set']! * 0.10 +
      f['sig']! * 0.10 +
      f['pref']! * 0.25 +
      f['dessert']! * 0.10;

  // ── preferenceFit 계산 ──

  static double _calcPreferenceFit(
    Recommendation combo,
    UserPreference pref,
  ) {
    if (pref.isEmpty) return 0;

    double raw = 0;
    final mainId = combo.mainItem.id;

    // 누적 가산 (즐겨찾기 + 최근성 중복 허용, clamp로 상한)
    if (pref.favoriteItemIds.contains(mainId)) {
      raw += 0.35;
    }
    if (pref.recent30dItemIds.contains(mainId)) {
      raw += 0.25;
    } else if (pref.recent90dItemIds.contains(mainId)) {
      raw += 0.10;
    }

    // 사이드/음료 즐겨찾기: +0.15
    final sideId = combo.sideItem?.id;
    final drinkId = combo.drinkItem?.id;
    if (sideId != null &&
        pref.favoriteItemIds.contains(sideId)) {
      raw += 0.075;
    }
    if (drinkId != null &&
        pref.favoriteItemIds.contains(drinkId)) {
      raw += 0.075;
    }

    // 프랜차이즈 최다 주문: +0.15
    final topFranchise = pref.topFranchise;
    if (topFranchise != null &&
        combo.mainItem.franchise == topFranchise) {
      raw += 0.15;
    }

    return raw.clamp(0.0, 1.0);
  }

  // ── exploration: 취향 수렴 방지 ──
  // 위치 3, 6에 exploration 아이템 끼워넣기

  static void _applyExploration(
    List<Recommendation> sorted,
    UserPreference pref,
  ) {
    // preferenceFit이 낮지만 전체 스코어는 괜찮은 후보 수집
    // (인덱스가 아닌 객체 참조로 안전하게 처리)
    final exploreCandidates = <Recommendation>[];
    for (var i = 2; i < sorted.length; i++) {
      final p = sorted[i].scoreBreakdown['pref'] ?? 0;
      final meal = sorted[i].scoreBreakdown['meal'] ?? 0;
      if (p < 0.15 && meal >= 0.55) {
        exploreCandidates.add(sorted[i]);
      }
    }

    if (exploreCandidates.isEmpty) return;

    // 위치 2(3번째), 5(6번째)에 exploration 삽입
    const insertPositions = [2, 5];
    var inserted = 0;
    for (final pos in insertPositions) {
      if (inserted >= exploreCandidates.length) break;
      final candidate = exploreCandidates[inserted];
      final currentIdx = sorted.indexOf(candidate);
      if (currentIdx == -1 || currentIdx <= pos) continue;

      sorted.removeAt(currentIdx);
      sorted.insert(pos, candidate);
      inserted++;
    }
  }

  // ══════════════════════════════════════════════
  // 3단계: 다양성 보장 (라운드로빈)
  // ══════════════════════════════════════════════

  List<Recommendation> _selectDiverse(
    List<_ScoredCombo> scored,
  ) {
    if (scored.isEmpty) return [];

    scored.sort((a, b) => b.score.compareTo(a.score));

    final seen = <String>{};
    final queues = <String, List<_ScoredCombo>>{};
    for (final entry in scored) {
      final key = _comboKey(entry.combo);
      if (!seen.add(key)) continue;
      queues
          .putIfAbsent(
            entry.combo.mainItem.franchise,
            () => [],
          )
          .add(entry);
    }

    final result = <Recommendation>[];
    final mainCounts = <String, int>{};
    final indices = <String, int>{
      for (final k in queues.keys) k: 0,
    };

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

          // scoreBreakdown 주입 (diversity 단계에서)
          result.add(Recommendation(
            mainItem: entry.combo.mainItem,
            sideItem: entry.combo.sideItem,
            drinkItem: entry.combo.drinkItem,
            dessertItem: entry.combo.dessertItem,
            scoreBreakdown: entry.features,
          ));
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

  // ══════════════════════════════════════════════
  // 4단계: 정렬 모드 적용 (통합 스코어 사용)
  // ══════════════════════════════════════════════

  List<Recommendation> _applySortMode(
    List<Recommendation> recommendations,
    SortMode sort,
    int budget,
    bool deliveryMode,
    UserPreference pref,
  ) {
    final sorted =
        List<Recommendation>.from(recommendations);
    switch (sort) {
      case SortMode.recommended:
        // scoreBreakdown은 diversity 단계에서 이미 주입됨
        // 캐싱된 스코어로 정렬 (재계산 없음)
        sorted.sort((a, b) {
          final aScore =
              _scoreFromFeatures(a.scoreBreakdown);
          final bScore =
              _scoreFromFeatures(b.scoreBreakdown);
          final cmp = bScore.compareTo(aScore);
          if (cmp != 0) return cmp;
          // 동점 tie-breaker: 예산 타겟에 더 가까운 것
          final target = _targetUtilization(budget);
          final aUtil =
              a.scoreBreakdown['utilPct'] ?? 0.0;
          final bUtil =
              b.scoreBreakdown['utilPct'] ?? 0.0;
          return (aUtil - target)
              .abs()
              .compareTo((bUtil - target).abs());
        });
        // exploration 슬롯 (80/20 혼합)
        if (!pref.isEmpty && sorted.length >= 6) {
          _applyExploration(sorted, pref);
        }
      case SortMode.saving:
        sorted.sort((a, b) {
          return _comboPrice(a, deliveryMode)
              .compareTo(_comboPrice(b, deliveryMode));
        });
      case SortMode.lowestCalories:
        sorted.sort((a, b) {
          final aCal = a.totalCalories;
          final bCal = b.totalCalories;
          if (aCal != null && bCal != null) {
            final cmp = aCal.compareTo(bCal);
            if (cmp != 0) return cmp;
          }
          if (aCal != null && bCal == null) return -1;
          if (aCal == null && bCal != null) return 1;
          return _comboPrice(a, deliveryMode)
              .compareTo(_comboPrice(b, deliveryMode));
        });
    }
    return sorted;
  }
}

/// 점수가 매겨진 추천 조합 (내부 정렬용)
class _ScoredCombo {
  const _ScoredCombo(this.combo, this.score, this.features);

  final Recommendation combo;
  final double score;
  final Map<String, double> features;
}
