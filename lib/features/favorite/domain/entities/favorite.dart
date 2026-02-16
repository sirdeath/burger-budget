class Favorite {
  const Favorite({
    required this.id,
    required this.mainItemId,
    this.sideItemId,
    this.drinkItemId,
    required this.createdAt,
  });

  final int id;
  final String mainItemId;
  final String? sideItemId;
  final String? drinkItemId;
  final DateTime createdAt;
}
