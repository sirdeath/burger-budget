import 'package:burger_budget/core/errors/result.dart';
import 'package:burger_budget/features/menu/data/models/menu_item_model.dart';
import 'package:burger_budget/features/menu/domain/entities/menu_item.dart';
import 'package:burger_budget/features/recommendation/data/datasources/recommendation_datasource.dart';
import 'package:burger_budget/features/recommendation/data/repositories/recommendation_repository_impl.dart';
import 'package:burger_budget/features/recommendation/domain/entities/recommendation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecommendationDatasource extends Mock
    implements RecommendationDatasource {}

void main() {
  late MockRecommendationDatasource mockDatasource;
  late RecommendationRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockRecommendationDatasource();
    repository = RecommendationRepositoryImpl(mockDatasource);
  });

  // 가격 내림차순 (datasource가 orderBy: 'price DESC'로 반환)
  const candidates = [
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
      name: '맥치킨',
      type: MenuType.burger,
      price: 3500,
      calories: 400,
    ),
    MenuItemModel(
      id: 'mcd_s01',
      franchise: 'mcd',
      name: '프렌치 프라이',
      type: MenuType.side,
      price: 2800,
      calories: 330,
    ),
    MenuItemModel(
      id: 'mcd_s02',
      franchise: 'mcd',
      name: '맥너겟 6조각',
      type: MenuType.side,
      price: 3500,
      calories: 420,
    ),
    MenuItemModel(
      id: 'mcd_d01',
      franchise: 'mcd',
      name: '코카콜라',
      type: MenuType.drink,
      price: 2200,
      calories: 190,
    ),
    MenuItemModel(
      id: 'mcd_d02',
      franchise: 'mcd',
      name: '아메리카노',
      type: MenuType.drink,
      price: 2500,
      calories: 10,
    ),
  ];

  group('getRecommendations', () {
    test('should return recommendations with main + side + drink', () async {
      when(() => mockDatasource.getCandidates(15000, ['mcd']))
          .thenAnswer((_) async => candidates);

      final result = await repository.getRecommendations(
        budget: 15000,
        franchises: ['mcd'],
      );

      expect(result, isA<Success<List<Recommendation>>>());
      final data = (result as Success<List<Recommendation>>).data;
      expect(data, isNotEmpty);
      // 첫 번째 추천: 가장 비싼 버거(빅맥) 기반
      expect(data[0].mainItem.name, '빅맥');
      expect(data[0].sideItem, isNotNull);
      expect(data[0].drinkItem, isNotNull);
    });

    test('should return empty when no mains available', () async {
      const onlyDrinks = [
        MenuItemModel(
          id: 'mcd_d01',
          franchise: 'mcd',
          name: '코카콜라',
          type: MenuType.drink,
          price: 2200,
          calories: 190,
        ),
      ];
      when(() => mockDatasource.getCandidates(3000, ['mcd']))
          .thenAnswer((_) async => onlyDrinks);

      final result = await repository.getRecommendations(
        budget: 3000,
        franchises: ['mcd'],
      );

      expect(result, isA<Success<List<Recommendation>>>());
      expect((result as Success<List<Recommendation>>).data, isEmpty);
    });

    test('should omit side/drink when budget is tight', () async {
      const cheapBurgerOnly = [
        MenuItemModel(
          id: 'mcd_002',
          franchise: 'mcd',
          name: '맥치킨',
          type: MenuType.burger,
          price: 3500,
          calories: 400,
        ),
      ];
      when(() => mockDatasource.getCandidates(4000, ['mcd']))
          .thenAnswer((_) async => cheapBurgerOnly);

      final result = await repository.getRecommendations(
        budget: 4000,
        franchises: ['mcd'],
      );

      expect(result, isA<Success<List<Recommendation>>>());
      final data = (result as Success<List<Recommendation>>).data;
      expect(data.length, 1);
      expect(data[0].mainItem.name, '맥치킨');
      expect(data[0].sideItem, isNull);
      expect(data[0].drinkItem, isNull);
    });

    test('should sort by bestValue (highest total price first)', () async {
      when(() => mockDatasource.getCandidates(15000, ['mcd']))
          .thenAnswer((_) async => candidates);

      final result = await repository.getRecommendations(
        budget: 15000,
        franchises: ['mcd'],
        sort: SortMode.bestValue,
      );

      final data = (result as Success<List<Recommendation>>).data;
      for (var i = 0; i < data.length - 1; i++) {
        expect(
          data[i].totalPrice,
          greaterThanOrEqualTo(data[i + 1].totalPrice),
        );
      }
    });

    test('should sort by lowestCalories', () async {
      when(() => mockDatasource.getCandidates(15000, ['mcd']))
          .thenAnswer((_) async => candidates);

      final result = await repository.getRecommendations(
        budget: 15000,
        franchises: ['mcd'],
        sort: SortMode.lowestCalories,
      );

      final data = (result as Success<List<Recommendation>>).data;
      for (var i = 0; i < data.length - 1; i++) {
        final aCal = data[i].totalCalories ?? double.maxFinite.toInt();
        final bCal = data[i + 1].totalCalories ?? double.maxFinite.toInt();
        expect(aCal, lessThanOrEqualTo(bCal));
      }
    });

    test('should prefer sets over burgers when available', () async {
      const withSets = [
        MenuItemModel(
          id: 'mcd_set01',
          franchise: 'mcd',
          name: '빅맥세트',
          type: MenuType.set_,
          price: 7500,
          calories: 1100,
        ),
        MenuItemModel(
          id: 'mcd_001',
          franchise: 'mcd',
          name: '빅맥',
          type: MenuType.burger,
          price: 5500,
          calories: 583,
        ),
        MenuItemModel(
          id: 'mcd_d01',
          franchise: 'mcd',
          name: '코카콜라',
          type: MenuType.drink,
          price: 2200,
          calories: 190,
        ),
      ];
      when(() => mockDatasource.getCandidates(15000, ['mcd']))
          .thenAnswer((_) async => withSets);

      final result = await repository.getRecommendations(
        budget: 15000,
        franchises: ['mcd'],
      );

      final data = (result as Success<List<Recommendation>>).data;
      // 세트가 메인으로 사용되어야 함
      expect(data[0].mainItem.type, MenuType.set_);
    });

    test('should limit to maxRecommendations', () async {
      // 6개 버거 후보
      final manyBurgers = List.generate(
        6,
        (i) => MenuItemModel(
          id: 'mcd_$i',
          franchise: 'mcd',
          name: '버거$i',
          type: MenuType.burger,
          price: 5000 - (i * 100),
          calories: 500,
        ),
      );
      when(() => mockDatasource.getCandidates(15000, ['mcd']))
          .thenAnswer((_) async => manyBurgers);

      final result = await repository.getRecommendations(
        budget: 15000,
        franchises: ['mcd'],
      );

      final data = (result as Success<List<Recommendation>>).data;
      expect(data.length, lessThanOrEqualTo(5));
    });

    test('should return Failure on datasource exception', () async {
      when(() => mockDatasource.getCandidates(any(), any()))
          .thenThrow(Exception('DB error'));

      final result = await repository.getRecommendations(
        budget: 10000,
        franchises: ['mcd'],
      );

      expect(result, isA<Failure<List<Recommendation>>>());
      expect((result as Failure).message, '추천 생성 실패');
    });
  });

  group('Recommendation entity', () {
    test('totalPrice should sum all items', () {
      const rec = Recommendation(
        mainItem: MenuItem(
          id: 'a',
          franchise: 'mcd',
          name: 'A',
          type: MenuType.burger,
          price: 5000,
        ),
        sideItem: MenuItem(
          id: 'b',
          franchise: 'mcd',
          name: 'B',
          type: MenuType.side,
          price: 3000,
        ),
        drinkItem: MenuItem(
          id: 'c',
          franchise: 'mcd',
          name: 'C',
          type: MenuType.drink,
          price: 2000,
        ),
      );

      expect(rec.totalPrice, 10000);
    });

    test('totalPrice with no side/drink', () {
      const rec = Recommendation(
        mainItem: MenuItem(
          id: 'a',
          franchise: 'mcd',
          name: 'A',
          type: MenuType.burger,
          price: 5000,
        ),
      );

      expect(rec.totalPrice, 5000);
    });

    test('totalCalories returns null when main has no calories', () {
      const rec = Recommendation(
        mainItem: MenuItem(
          id: 'a',
          franchise: 'mcd',
          name: 'A',
          type: MenuType.burger,
          price: 5000,
        ),
      );

      expect(rec.totalCalories, isNull);
    });

    test('totalCalories sums all items', () {
      const rec = Recommendation(
        mainItem: MenuItem(
          id: 'a',
          franchise: 'mcd',
          name: 'A',
          type: MenuType.burger,
          price: 5000,
          calories: 500,
        ),
        sideItem: MenuItem(
          id: 'b',
          franchise: 'mcd',
          name: 'B',
          type: MenuType.side,
          price: 3000,
          calories: 300,
        ),
        drinkItem: MenuItem(
          id: 'c',
          franchise: 'mcd',
          name: 'C',
          type: MenuType.drink,
          price: 2000,
          calories: 200,
        ),
      );

      expect(rec.totalCalories, 1000);
    });
  });
}
