class OrderHistory {
  const OrderHistory({
    required this.id,
    required this.mainItemId,
    this.sideItemId,
    this.drinkItemId,
    required this.totalPrice,
    required this.createdAt,
  });

  final int id;
  final String mainItemId;
  final String? sideItemId;
  final String? drinkItemId;
  final int totalPrice;
  final DateTime createdAt;
}
