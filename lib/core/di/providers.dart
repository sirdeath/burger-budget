import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/data_update/data/datasources/remote_manifest_datasource.dart';
import '../../features/data_update/data/repositories/data_update_repository_impl.dart';
import '../../features/data_update/domain/repositories/data_update_repository.dart';
import '../../features/menu/data/datasources/menu_local_datasource.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/recommendation/data/datasources/recommendation_datasource.dart';
import '../../features/recommendation/data/repositories/recommendation_repository_impl.dart';
import '../../features/recommendation/domain/repositories/recommendation_repository.dart';
import '../database/database_helper.dart';

part 'providers.g.dart';

@riverpod
MenuRepository menuRepository(Ref ref) {
  final datasource = MenuLocalDatasource(DatabaseHelper.instance);
  return MenuRepositoryImpl(datasource);
}

@riverpod
RecommendationRepository recommendationRepository(Ref ref) {
  final datasource = RecommendationDatasource(DatabaseHelper.instance);
  return RecommendationRepositoryImpl(datasource);
}

@riverpod
DataUpdateRepository dataUpdateRepository(Ref ref) {
  final remoteDatasource = RemoteManifestDatasource();
  return DataUpdateRepositoryImpl(remoteDatasource, DatabaseHelper.instance);
}
