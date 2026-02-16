import 'package:burger_budget/core/errors/result.dart';
import 'package:burger_budget/features/favorite/data/datasources/favorite_local_datasource.dart';
import 'package:burger_budget/features/favorite/data/models/favorite_model.dart';
import 'package:burger_budget/features/favorite/data/repositories/favorite_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';

class MockFavoriteLocalDatasource extends Mock
    implements FavoriteLocalDatasource {}

class MockDatabaseException extends Mock implements DatabaseException {}

void main() {
  late FavoriteRepositoryImpl repository;
  late MockFavoriteLocalDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockFavoriteLocalDatasource();
    repository = FavoriteRepositoryImpl(mockDatasource);
  });

  group('FavoriteRepositoryImpl', () {
    final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);
    final testFavorite = FavoriteModel(
      id: 1,
      mainItemId: 'burger_1',
      sideItemId: 'side_1',
      drinkItemId: 'drink_1',
      createdAt: testDateTime,
    );

    group('getFavorites', () {
      test('should return Success with favorites list on success', () async {
        // Arrange
        final favorites = [testFavorite];
        when(() => mockDatasource.getFavorites()).thenAnswer(
          (_) async => favorites,
        );

        // Act
        final result = await repository.getFavorites();

        // Assert
        expect(result, isA<Success>());
        final success = result as Success;
        expect(success.data, favorites);
        verify(() => mockDatasource.getFavorites()).called(1);
      });

      test('should return Failure on exception', () async {
        // Arrange
        when(() => mockDatasource.getFavorites()).thenThrow(
          Exception('DB Error'),
        );

        // Act
        final result = await repository.getFavorites();

        // Assert
        expect(result, isA<Failure>());
        final failure = result as Failure;
        expect(failure.message, '즐겨찾기 목록 조회 실패');
        verify(() => mockDatasource.getFavorites()).called(1);
      });
    });

    group('addFavorite', () {
      test('should return Success with favorite on success', () async {
        // Arrange
        when(
          () => mockDatasource.addFavorite(
            mainItemId: any(named: 'mainItemId'),
            sideItemId: any(named: 'sideItemId'),
            drinkItemId: any(named: 'drinkItemId'),
          ),
        ).thenAnswer((_) async => testFavorite);

        // Act
        final result = await repository.addFavorite(
          mainItemId: 'burger_1',
          sideItemId: 'side_1',
          drinkItemId: 'drink_1',
        );

        // Assert
        expect(result, isA<Success>());
        final success = result as Success;
        expect(success.data, testFavorite);
        verify(
          () => mockDatasource.addFavorite(
            mainItemId: 'burger_1',
            sideItemId: 'side_1',
            drinkItemId: 'drink_1',
          ),
        ).called(1);
      });

      test('should return Failure on unique constraint error', () async {
        // Arrange
        final uniqueError = MockDatabaseException();
        when(() => uniqueError.isUniqueConstraintError()).thenReturn(true);
        when(
          () => mockDatasource.addFavorite(
            mainItemId: any(named: 'mainItemId'),
            sideItemId: any(named: 'sideItemId'),
            drinkItemId: any(named: 'drinkItemId'),
          ),
        ).thenThrow(uniqueError);

        // Act
        final result = await repository.addFavorite(
          mainItemId: 'burger_1',
          sideItemId: 'side_1',
          drinkItemId: 'drink_1',
        );

        // Assert
        expect(result, isA<Failure>());
        final failure = result as Failure;
        expect(failure.message, '이미 즐겨찾기에 추가된 조합입니다');
      });

      test('should return Failure on other database exception', () async {
        // Arrange
        final dbError = MockDatabaseException();
        when(() => dbError.isUniqueConstraintError()).thenReturn(false);
        when(
          () => mockDatasource.addFavorite(
            mainItemId: any(named: 'mainItemId'),
            sideItemId: any(named: 'sideItemId'),
            drinkItemId: any(named: 'drinkItemId'),
          ),
        ).thenThrow(dbError);

        // Act
        final result = await repository.addFavorite(
          mainItemId: 'burger_1',
          sideItemId: 'side_1',
          drinkItemId: 'drink_1',
        );

        // Assert
        expect(result, isA<Failure>());
        final failure = result as Failure;
        expect(failure.message, '즐겨찾기 추가 실패');
      });

      test('should return Failure on general exception', () async {
        // Arrange
        when(
          () => mockDatasource.addFavorite(
            mainItemId: any(named: 'mainItemId'),
            sideItemId: any(named: 'sideItemId'),
            drinkItemId: any(named: 'drinkItemId'),
          ),
        ).thenThrow(Exception('General error'));

        // Act
        final result = await repository.addFavorite(
          mainItemId: 'burger_1',
          sideItemId: 'side_1',
          drinkItemId: 'drink_1',
        );

        // Assert
        expect(result, isA<Failure>());
        final failure = result as Failure;
        expect(failure.message, '즐겨찾기 추가 실패');
      });
    });

    group('removeFavorite', () {
      test('should return Success on success', () async {
        // Arrange
        when(() => mockDatasource.removeFavorite(any())).thenAnswer(
          (_) async {},
        );

        // Act
        final result = await repository.removeFavorite(1);

        // Assert
        expect(result, isA<Success>());
        verify(() => mockDatasource.removeFavorite(1)).called(1);
      });

      test('should return Failure on exception', () async {
        // Arrange
        when(() => mockDatasource.removeFavorite(any())).thenThrow(
          Exception('DB Error'),
        );

        // Act
        final result = await repository.removeFavorite(1);

        // Assert
        expect(result, isA<Failure>());
        final failure = result as Failure;
        expect(failure.message, '즐겨찾기 삭제 실패');
        verify(() => mockDatasource.removeFavorite(1)).called(1);
      });
    });

    group('isFavorite', () {
      test('should return Success with true when favorite exists', () async {
        // Arrange
        when(
          () => mockDatasource.isFavorite(
            mainItemId: any(named: 'mainItemId'),
            sideItemId: any(named: 'sideItemId'),
            drinkItemId: any(named: 'drinkItemId'),
          ),
        ).thenAnswer((_) async => true);

        // Act
        final result = await repository.isFavorite(
          mainItemId: 'burger_1',
          sideItemId: 'side_1',
          drinkItemId: 'drink_1',
        );

        // Assert
        expect(result, isA<Success>());
        final success = result as Success;
        expect(success.data, true);
        verify(
          () => mockDatasource.isFavorite(
            mainItemId: 'burger_1',
            sideItemId: 'side_1',
            drinkItemId: 'drink_1',
          ),
        ).called(1);
      });

      test('should return Success with false when not favorite', () async {
        // Arrange
        when(
          () => mockDatasource.isFavorite(
            mainItemId: any(named: 'mainItemId'),
            sideItemId: any(named: 'sideItemId'),
            drinkItemId: any(named: 'drinkItemId'),
          ),
        ).thenAnswer((_) async => false);

        // Act
        final result = await repository.isFavorite(
          mainItemId: 'burger_1',
          sideItemId: 'side_1',
          drinkItemId: 'drink_1',
        );

        // Assert
        expect(result, isA<Success>());
        final success = result as Success;
        expect(success.data, false);
      });

      test('should return Failure on exception', () async {
        // Arrange
        when(
          () => mockDatasource.isFavorite(
            mainItemId: any(named: 'mainItemId'),
            sideItemId: any(named: 'sideItemId'),
            drinkItemId: any(named: 'drinkItemId'),
          ),
        ).thenThrow(Exception('DB Error'));

        // Act
        final result = await repository.isFavorite(
          mainItemId: 'burger_1',
          sideItemId: 'side_1',
          drinkItemId: 'drink_1',
        );

        // Assert
        expect(result, isA<Failure>());
        final failure = result as Failure;
        expect(failure.message, '즐겨찾기 확인 실패');
      });
    });
  });
}
