import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/errors/result.dart';
import '../../data/datasources/recommendation_datasource.dart';
import '../../data/repositories/recommendation_repository_impl.dart';
import '../../domain/entities/recommendation.dart';

part 'recommendation_provider.g.dart';

@riverpod
RecommendationRepositoryImpl recommendationRepository(
  RecommendationRepositoryRef ref,
) {
  final datasource = RecommendationDatasource(DatabaseHelper.instance);
  return RecommendationRepositoryImpl(datasource);
}

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
  RecommendationsRef ref, {
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
