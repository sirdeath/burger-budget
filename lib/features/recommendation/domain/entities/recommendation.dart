import '../../../menu/domain/entities/menu_item.dart';

enum SortMode { bestValue, lowestCalories }

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
}
