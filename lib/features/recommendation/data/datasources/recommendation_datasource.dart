import '../../../../core/database/database_helper.dart';
import '../../../menu/data/models/menu_item_model.dart';

class RecommendationDatasource {
  const RecommendationDatasource(this._dbHelper);

  final DatabaseHelper _dbHelper;

  Future<List<MenuItemModel>> getCandidates(
    int budget,
    List<String> franchises,
  ) async {
    final db = await _dbHelper.database;
    final placeholders = List.filled(franchises.length, '?').join(',');
    final result = await db.query(
      'menus',
      where: 'franchise IN ($placeholders) AND price <= ?',
      whereArgs: [...franchises, budget],
      orderBy: 'price DESC',
    );
    return result.map(MenuItemModel.fromMap).toList();
  }
}
