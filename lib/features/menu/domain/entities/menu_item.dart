enum MenuType {
  burger,
  side,
  drink,
  set_;

  static MenuType fromString(String value) {
    return switch (value) {
      'burger' => MenuType.burger,
      'side' => MenuType.side,
      'drink' => MenuType.drink,
      'set' => MenuType.set_,
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
    this.calories,
    this.imageUrl,
    this.tags = const [],
  });

  final String id;
  final String franchise;
  final String name;
  final MenuType type;
  final int price;
  final int? calories;
  final String? imageUrl;
  final List<String> tags;
}
