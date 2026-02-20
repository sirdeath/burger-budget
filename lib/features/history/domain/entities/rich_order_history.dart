import '../../../menu/domain/entities/menu_item.dart';
import 'order_history.dart';

class RichOrderHistory {
  const RichOrderHistory({
    required this.history,
    required this.mainItem,
    this.sideItem,
    this.drinkItem,
  });

  final OrderHistory history;
  final MenuItem mainItem;
  final MenuItem? sideItem;
  final MenuItem? drinkItem;

  int get id => history.id;
  int get totalPrice => history.totalPrice;
  DateTime get createdAt => history.createdAt;
}
