import '../../../menu/domain/entities/menu_item.dart';

enum SortMode { recommended, saving, lowestCalories }

class Recommendation {
  const Recommendation({
    required this.mainItem,
    this.sideItem,
    this.drinkItem,
    this.dessertItem,
  });

  final MenuItem mainItem;
  final MenuItem? sideItem;
  final MenuItem? drinkItem;
  final MenuItem? dessertItem;

  bool get isSet => mainItem.type == MenuType.set_;

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
