import 'package:burger_budget/core/errors/result.dart';
import 'package:burger_budget/features/history/data/datasources/history_local_datasource.dart';
import 'package:burger_budget/features/history/data/models/order_history_model.dart';
import 'package:burger_budget/features/history/data/repositories/history_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHistoryLocalDatasource extends Mock
    implements HistoryLocalDatasource {}

void main() {
  late MockHistoryLocalDatasource mockDatasource;
  late HistoryRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockHistoryLocalDatasource();
    repository = HistoryRepositoryImpl(mockDatasource);
  });

  group('HistoryRepositoryImpl', () {
    final testDateTime = DateTime(2024, 1, 15, 12, 30);
    final testHistoryList = [
      OrderHistoryModel(
        id: 1,
        mainItemId: 'burger_001',
        sideItemId: 'fries_001',
        drinkItemId: 'coke_001',
        totalPrice: 15000,
        createdAt: testDateTime,
      ),
      OrderHistoryModel(
        id: 2,
        mainItemId: 'burger_002',
        totalPrice: 8000,
        createdAt: testDateTime.subtract(const Duration(days: 1)),
      ),
    ];

    group('getHistory', () {
      test('should return Success with history list on success', () async {
        when(() => mockDatasource.getHistory())
            .thenAnswer((_) async => testHistoryList);

        final result = await repository.getHistory();

        expect(result, isA<Success>());
        final success = result as Success;
        expect(success.data, testHistoryList);
        verify(() => mockDatasource.getHistory()).called(1);
      });

      test('should return Failure on exception', () async {
        when(() => mockDatasource.getHistory())
            .thenThrow(Exception('Database error'));

        final result = await repository.getHistory();

        expect(result, isA<Failure>());
        final failure = result as Failure;
        expect(failure.message, '주문 이력 조회 실패');
        expect(failure.exception, isA<Exception>());
        verify(() => mockDatasource.getHistory()).called(1);
      });
    });

    group('addHistory', () {
      final testModel = OrderHistoryModel(
        id: 1,
        mainItemId: 'burger_001',
        sideItemId: 'fries_001',
        drinkItemId: 'coke_001',
        totalPrice: 15000,
        createdAt: testDateTime,
      );

      test('should return Success with created history on success', () async {
        when(() => mockDatasource.addHistory(
              mainItemId: any(named: 'mainItemId'),
              sideItemId: any(named: 'sideItemId'),
              drinkItemId: any(named: 'drinkItemId'),
              totalPrice: any(named: 'totalPrice'),
            )).thenAnswer((_) async => testModel);

        final result = await repository.addHistory(
          mainItemId: 'burger_001',
          sideItemId: 'fries_001',
          drinkItemId: 'coke_001',
          totalPrice: 15000,
        );

        expect(result, isA<Success>());
        final success = result as Success;
        expect(success.data, testModel);
        verify(() => mockDatasource.addHistory(
              mainItemId: 'burger_001',
              sideItemId: 'fries_001',
              drinkItemId: 'coke_001',
              totalPrice: 15000,
            )).called(1);
      });

      test('should return Failure on exception', () async {
        when(() => mockDatasource.addHistory(
              mainItemId: any(named: 'mainItemId'),
              sideItemId: any(named: 'sideItemId'),
              drinkItemId: any(named: 'drinkItemId'),
              totalPrice: any(named: 'totalPrice'),
            )).thenThrow(Exception('Insert error'));

        final result = await repository.addHistory(
          mainItemId: 'burger_001',
          totalPrice: 8000,
        );

        expect(result, isA<Failure>());
        final failure = result as Failure;
        expect(failure.message, '주문 이력 추가 실패');
        expect(failure.exception, isA<Exception>());
      });
    });

    group('removeHistory', () {
      test('should return Success on successful removal', () async {
        when(() => mockDatasource.removeHistory(any()))
            .thenAnswer((_) async => {});

        final result = await repository.removeHistory(1);

        expect(result, isA<Success>());
        verify(() => mockDatasource.removeHistory(1)).called(1);
      });

      test('should return Failure on exception', () async {
        when(() => mockDatasource.removeHistory(any()))
            .thenThrow(Exception('Delete error'));

        final result = await repository.removeHistory(1);

        expect(result, isA<Failure>());
        final failure = result as Failure;
        expect(failure.message, '주문 이력 삭제 실패');
        expect(failure.exception, isA<Exception>());
      });
    });

    group('clearHistory', () {
      test('should return Success on successful clear', () async {
        when(() => mockDatasource.clearHistory())
            .thenAnswer((_) async => {});

        final result = await repository.clearHistory();

        expect(result, isA<Success>());
        verify(() => mockDatasource.clearHistory()).called(1);
      });

      test('should return Failure on exception', () async {
        when(() => mockDatasource.clearHistory())
            .thenThrow(Exception('Clear error'));

        final result = await repository.clearHistory();

        expect(result, isA<Failure>());
        final failure = result as Failure;
        expect(failure.message, '주문 이력 초기화 실패');
        expect(failure.exception, isA<Exception>());
      });
    });
  });
}
