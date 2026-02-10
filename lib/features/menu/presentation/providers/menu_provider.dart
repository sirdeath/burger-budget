import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/menu_item.dart';

part 'menu_provider.g.dart';

@riverpod
Future<MenuItem> menuDetail(Ref ref, String id) async {
  final repository = ref.watch(menuRepositoryProvider);
  final result = await repository.getMenuById(id);
  return switch (result) {
    Success(data: final item) => item,
    Failure(message: final msg) => throw Exception(msg),
  };
}
