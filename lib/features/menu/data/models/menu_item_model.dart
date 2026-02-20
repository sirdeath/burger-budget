import '../../domain/entities/menu_item.dart';

class MenuItemModel extends MenuItem {
  const MenuItemModel({
    required super.id,
    required super.franchise,
    required super.name,
    required super.type,
    required super.price,
    super.calories,
    super.imageUrl,
    super.tags,
    super.includesSide,
    super.includesDrink,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    final rawTags = map['tags'] as String?;
    final tags = (rawTags != null && rawTags.isNotEmpty)
        ? rawTags.split(',').map((e) => e.trim()).toList()
        : <String>[];

    return MenuItemModel(
      id: map['id'] as String,
      franchise: map['franchise'] as String,
      name: map['name'] as String,
      type: MenuType.fromString(map['type'] as String),
      price: map['price'] as int,
      calories: map['calories'] as int?,
      imageUrl: map['imageUrl'] as String?,
      tags: tags,
      includesSide: (map['includes_side'] as int?) == 1,
      includesDrink: (map['includes_drink'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'franchise': franchise,
      'name': name,
      'type': type.toValue(),
      'price': price,
      'calories': calories,
      'imageUrl': imageUrl,
      'tags': tags.join(','),
      'includes_side': includesSide ? 1 : 0,
      'includes_drink': includesDrink ? 1 : 0,
    };
  }

  factory MenuItemModel.fromEntity(MenuItem entity) {
    return MenuItemModel(
      id: entity.id,
      franchise: entity.franchise,
      name: entity.name,
      type: entity.type,
      price: entity.price,
      calories: entity.calories,
      imageUrl: entity.imageUrl,
      tags: entity.tags,
      includesSide: entity.includesSide,
      includesDrink: entity.includesDrink,
    );
  }
}
