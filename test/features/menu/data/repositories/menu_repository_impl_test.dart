import 'package:burger_budget/core/errors/result.dart';
import 'package:burger_budget/features/menu/data/datasources/menu_local_datasource.dart';
import 'package:burger_budget/features/menu/data/models/menu_item_model.dart';
import 'package:burger_budget/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:burger_budget/features/menu/domain/entities/menu_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMenuLocalDatasource extends Mock implements MenuLocalDatasource {}

void main() {
  late MockMenuLocalDatasource mockDatasource;
  late MenuRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockMenuLocalDatasource();
    repository = MenuRepositoryImpl(mockDatasource);
  });

  const testItems = [
    MenuItemModel(
      id: 'mcd_001',
      franchise: 'mcd',
      name: '빅맥',
      type: MenuType.burger,
      price: 5500,
      calories: 583,
    ),
    MenuItemModel(
      id: 'mcd_002',
      franchise: 'mcd',
      name: '맥너겟',
      type: MenuType.side,
      price: 3500,
      calories: 420,
    ),
  ];

  group('getMenusByFranchise', () {
    test('should return Success with menu items', () async {
      when(() => mockDatasource.getMenusByFranchise(['mcd']))
          .thenAnswer((_) async => testItems);

      final result = await repository.getMenusByFranchise(['mcd']);

      expect(result, isA<Success<List<MenuItem>>>());
      final data = (result as Success<List<MenuItem>>).data;
      expect(data.length, 2);
      expect(data[0].name, '빅맥');
    });

    test('should return Failure on exception', () async {
      when(() => mockDatasource.getMenusByFranchise(any()))
          .thenThrow(Exception('DB error'));

      final result = await repository.getMenusByFranchise(['mcd']);

      expect(result, isA<Failure<List<MenuItem>>>());
      expect((result as Failure).message, '메뉴 조회 실패');
    });
  });

  group('getMenusWithinBudget', () {
    test('should return Success with filtered items', () async {
      when(() => mockDatasource.getMenusWithinBudget(10000, ['mcd']))
          .thenAnswer((_) async => testItems);

      final result = await repository.getMenusWithinBudget(10000, ['mcd']);

      expect(result, isA<Success<List<MenuItem>>>());
      expect((result as Success<List<MenuItem>>).data.length, 2);
    });

    test('should return Failure on exception', () async {
      when(() => mockDatasource.getMenusWithinBudget(any(), any()))
          .thenThrow(Exception('DB error'));

      final result = await repository.getMenusWithinBudget(10000, ['mcd']);

      expect(result, isA<Failure<List<MenuItem>>>());
      expect((result as Failure).message, '예산 내 메뉴 조회 실패');
    });
  });

  group('getMenuById', () {
    test('should return Success with menu item', () async {
      when(() => mockDatasource.getMenuById('mcd_001'))
          .thenAnswer((_) async => testItems[0]);

      final result = await repository.getMenuById('mcd_001');

      expect(result, isA<Success<MenuItem>>());
      expect((result as Success<MenuItem>).data.name, '빅맥');
    });

    test('should return Failure when not found', () async {
      when(() => mockDatasource.getMenuById('nonexistent'))
          .thenAnswer((_) async => null);

      final result = await repository.getMenuById('nonexistent');

      expect(result, isA<Failure<MenuItem>>());
      expect((result as Failure).message, '메뉴를 찾을 수 없습니다');
    });

    test('should return Failure on exception', () async {
      when(() => mockDatasource.getMenuById(any()))
          .thenThrow(Exception('DB error'));

      final result = await repository.getMenuById('mcd_001');

      expect(result, isA<Failure<MenuItem>>());
      expect((result as Failure).message, '메뉴 상세 조회 실패');
    });
  });

  group('searchMenus', () {
    test('should return Success with matching items', () async {
      when(() => mockDatasource.searchMenus('빅'))
          .thenAnswer((_) async => [testItems[0]]);

      final result = await repository.searchMenus('빅');

      expect(result, isA<Success<List<MenuItem>>>());
      final data = (result as Success<List<MenuItem>>).data;
      expect(data.length, 1);
      expect(data[0].name, '빅맥');
    });

    test('should return Success with empty list when no matches', () async {
      when(() => mockDatasource.searchMenus('없는메뉴'))
          .thenAnswer((_) async => []);

      final result = await repository.searchMenus('없는메뉴');

      expect(result, isA<Success<List<MenuItem>>>());
      expect((result as Success<List<MenuItem>>).data.isEmpty, true);
    });

    test('should return Failure on exception', () async {
      when(() => mockDatasource.searchMenus(any()))
          .thenThrow(Exception('DB error'));

      final result = await repository.searchMenus('빅맥');

      expect(result, isA<Failure<List<MenuItem>>>());
      expect((result as Failure).message, '메뉴 검색 실패');
    });
  });
}
