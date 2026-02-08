import '../../../../core/errors/result.dart';
import '../entities/menu_item.dart';

abstract class MenuRepository {
  Future<Result<List<MenuItem>>> getMenusByFranchise(
    List<String> franchises,
  );

  Future<Result<List<MenuItem>>> getMenusWithinBudget(
    int budget,
    List<String> franchises,
  );

  Future<Result<MenuItem>> getMenuById(String id);
}
