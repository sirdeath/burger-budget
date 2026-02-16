import '../../../../core/errors/result.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_local_datasource.dart';

class MenuRepositoryImpl implements MenuRepository {
  const MenuRepositoryImpl(this._datasource);

  final MenuLocalDatasource _datasource;

  @override
  Future<Result<List<MenuItem>>> getMenusByFranchise(
    List<String> franchises,
  ) async {
    try {
      final items = await _datasource.getMenusByFranchise(franchises);
      return Success(items);
    } on Exception catch (e) {
      return Failure('메뉴 조회 실패', e);
    }
  }

  @override
  Future<Result<List<MenuItem>>> getMenusWithinBudget(
    int budget,
    List<String> franchises,
  ) async {
    try {
      final items = await _datasource.getMenusWithinBudget(
        budget,
        franchises,
      );
      return Success(items);
    } on Exception catch (e) {
      return Failure('예산 내 메뉴 조회 실패', e);
    }
  }

  @override
  Future<Result<MenuItem>> getMenuById(String id) async {
    try {
      final item = await _datasource.getMenuById(id);
      if (item == null) {
        return const Failure('메뉴를 찾을 수 없습니다');
      }
      return Success(item);
    } on Exception catch (e) {
      return Failure('메뉴 상세 조회 실패', e);
    }
  }

  @override
  Future<Result<List<MenuItem>>> searchMenus(String query) async {
    try {
      final items = await _datasource.searchMenus(query);
      return Success(items);
    } on Exception catch (e) {
      return Failure('메뉴 검색 실패', e);
    }
  }
}
