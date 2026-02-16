import '../../../../core/database/user_database_helper.dart';
import '../models/order_history_model.dart';

class HistoryLocalDatasource {
  const HistoryLocalDatasource(this._dbHelper);

  final UserDatabaseHelper _dbHelper;

  Future<List<OrderHistoryModel>> getHistory() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'order_history',
      orderBy: 'created_at DESC',
    );
    return result.map(OrderHistoryModel.fromMap).toList();
  }

  Future<OrderHistoryModel> addHistory({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
    required int totalPrice,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final id = await db.insert(
      'order_history',
      {
        'main_item_id': mainItemId,
        'side_item_id': sideItemId,
        'drink_item_id': drinkItemId,
        'total_price': totalPrice,
        'created_at': now.toIso8601String(),
      },
    );

    return OrderHistoryModel(
      id: id,
      mainItemId: mainItemId,
      sideItemId: sideItemId,
      drinkItemId: drinkItemId,
      totalPrice: totalPrice,
      createdAt: now,
    );
  }

  Future<void> removeHistory(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'order_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearHistory() async {
    final db = await _dbHelper.database;
    await db.delete('order_history');
  }
}
