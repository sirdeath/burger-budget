import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/recommendation.dart';

part 'recommendation_provider.g.dart';

const _keyBudget = 'home_budget';
const _keyPersonCount = 'home_person_count';
const _keyDeliveryMode = 'home_delivery_mode';
const _keyFranchises = 'home_franchises';

@riverpod
class BudgetState extends _$BudgetState {
  @override
  int? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_keyBudget);
    if (saved != null && state == null) {
      state = saved;
    }
  }

  void setBudget(int? value) {
    state = value;
    _save(value);
  }

  Future<void> _save(int? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setInt(_keyBudget, value);
    } else {
      await prefs.remove(_keyBudget);
    }
  }
}

@riverpod
class SelectedFranchises extends _$SelectedFranchises {
  @override
  Set<String> build() {
    _load();
    return {};
  }

  bool get isAllSelected =>
      state.length == AppConstants.franchiseCodes.length;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_keyFranchises);
    if (saved != null && state.isEmpty) {
      state = saved.toSet();
    }
  }

  void toggle(String code) {
    final next = Set<String>.from(state);
    if (next.contains(code)) {
      next.remove(code);
    } else {
      next.add(code);
    }
    state = next;
    _save(next);
  }

  void toggleAll() {
    if (isAllSelected) {
      state = {};
      _save({});
    } else {
      final all = Set<String>.from(AppConstants.franchiseCodes);
      state = all;
      _save(all);
    }
  }

  Future<void> _save(Set<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFranchises, value.toList());
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
  int build() {
    _load();
    return 1;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_keyPersonCount);
    if (saved != null && state == 1) {
      state = saved.clamp(1, 4);
    }
  }

  void setCount(int count) {
    final clamped = count.clamp(1, 4);
    state = clamped;
    _save(clamped);
  }

  Future<void> _save(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPersonCount, value);
  }
}

@riverpod
class DeliveryModeState extends _$DeliveryModeState {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_keyDeliveryMode);
    if (saved != null) {
      state = saved;
    }
  }

  void toggle() {
    state = !state;
    _save(state);
  }

  void setMode({required bool isDelivery}) {
    state = isDelivery;
    _save(isDelivery);
  }

  Future<void> _save(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDeliveryMode, value);
  }
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
class DeliveryFeeState extends _$DeliveryFeeState {
  @override
  int build() => 0;

  void setFee(int fee) {
    state = fee.clamp(0, 99000);
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
