import '../../domain/entities/order_history.dart';

class OrderHistoryModel extends OrderHistory {
  const OrderHistoryModel({
    required super.id,
    required super.mainItemId,
    super.sideItemId,
    super.drinkItemId,
    required super.totalPrice,
    required super.createdAt,
  });

  factory OrderHistoryModel.fromMap(Map<String, dynamic> map) {
    return OrderHistoryModel(
      id: map['id'] as int,
      mainItemId: map['main_item_id'] as String,
      sideItemId: map['side_item_id'] as String?,
      drinkItemId: map['drink_item_id'] as String?,
      totalPrice: map['total_price'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'main_item_id': mainItemId,
      'side_item_id': sideItemId,
      'drink_item_id': drinkItemId,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory OrderHistoryModel.fromEntity(OrderHistory entity) {
    return OrderHistoryModel(
      id: entity.id,
      mainItemId: entity.mainItemId,
      sideItemId: entity.sideItemId,
      drinkItemId: entity.drinkItemId,
      totalPrice: entity.totalPrice,
      createdAt: entity.createdAt,
    );
  }
}
