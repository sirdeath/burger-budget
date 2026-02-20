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

  // 기본 후보군 (가격 내림차순, 모두 mcd 프랜차이즈)
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

    // ── 신규 알고리즘 테스트 ──

    test('variety: multiple sides/drinks should yield different combo variants',
        () async {
      // 2개의 사이드, 3개의 음료가 있으면 같은 메인에 대해
      // 사이드/음료가 서로 다른 조합이 결과에 포함되어야 함
      const richCandidates = [
        MenuItemModel(
          id: 'mcd_001',
          franchise: 'mcd',
          name: '빅맥',
          type: MenuType.burger,
          price: 5500,
          calories: 583,
        ),
        MenuItemModel(
          id: 'mcd_s01',
          franchise: 'mcd',
          name: '프렌치 프라이',
          type: MenuType.side,
          price: 2000,
          calories: 330,
        ),
        MenuItemModel(
          id: 'mcd_s02',
          franchise: 'mcd',
          name: '맥너겟',
          type: MenuType.side,
          price: 2500,
          calories: 420,
        ),
        MenuItemModel(
          id: 'mcd_d01',
          franchise: 'mcd',
          name: '코카콜라',
          type: MenuType.drink,
          price: 1500,
          calories: 190,
        ),
        MenuItemModel(
          id: 'mcd_d02',
          franchise: 'mcd',
          name: '아메리카노',
          type: MenuType.drink,
          price: 1800,
          calories: 10,
        ),
        MenuItemModel(
          id: 'mcd_d03',
          franchise: 'mcd',
          name: '오렌지주스',
          type: MenuType.drink,
          price: 2000,
          calories: 150,
        ),
      ];
      when(() => mockDatasource.getCandidates(15000, ['mcd']))
          .thenAnswer((_) async => richCandidates);

      final result = await repository.getRecommendations(
        budget: 15000,
        franchises: ['mcd'],
      );

      final data = (result as Success<List<Recommendation>>).data;
      // 빅맥 기반 결과가 2개 포함되고, 두 결과의 사이드 또는 음료가 달라야 함
      final bigMacCombos =
          data.where((r) => r.mainItem.id == 'mcd_001').toList();
      expect(bigMacCombos.length, greaterThan(1));

      // 사이드 또는 음료 중 적어도 하나가 서로 다른 조합이 있어야 함
      final allSame = bigMacCombos.every((r) =>
          r.sideItem?.id == bigMacCombos[0].sideItem?.id &&
          r.drinkItem?.id == bigMacCombos[0].drinkItem?.id);
      expect(allSame, isFalse,
          reason: '동일한 메인에 대해 서로 다른 사이드/음료 조합이 생성되어야 합니다');
    });

    test(
        'same-franchise grouping: cross-franchise combos must not appear in results',
        () async {
      // mcd 버거 + bk 사이드를 함께 넣어도 조합이 섞이면 안 됨
      const mixedFranchise = [
        MenuItemModel(
          id: 'mcd_001',
          franchise: 'mcd',
          name: '빅맥',
          type: MenuType.burger,
          price: 5500,
          calories: 583,
        ),
        MenuItemModel(
          id: 'bk_001',
          franchise: 'bk',
          name: '와퍼',
          type: MenuType.burger,
          price: 6000,
          calories: 660,
        ),
        // mcd 사이드
        MenuItemModel(
          id: 'mcd_s01',
          franchise: 'mcd',
          name: '프렌치 프라이',
          type: MenuType.side,
          price: 2000,
          calories: 330,
        ),
        // bk 사이드
        MenuItemModel(
          id: 'bk_s01',
          franchise: 'bk',
          name: '어니언링',
          type: MenuType.side,
          price: 2200,
          calories: 350,
        ),
        // mcd 음료
        MenuItemModel(
          id: 'mcd_d01',
          franchise: 'mcd',
          name: '코카콜라',
          type: MenuType.drink,
          price: 1500,
          calories: 190,
        ),
        // bk 음료
        MenuItemModel(
          id: 'bk_d01',
          franchise: 'bk',
          name: '펩시',
          type: MenuType.drink,
          price: 1500,
          calories: 180,
        ),
      ];
      when(() => mockDatasource.getCandidates(15000, ['mcd', 'bk']))
          .thenAnswer((_) async => mixedFranchise);

      final result = await repository.getRecommendations(
        budget: 15000,
        franchises: ['mcd', 'bk'],
      );

      final data = (result as Success<List<Recommendation>>).data;
      expect(data, isNotEmpty);

      // 모든 결과에서 메인·사이드·음료의 프랜차이즈가 일치해야 함
      for (final rec in data) {
        final mainFranchise = rec.mainItem.franchise;
        if (rec.sideItem != null) {
          expect(
            rec.sideItem!.franchise,
            mainFranchise,
            reason:
                '사이드(${rec.sideItem!.id})의 프랜차이즈가 메인(${rec.mainItem.id})과 다릅니다',
          );
        }
        if (rec.drinkItem != null) {
          expect(
            rec.drinkItem!.franchise,
            mainFranchise,
            reason:
                '음료(${rec.drinkItem!.id})의 프랜차이즈가 메인(${rec.mainItem.id})과 다릅니다',
          );
        }
      }
    });

    test('personCount: budget divided per person before passing to datasource',
        () async {
      // budget=20000, personCount=2 → datasource는 10000으로 호출됨
      const perPersonCandidates = [
        MenuItemModel(
          id: 'mcd_001',
          franchise: 'mcd',
          name: '빅맥',
          type: MenuType.burger,
          price: 5500,
          calories: 583,
        ),
        MenuItemModel(
          id: 'mcd_s01',
          franchise: 'mcd',
          name: '프렌치 프라이',
          type: MenuType.side,
          price: 2000,
          calories: 330,
        ),
        MenuItemModel(
          id: 'mcd_d01',
          franchise: 'mcd',
          name: '코카콜라',
          type: MenuType.drink,
          price: 1500,
          calories: 190,
        ),
      ];
      when(() => mockDatasource.getCandidates(10000, ['mcd']))
          .thenAnswer((_) async => perPersonCandidates);

      final result = await repository.getRecommendations(
        budget: 20000,
        franchises: ['mcd'],
        personCount: 2,
      );

      // datasource가 10000(=20000÷2)으로 호출되었는지 검증
      verify(() => mockDatasource.getCandidates(10000, ['mcd'])).called(1);

      expect(result, isA<Success<List<Recommendation>>>());
      final data = (result as Success<List<Recommendation>>).data;
      expect(data, isNotEmpty);

      // 각 추천의 총 가격이 1인분 예산(10000) 이하여야 함
      for (final rec in data) {
        expect(
          rec.totalPrice,
          lessThanOrEqualTo(10000),
          reason:
              '1인 예산 10000원 이내여야 하지만 ${rec.totalPrice}원입니다',
        );
      }
    });

    test(
        'personCount=1: datasource receives full budget (no division)',
        () async {
      when(() => mockDatasource.getCandidates(15000, ['mcd']))
          .thenAnswer((_) async => candidates);

      await repository.getRecommendations(
        budget: 15000,
        franchises: ['mcd'],
        personCount: 1,
      );

      // personCount=1이면 budget 그대로 전달
      verify(() => mockDatasource.getCandidates(15000, ['mcd'])).called(1);
    });

    test(
        'set with includesSide: should not recommend additional side item',
        () async {
      // 세트에 사이드 포함 → 추천 결과에 사이드 없어야 함
      const setWithSide = [
        MenuItemModel(
          id: 'mcd_set01',
          franchise: 'mcd',
          name: '빅맥세트',
          type: MenuType.set_,
          price: 7500,
          calories: 1100,
          includesSide: true,   // 사이드 포함 세트
          includesDrink: false,
        ),
        MenuItemModel(
          id: 'mcd_s01',
          franchise: 'mcd',
          name: '프렌치 프라이',
          type: MenuType.side,
          price: 2000,
          calories: 330,
        ),
        MenuItemModel(
          id: 'mcd_d01',
          franchise: 'mcd',
          name: '코카콜라',
          type: MenuType.drink,
          price: 1500,
          calories: 190,
        ),
      ];
      when(() => mockDatasource.getCandidates(15000, ['mcd']))
          .thenAnswer((_) async => setWithSide);

      final result = await repository.getRecommendations(
        budget: 15000,
        franchises: ['mcd'],
      );

      final data = (result as Success<List<Recommendation>>).data;
      final setResults = data.where(
        (r) => r.mainItem.id == 'mcd_set01',
      );
      expect(setResults, isNotEmpty);

      // includesSide=true인 세트에는 sideItem이 없어야 함
      for (final rec in setResults) {
        expect(
          rec.sideItem,
          isNull,
          reason: '사이드 포함 세트에는 추가 사이드가 붙으면 안 됩니다',
        );
      }
    });

    test(
        'set with includesDrink: should not recommend additional drink item',
        () async {
      // 세트에 음료 포함 → 추천 결과에 음료 없어야 함
      const setWithDrink = [
        MenuItemModel(
          id: 'mcd_set02',
          franchise: 'mcd',
          name: '맥치킨세트',
          type: MenuType.set_,
          price: 6500,
          calories: 900,
          includesSide: false,
          includesDrink: true,  // 음료 포함 세트
        ),
        MenuItemModel(
          id: 'mcd_s01',
          franchise: 'mcd',
          name: '프렌치 프라이',
          type: MenuType.side,
          price: 2000,
          calories: 330,
        ),
        MenuItemModel(
          id: 'mcd_d01',
          franchise: 'mcd',
          name: '코카콜라',
          type: MenuType.drink,
          price: 1500,
          calories: 190,
        ),
      ];
      when(() => mockDatasource.getCandidates(15000, ['mcd']))
          .thenAnswer((_) async => setWithDrink);

      final result = await repository.getRecommendations(
        budget: 15000,
        franchises: ['mcd'],
      );

      final data = (result as Success<List<Recommendation>>).data;
      final setResults = data.where(
        (r) => r.mainItem.id == 'mcd_set02',
      );
      expect(setResults, isNotEmpty);

      // includesDrink=true인 세트에는 drinkItem이 없어야 함
      for (final rec in setResults) {
        expect(
          rec.drinkItem,
          isNull,
          reason: '음료 포함 세트에는 추가 음료가 붙으면 안 됩니다',
        );
      }
    });

    test(
        'set with includesSide and includesDrink: no side or drink added',
        () async {
      // 사이드+음료 모두 포함 세트 → 사이드, 음료 모두 null
      const fullSet = [
        MenuItemModel(
          id: 'mcd_set03',
          franchise: 'mcd',
          name: '쿼터파운더세트',
          type: MenuType.set_,
          price: 9000,
          calories: 1300,
          includesSide: true,
          includesDrink: true,
        ),
        MenuItemModel(
          id: 'mcd_s01',
          franchise: 'mcd',
          name: '프렌치 프라이',
          type: MenuType.side,
          price: 2000,
          calories: 330,
        ),
        MenuItemModel(
          id: 'mcd_d01',
          franchise: 'mcd',
          name: '코카콜라',
          type: MenuType.drink,
          price: 1500,
          calories: 190,
        ),
      ];
      when(() => mockDatasource.getCandidates(15000, ['mcd']))
          .thenAnswer((_) async => fullSet);

      final result = await repository.getRecommendations(
        budget: 15000,
        franchises: ['mcd'],
      );

      final data = (result as Success<List<Recommendation>>).data;
      expect(data, isNotEmpty);
      expect(data[0].mainItem.id, 'mcd_set03');
      expect(data[0].sideItem, isNull,
          reason: '사이드+음료 포함 세트에는 추가 사이드가 없어야 합니다');
      expect(data[0].drinkItem, isNull,
          reason: '사이드+음료 포함 세트에는 추가 음료가 없어야 합니다');
    });

    test('diversity: same main item appears at most twice in results', () async {
      // 사이드·음료 다양하게 줘서 동일 메인 조합이 많이 생성되도록 유도
      const manyOptions = [
        MenuItemModel(
          id: 'mcd_001',
          franchise: 'mcd',
          name: '빅맥',
          type: MenuType.burger,
          price: 4000,
          calories: 583,
        ),
        MenuItemModel(
          id: 'mcd_s01',
          franchise: 'mcd',
          name: '사이드A',
          type: MenuType.side,
          price: 1000,
          calories: 100,
        ),
        MenuItemModel(
          id: 'mcd_s02',
          franchise: 'mcd',
          name: '사이드B',
          type: MenuType.side,
          price: 1100,
          calories: 110,
        ),
        MenuItemModel(
          id: 'mcd_s03',
          franchise: 'mcd',
          name: '사이드C',
          type: MenuType.side,
          price: 1200,
          calories: 120,
        ),
        MenuItemModel(
          id: 'mcd_d01',
          franchise: 'mcd',
          name: '음료A',
          type: MenuType.drink,
          price: 1000,
          calories: 80,
        ),
        MenuItemModel(
          id: 'mcd_d02',
          franchise: 'mcd',
          name: '음료B',
          type: MenuType.drink,
          price: 1100,
          calories: 90,
        ),
        MenuItemModel(
          id: 'mcd_d03',
          franchise: 'mcd',
          name: '음료C',
          type: MenuType.drink,
          price: 1200,
          calories: 100,
        ),
      ];
      when(() => mockDatasource.getCandidates(15000, ['mcd']))
          .thenAnswer((_) async => manyOptions);

      final result = await repository.getRecommendations(
        budget: 15000,
        franchises: ['mcd'],
      );

      final data = (result as Success<List<Recommendation>>).data;
      // 메인별 등장 횟수 계산
      final countByMain = <String, int>{};
      for (final rec in data) {
        final id = rec.mainItem.id;
        countByMain[id] = (countByMain[id] ?? 0) + 1;
      }

      // 어떤 메인도 3회 이상 등장하면 안 됨 (maxPerMain = 2)
      for (final entry in countByMain.entries) {
        expect(
          entry.value,
          lessThanOrEqualTo(2),
          reason: '메인 ${entry.key}이(가) 결과에 ${entry.value}번 등장했습니다 (최대 2회)',
        );
      }
    });

    test('diversity: deduplication removes identical combos', () async {
      // 후보가 하나의 버거, 사이드 없음, 음료 없음일 때
      // 중복 조합이 생성되지 않아야 함
      const singleBurger = [
        MenuItemModel(
          id: 'mcd_001',
          franchise: 'mcd',
          name: '빅맥',
          type: MenuType.burger,
          price: 5500,
          calories: 583,
        ),
      ];
      when(() => mockDatasource.getCandidates(6000, ['mcd']))
          .thenAnswer((_) async => singleBurger);

      final result = await repository.getRecommendations(
        budget: 6000,
        franchises: ['mcd'],
      );

      final data = (result as Success<List<Recommendation>>).data;
      // 버거 하나만 있으면 조합도 하나 (메인+null+null+null)
      expect(data.length, 1);
      expect(data[0].mainItem.id, 'mcd_001');
    });

    test(
        'scoring: combo with higher budget utilization ranks above low utilization',
        () async {
      // 예산 10000 기준:
      // - 버거A(9500) → 활용도 95%, 구성 25%  (높음)
      // - 버거B(3000) → 활용도 30%, 구성 25%  (낮음 + 잔액 페널티)
      // bestValue 정렬 시 버거A 기반 조합이 먼저 와야 함
      const scoringCandidates = [
        MenuItemModel(
          id: 'mcd_a',
          franchise: 'mcd',
          name: '비싼버거',
          type: MenuType.burger,
          price: 9500,
          calories: 800,
        ),
        MenuItemModel(
          id: 'mcd_b',
          franchise: 'mcd',
          name: '저렴한버거',
          type: MenuType.burger,
          price: 3000,
          calories: 400,
        ),
      ];
      when(() => mockDatasource.getCandidates(10000, ['mcd']))
          .thenAnswer((_) async => scoringCandidates);

      final result = await repository.getRecommendations(
        budget: 10000,
        franchises: ['mcd'],
        sort: SortMode.bestValue,
      );

      final data = (result as Success<List<Recommendation>>).data;
      expect(data, isNotEmpty);
      // bestValue 정렬 → 총 가격이 높은 것이 먼저 (9500 > 3000)
      expect(data[0].mainItem.id, 'mcd_a');
      expect(data[0].totalPrice, greaterThan(data.last.totalPrice));
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
