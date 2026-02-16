import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_local_datasource.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  const FavoriteRepositoryImpl(this._datasource);

  final FavoriteLocalDatasource _datasource;

  @override
  Future<Result<List<Favorite>>> getFavorites() async {
    try {
      final favorites = await _datasource.getFavorites();
      return Success(favorites);
    } on Exception catch (e) {
      return Failure('즐겨찾기 목록 조회 실패', e);
    }
  }

  @override
  Future<Result<Favorite>> addFavorite({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
  }) async {
    try {
      final favorite = await _datasource.addFavorite(
        mainItemId: mainItemId,
        sideItemId: sideItemId,
        drinkItemId: drinkItemId,
      );
      return Success(favorite);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        return const Failure('이미 즐겨찾기에 추가된 조합입니다');
      }
      return Failure('즐겨찾기 추가 실패', e);
    } on Exception catch (e) {
      return Failure('즐겨찾기 추가 실패', e);
    }
  }

  @override
  Future<Result<void>> removeFavorite(int id) async {
    try {
      await _datasource.removeFavorite(id);
      return const Success(null);
    } on Exception catch (e) {
      return Failure('즐겨찾기 삭제 실패', e);
    }
  }

  @override
  Future<Result<bool>> isFavorite({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
  }) async {
    try {
      final result = await _datasource.isFavorite(
        mainItemId: mainItemId,
        sideItemId: sideItemId,
        drinkItemId: drinkItemId,
      );
      return Success(result);
    } on Exception catch (e) {
      return Failure('즐겨찾기 확인 실패', e);
    }
  }
}
