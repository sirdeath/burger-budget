import 'package:sqflite/sqflite.dart';

import '../../../../core/database/user_database_helper.dart';
import '../models/favorite_model.dart';

class FavoriteLocalDatasource {
  const FavoriteLocalDatasource(this._dbHelper);

  final UserDatabaseHelper _dbHelper;

  Future<List<FavoriteModel>> getFavorites() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'favorites',
      orderBy: 'created_at DESC',
    );
    return result.map(FavoriteModel.fromMap).toList();
  }

  Future<FavoriteModel> addFavorite({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final id = await db.insert(
      'favorites',
      {
        'main_item_id': mainItemId,
        'side_item_id': sideItemId,
        'drink_item_id': drinkItemId,
        'created_at': now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return FavoriteModel(
      id: id,
      mainItemId: mainItemId,
      sideItemId: sideItemId,
      drinkItemId: drinkItemId,
      createdAt: now,
    );
  }

  Future<void> removeFavorite(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isFavorite({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
  }) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'favorites',
      where: 'main_item_id = ? AND side_item_id IS ? AND drink_item_id IS ?',
      whereArgs: [mainItemId, sideItemId, drinkItemId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
