import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/order_history.dart';
import '../../domain/entities/rich_order_history.dart';

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
    if (!ref.mounted) return;
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.removeHistory(id);
    if (!ref.mounted) return;
    ref.invalidateSelf();
  }

  Future<void> clearAll() async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.clearHistory();
    if (!ref.mounted) return;
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<RichOrderHistory>> richHistoryList(Ref ref) async {
  final historyItems = await ref.watch(historyListProvider.future);
  final menuRepo = ref.watch(menuRepositoryProvider);

  final results = <RichOrderHistory>[];
  for (final history in historyItems) {
    final mainResult = await menuRepo.getMenuById(history.mainItemId);
    final mainItem = switch (mainResult) {
      Success(:final data) => data,
      Failure() => null,
    };
    if (mainItem == null) continue;

    final sideItem = history.sideItemId != null
        ? switch (await menuRepo.getMenuById(history.sideItemId!)) {
            Success(:final data) => data,
            Failure() => null,
          }
        : null;

    final drinkItem = history.drinkItemId != null
        ? switch (await menuRepo.getMenuById(history.drinkItemId!)) {
            Success(:final data) => data,
            Failure() => null,
          }
        : null;

    results.add(RichOrderHistory(
      history: history,
      mainItem: mainItem,
      sideItem: sideItem,
      drinkItem: drinkItem,
    ));
  }
  return results;
}
