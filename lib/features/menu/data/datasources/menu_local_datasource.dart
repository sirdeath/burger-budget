import '../../../../core/database/database_helper.dart';
import '../models/menu_item_model.dart';

class MenuLocalDatasource {
  const MenuLocalDatasource(this._dbHelper);

  final DatabaseHelper _dbHelper;

  Future<List<MenuItemModel>> getMenusByFranchise(
    List<String> franchises,
  ) async {
    final db = await _dbHelper.database;
    final placeholders = List.filled(franchises.length, '?').join(',');
    final result = await db.query(
      'menus',
      where: 'franchise IN ($placeholders)',
      whereArgs: franchises,
      orderBy: 'price DESC',
    );
    return result.map(MenuItemModel.fromMap).toList();
  }

  Future<List<MenuItemModel>> getMenusWithinBudget(
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

  Future<MenuItemModel?> getMenuById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'menus',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return MenuItemModel.fromMap(result.first);
  }
}
