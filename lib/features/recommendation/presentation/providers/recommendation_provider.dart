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
  SortMode build() => SortMode.recommended;

  void setSortMode(SortMode mode) {
    state = mode;
  }
}

@riverpod
class PersonCountState extends _$PersonCountState {
  @override
  int build() => 1;

  void setCount(int count) {
    state = count.clamp(1, 4);
  }
}

@riverpod
class DeliveryModeState extends _$DeliveryModeState {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void setMode({required bool isDelivery}) => state = isDelivery;
}

enum MenuTypeFilter { all, setOnly, singleOnly }

@riverpod
class SelectedMenuTypeFilter extends _$SelectedMenuTypeFilter {
  @override
  MenuTypeFilter build() => MenuTypeFilter.all;

  void setFilter(MenuTypeFilter filter) {
    state = filter;
  }
}

@riverpod
class DisplayedCountState extends _$DisplayedCountState {
  @override
  int build() => AppConstants.maxRecommendations;

  void loadMore(int totalCount) {
    if (state >= totalCount) return;
    state = state + AppConstants.maxRecommendations;
  }

  void reset() {
    state = AppConstants.maxRecommendations;
  }
}

@riverpod
Future<List<Recommendation>> recommendations(
  Ref ref, {
  required int budget,
  required List<String> franchises,
  int personCount = 1,
}) async {
  final sort = ref.watch(selectedSortModeProvider);
  final deliveryMode = ref.watch(deliveryModeStateProvider);
  final repository = ref.watch(recommendationRepositoryProvider);
  final result = await repository.getRecommendations(
    budget: budget,
    franchises: franchises,
    sort: sort,
    personCount: personCount,
    deliveryMode: deliveryMode,
  );
  return switch (result) {
    Success(data: final items) => items,
    Failure(message: final msg) => throw Exception(msg),
  };
}
