import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/errors/result.dart';
import '../../data/datasources/menu_local_datasource.dart';
import '../../data/repositories/menu_repository_impl.dart';
import '../../domain/entities/menu_item.dart';

part 'menu_provider.g.dart';

@riverpod
MenuRepositoryImpl menuRepository(MenuRepositoryRef ref) {
  final datasource = MenuLocalDatasource(DatabaseHelper.instance);
  return MenuRepositoryImpl(datasource);
}

@riverpod
Future<MenuItem> menuDetail(MenuDetailRef ref, String id) async {
  final repository = ref.watch(menuRepositoryProvider);
  final result = await repository.getMenuById(id);
  return switch (result) {
    Success(data: final item) => item,
    Failure(message: final msg) => throw Exception(msg),
  };
}
