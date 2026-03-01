import '../../../../core/database/database_helper.dart';
import '../../../menu/data/models/menu_item_model.dart';

class RecommendationDatasource {
  const RecommendationDatasource(this._dbHelper);

  final DatabaseHelper _dbHelper;

  Future<List<MenuItemModel>> getCandidates(
    int budget,
    List<String> franchises, {
    bool deliveryMode = false,
  }) async {
    final db = await _dbHelper.database;
    final placeholders =
        List.filled(franchises.length, '?').join(',');

    final String where;
    final String orderBy;
    if (deliveryMode) {
      where = 'franchise IN ($placeholders) '
          'AND price_delivery IS NOT NULL '
          'AND price_delivery <= ?';
      orderBy = 'price_delivery DESC';
    } else {
      where = 'franchise IN ($placeholders) AND price <= ?';
      orderBy = 'price DESC';
    }

    final result = await db.query(
      'menus',
      where: where,
      whereArgs: [...franchises, budget],
      orderBy: orderBy,
    );
    return result.map(MenuItemModel.fromMap).toList();
  }
}
