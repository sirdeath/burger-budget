import '../../domain/entities/favorite.dart';

class FavoriteModel extends Favorite {
  const FavoriteModel({
    required super.id,
    required super.mainItemId,
    super.sideItemId,
    super.drinkItemId,
    required super.createdAt,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id'] as int,
      mainItemId: map['main_item_id'] as String,
      sideItemId: map['side_item_id'] as String?,
      drinkItemId: map['drink_item_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'main_item_id': mainItemId,
      'side_item_id': sideItemId,
      'drink_item_id': drinkItemId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FavoriteModel.fromEntity(Favorite entity) {
    return FavoriteModel(
      id: entity.id,
      mainItemId: entity.mainItemId,
      sideItemId: entity.sideItemId,
      drinkItemId: entity.drinkItemId,
      createdAt: entity.createdAt,
    );
  }
}
