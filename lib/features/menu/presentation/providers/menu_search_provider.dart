import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/menu_item.dart';

part 'menu_search_provider.g.dart';

@riverpod
class MenuSearchQuery extends _$MenuSearchQuery {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }
}

@riverpod
Future<List<MenuItem>> menuSearchResults(Ref ref) async {
  final query = ref.watch(menuSearchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repository = ref.watch(menuRepositoryProvider);
  final result = await repository.searchMenus(query.trim());
  return switch (result) {
    Success(:final data) => data,
    Failure(:final message) => throw Exception(message),
  };
}

@riverpod
class SelectedCatalogFranchise extends _$SelectedCatalogFranchise {
  @override
  String build() => 'mcd';

  void select(String franchise) {
    state = franchise;
  }
}

@riverpod
Future<Map<MenuType, List<MenuItem>>> menuCatalog(Ref ref) async {
  final franchise = ref.watch(selectedCatalogFranchiseProvider);
  final repository = ref.watch(menuRepositoryProvider);
  final result =
      await repository.getMenusByFranchise([franchise]);
  final items = switch (result) {
    Success(:final data) => data,
    Failure(:final message) => throw Exception(message),
  };

  final grouped = <MenuType, List<MenuItem>>{};
  // 순서: 세트 → 버거 → 사이드 → 음료 → 디저트
  for (final type in [
    MenuType.set_,
    MenuType.burger,
    MenuType.side,
    MenuType.drink,
    MenuType.dessert,
  ]) {
    final list = items.where((i) => i.type == type).toList();
    if (list.isNotEmpty) {
      grouped[type] = list;
    }
  }
  return grouped;
}

// ── 메뉴판 검색/정렬 ──

enum MenuBoardSortMode { popular, priceAsc, priceDesc, nameAsc }

@riverpod
class MenuBoardQuery extends _$MenuBoardQuery {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }
}

@riverpod
class MenuBoardSort extends _$MenuBoardSort {
  @override
  MenuBoardSortMode build() => MenuBoardSortMode.popular;

  void select(MenuBoardSortMode mode) {
    state = mode;
  }
}

// ── 카테고리별 비교 ──

@riverpod
class SelectedCompareType extends _$SelectedCompareType {
  @override
  MenuType build() => MenuType.set_;

  void select(MenuType type) {
    state = type;
  }
}

@riverpod
Future<List<MenuItem>> categoryCompare(Ref ref) async {
  final type = ref.watch(selectedCompareTypeProvider);
  final repository = ref.watch(menuRepositoryProvider);
  final result = await repository.getMenusByFranchise(
    AppConstants.franchiseCodes,
  );
  final items = switch (result) {
    Success(:final data) => data,
    Failure(:final message) => throw Exception(message),
  };

  return items.where((i) => i.type == type).toList();
}
