import '../../../../core/errors/result.dart';
import '../entities/favorite.dart';

abstract class FavoriteRepository {
  Future<Result<List<Favorite>>> getFavorites();

  Future<Result<Favorite>> addFavorite({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
  });

  Future<Result<void>> removeFavorite(int id);

  Future<Result<bool>> isFavorite({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
  });
}
