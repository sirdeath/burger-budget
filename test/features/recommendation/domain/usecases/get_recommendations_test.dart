import 'package:burger_budget/core/errors/result.dart';
import 'package:burger_budget/features/menu/domain/entities/menu_item.dart';
import 'package:burger_budget/features/recommendation/domain/entities/recommendation.dart';
import 'package:burger_budget/features/recommendation/domain/repositories/recommendation_repository.dart';
import 'package:burger_budget/features/recommendation/domain/usecases/get_recommendations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecommendationRepository extends Mock
    implements RecommendationRepository {}

void main() {
  late MockRecommendationRepository mockRepository;
  late GetRecommendations usecase;

  setUpAll(() {
    registerFallbackValue(SortMode.bestValue);
  });

  setUp(() {
    mockRepository = MockRecommendationRepository();
    usecase = GetRecommendations(mockRepository);
  });

  final testRecommendations = [
    const Recommendation(
      mainItem: MenuItem(
        id: 'mcd_001',
        franchise: 'mcd',
        name: '빅맥',
        type: MenuType.burger,
        price: 5500,
        calories: 583,
      ),
      sideItem: MenuItem(
        id: 'mcd_s01',
        franchise: 'mcd',
        name: '프렌치 프라이',
        type: MenuType.side,
        price: 2800,
        calories: 330,
      ),
      drinkItem: MenuItem(
        id: 'mcd_d01',
        franchise: 'mcd',
        name: '코카콜라',
        type: MenuType.drink,
        price: 2200,
        calories: 190,
      ),
    ),
  ];

  group('GetRecommendations', () {
    test('should delegate to repository with correct params', () async {
      when(() => mockRepository.getRecommendations(
            budget: 10000,
            franchises: ['mcd'],
            sort: SortMode.bestValue,
          )).thenAnswer((_) async => Success(testRecommendations));

      final result = await usecase(
        budget: 10000,
        franchises: ['mcd'],
      );

      expect(result, isA<Success<List<Recommendation>>>());
      final data = (result as Success<List<Recommendation>>).data;
      expect(data.length, 1);
      expect(data[0].mainItem.name, '빅맥');
      expect(data[0].totalPrice, 10500);

      verify(() => mockRepository.getRecommendations(
            budget: 10000,
            franchises: ['mcd'],
            sort: SortMode.bestValue,
          )).called(1);
    });

    test('should pass custom sort mode', () async {
      when(() => mockRepository.getRecommendations(
            budget: 10000,
            franchises: ['mcd'],
            sort: SortMode.lowestCalories,
          )).thenAnswer((_) async => Success(testRecommendations));

      await usecase(
        budget: 10000,
        franchises: ['mcd'],
        sort: SortMode.lowestCalories,
      );

      verify(() => mockRepository.getRecommendations(
            budget: 10000,
            franchises: ['mcd'],
            sort: SortMode.lowestCalories,
          )).called(1);
    });

    test('should return Failure from repository', () async {
      when(() => mockRepository.getRecommendations(
            budget: any(named: 'budget'),
            franchises: any(named: 'franchises'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => const Failure('추천 생성 실패'));

      final result = await usecase(
        budget: 10000,
        franchises: ['mcd'],
      );

      expect(result, isA<Failure<List<Recommendation>>>());
      expect((result as Failure).message, '추천 생성 실패');
    });
  });
}
