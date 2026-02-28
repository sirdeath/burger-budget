enum MenuType {
  burger,
  side,
  drink,
  set_,
  dessert;

  static MenuType fromString(String value) {
    return switch (value) {
      'burger' => MenuType.burger,
      'side' => MenuType.side,
      'drink' => MenuType.drink,
      'set' => MenuType.set_,
      'dessert' => MenuType.dessert,
      _ => throw ArgumentError('Unknown MenuType: $value'),
    };
  }

  String toValue() {
    return switch (this) {
      MenuType.set_ => 'set',
      _ => name,
    };
  }
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.franchise,
    required this.name,
    required this.type,
    required this.price,
    this.deliveryPrice,
    this.priceUpdatedAt,
    this.calories,
    this.imageUrl,
    this.tags = const [],
    this.includesSide = false,
    this.includesDrink = false,
  });

  final String id;
  final String franchise;
  final String name;
  final MenuType type;
  final int price;
  final int? deliveryPrice;
  final String? priceUpdatedAt;
  final int? calories;
  final String? imageUrl;
  final List<String> tags;
  final bool includesSide;
  final bool includesDrink;

  /// 배달가와 매장가의 차액. 배달가가 없으면 null.
  int? get priceDiff =>
      deliveryPrice != null ? deliveryPrice! - price : null;
}
