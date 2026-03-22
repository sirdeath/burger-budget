import '../../../menu/domain/entities/menu_item.dart';

enum SortMode { recommended, saving, lowestCalories }

class Recommendation {
  const Recommendation({
    required this.mainItem,
    this.sideItem,
    this.drinkItem,
    this.dessertItem,
    this.scoreBreakdown = const {},
  });

  final MenuItem mainItem;
  final MenuItem? sideItem;
  final MenuItem? drinkItem;
  final MenuItem? dessertItem;

  /// 스코어 분해 (추천 이유 생성용)
  final Map<String, double> scoreBreakdown;

  bool get isSet => mainItem.type == MenuType.set_;

  /// 사용자에게 보여줄 추천 이유 (상위 1~2개)
  List<String> get explanations {
    if (scoreBreakdown.isEmpty) return [];
    final reasons = <String>[];

    final pref = scoreBreakdown['pref'] ?? 0;
    final meal = scoreBreakdown['meal'] ?? 0;
    final util = scoreBreakdown['util'] ?? 0;
    final utilPct = scoreBreakdown['utilPct'] ?? 0;
    final set_ = scoreBreakdown['set'] ?? 0;
    final sig = scoreBreakdown['sig'] ?? 0;

    if (pref > 0.25) {
      reasons.add('즐겨찾기 메뉴가 포함돼 있어요');
    } else if (pref > 0.10) {
      reasons.add('자주 고른 브랜드를 반영했어요');
    }

    if (meal >= 1.0) {
      reasons.add('메인 + 사이드 + 음료가 갖춰진 조합이에요');
    }

    if (util > 0.8 && utilPct > 0) {
      final pct = (utilPct * 100).round();
      reasons.add('예산의 $pct%를 효율적으로 사용했어요');
    }

    if (set_ > 0) {
      reasons.add('세트 메뉴 — 개별 주문보다 가성비 좋아요');
    }

    if (sig > 0 && reasons.length < 2) {
      reasons.add('인기 시그니처 메뉴에요');
    }

    return reasons.take(2).toList();
  }

  int get totalPrice =>
      mainItem.price +
      (sideItem?.price ?? 0) +
      (drinkItem?.price ?? 0) +
      (dessertItem?.price ?? 0);

  int? get totalCalories {
    if (mainItem.calories == null) return null;
    return mainItem.calories! +
        (sideItem?.calories ?? 0) +
        (drinkItem?.calories ?? 0) +
        (dessertItem?.calories ?? 0);
  }

  /// 조합 전체의 배달 총가격. 메인의 배달가가 없으면 null.
  int? get totalDeliveryPrice {
    final mainDel = mainItem.deliveryPrice;
    if (mainDel == null) return null;
    return mainDel +
        (sideItem?.deliveryPrice ?? sideItem?.price ?? 0) +
        (drinkItem?.deliveryPrice ?? drinkItem?.price ?? 0) +
        (dessertItem?.deliveryPrice ?? dessertItem?.price ?? 0);
  }

  /// 배달시 추가 비용 (매장가 대비). 배달가 없으면 null.
  int? get totalPriceDiff {
    final del = totalDeliveryPrice;
    if (del == null) return null;
    return del - totalPrice;
  }
}
