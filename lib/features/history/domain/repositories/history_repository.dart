import '../../../../core/errors/result.dart';
import '../entities/order_history.dart';

abstract class HistoryRepository {
  Future<Result<List<OrderHistory>>> getHistory();

  Future<Result<OrderHistory>> addHistory({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
    required int totalPrice,
  });

  Future<Result<void>> removeHistory(int id);

  Future<Result<void>> clearHistory();
}
