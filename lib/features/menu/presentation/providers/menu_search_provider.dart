import 'package:riverpod_annotation/riverpod_annotation.dart';

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
