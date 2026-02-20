import '../../../menu/domain/entities/menu_item.dart';
import 'favorite.dart';

class RichFavorite {
  const RichFavorite({
    required this.favorite,
    required this.mainItem,
    this.sideItem,
    this.drinkItem,
  });

  final Favorite favorite;
  final MenuItem mainItem;
  final MenuItem? sideItem;
  final MenuItem? drinkItem;

  int get id => favorite.id;
  String get mainItemId => favorite.mainItemId;
  String? get sideItemId => favorite.sideItemId;
  String? get drinkItemId => favorite.drinkItemId;
  DateTime get createdAt => favorite.createdAt;

  int get totalPrice =>
      mainItem.price +
      (sideItem?.price ?? 0) +
      (drinkItem?.price ?? 0);
}
