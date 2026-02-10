import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/recommendation.dart';

part 'recommendation_provider.g.dart';

@riverpod
class BudgetState extends _$BudgetState {
  @override
  int? build() => null;

  void setBudget(int? value) {
    state = value;
  }
}

@riverpod
class SelectedFranchises extends _$SelectedFranchises {
  @override
  Set<String> build() => {};

  bool get isAllSelected =>
      state.length == AppConstants.franchiseCodes.length;

  void toggle(String code) {
    final next = Set<String>.from(state);
    if (next.contains(code)) {
      next.remove(code);
    } else {
      next.add(code);
    }
    state = next;
  }

  void toggleAll() {
    if (isAllSelected) {
      state = {};
    } else {
      state = Set<String>.from(AppConstants.franchiseCodes);
    }
  }
}

@riverpod
class SelectedSortMode extends _$SelectedSortMode {
  @override
  SortMode build() => SortMode.bestValue;

  void setSortMode(SortMode mode) {
    state = mode;
  }
}

@riverpod
Future<List<Recommendation>> recommendations(
  Ref ref, {
  required int budget,
  required List<String> franchises,
  SortMode sort = SortMode.bestValue,
}) async {
  final repository = ref.watch(recommendationRepositoryProvider);
  final result = await repository.getRecommendations(
    budget: budget,
    franchises: franchises,
    sort: sort,
  );
  return switch (result) {
    Success(data: final items) => items,
    Failure(message: final msg) => throw Exception(msg),
  };
}
