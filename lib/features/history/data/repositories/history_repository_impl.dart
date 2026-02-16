import '../../../../core/errors/result.dart';
import '../../domain/entities/order_history.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._datasource);

  final HistoryLocalDatasource _datasource;

  @override
  Future<Result<List<OrderHistory>>> getHistory() async {
    try {
      final history = await _datasource.getHistory();
      return Success(history);
    } on Exception catch (e) {
      return Failure('주문 이력 조회 실패', e);
    }
  }

  @override
  Future<Result<OrderHistory>> addHistory({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
    required int totalPrice,
  }) async {
    try {
      final history = await _datasource.addHistory(
        mainItemId: mainItemId,
        sideItemId: sideItemId,
        drinkItemId: drinkItemId,
        totalPrice: totalPrice,
      );
      return Success(history);
    } on Exception catch (e) {
      return Failure('주문 이력 추가 실패', e);
    }
  }

  @override
  Future<Result<void>> removeHistory(int id) async {
    try {
      await _datasource.removeHistory(id);
      return const Success(null);
    } on Exception catch (e) {
      return Failure('주문 이력 삭제 실패', e);
    }
  }

  @override
  Future<Result<void>> clearHistory() async {
    try {
      await _datasource.clearHistory();
      return const Success(null);
    } on Exception catch (e) {
      return Failure('주문 이력 초기화 실패', e);
    }
  }
}
