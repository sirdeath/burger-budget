import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/order_history.dart';

part 'history_provider.g.dart';

@riverpod
class HistoryList extends _$HistoryList {
  @override
  Future<List<OrderHistory>> build() async {
    final repo = ref.watch(historyRepositoryProvider);
    final result = await repo.getHistory();
    return switch (result) {
      Success(data: final items) => items,
      Failure(message: final msg) => throw Exception(msg),
    };
  }

  Future<void> addFromRecommendation({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
    required int totalPrice,
  }) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.addHistory(
      mainItemId: mainItemId,
      sideItemId: sideItemId,
      drinkItemId: drinkItemId,
      totalPrice: totalPrice,
    );
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.removeHistory(id);
    ref.invalidateSelf();
  }

  Future<void> clearAll() async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.clearHistory();
    ref.invalidateSelf();
  }
}
