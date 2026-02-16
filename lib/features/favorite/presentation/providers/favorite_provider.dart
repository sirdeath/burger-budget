import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/favorite.dart';

part 'favorite_provider.g.dart';

@riverpod
class FavoriteList extends _$FavoriteList {
  @override
  Future<List<Favorite>> build() async {
    final repo = ref.watch(favoriteRepositoryProvider);
    final result = await repo.getFavorites();
    return switch (result) {
      Success(data: final items) => items,
      Failure(message: final msg) => throw Exception(msg),
    };
  }

  Future<void> toggle({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
  }) async {
    final repo = ref.read(favoriteRepositoryProvider);
    final checkResult = await repo.isFavorite(
      mainItemId: mainItemId,
      sideItemId: sideItemId,
      drinkItemId: drinkItemId,
    );
    if (checkResult is Success<bool> && checkResult.data) {
      // Find the favorite to get its id for removal
      final listResult = await repo.getFavorites();
      if (listResult is Success<List<Favorite>>) {
        final fav = listResult.data
            .where(
              (f) =>
                  f.mainItemId == mainItemId &&
                  f.sideItemId == sideItemId &&
                  f.drinkItemId == drinkItemId,
            )
            .firstOrNull;
        if (fav != null) {
          await repo.removeFavorite(fav.id);
        }
      }
    } else {
      await repo.addFavorite(
        mainItemId: mainItemId,
        sideItemId: sideItemId,
        drinkItemId: drinkItemId,
      );
    }
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    final repo = ref.read(favoriteRepositoryProvider);
    await repo.removeFavorite(id);
    ref.invalidateSelf();
  }
}

@riverpod
Future<bool> isFavorite(
  Ref ref, {
  required String mainItemId,
  String? sideItemId,
  String? drinkItemId,
}) async {
  // Depend on favoriteList to auto-refresh when favorites change
  ref.watch(favoriteListProvider);
  final repo = ref.watch(favoriteRepositoryProvider);
  final result = await repo.isFavorite(
    mainItemId: mainItemId,
    sideItemId: sideItemId,
    drinkItemId: drinkItemId,
  );
  return switch (result) {
    Success(data: final isFav) => isFav,
    Failure() => false,
  };
}
