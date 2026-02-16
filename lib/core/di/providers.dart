import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/data_update/data/datasources/remote_manifest_datasource.dart';
import '../../features/data_update/data/repositories/data_update_repository_impl.dart';
import '../../features/data_update/domain/repositories/data_update_repository.dart';
import '../../features/favorite/data/datasources/favorite_local_datasource.dart';
import '../../features/favorite/data/repositories/favorite_repository_impl.dart';
import '../../features/favorite/domain/repositories/favorite_repository.dart';
import '../../features/history/data/datasources/history_local_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/menu/data/datasources/menu_local_datasource.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/recommendation/data/datasources/recommendation_datasource.dart';
import '../../features/recommendation/data/repositories/recommendation_repository_impl.dart';
import '../../features/recommendation/domain/repositories/recommendation_repository.dart';
import '../database/database_helper.dart';
import '../database/user_database_helper.dart';

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

@riverpod
FavoriteRepository favoriteRepository(Ref ref) {
  final datasource = FavoriteLocalDatasource(UserDatabaseHelper.instance);
  return FavoriteRepositoryImpl(datasource);
}

@riverpod
HistoryRepository historyRepository(Ref ref) {
  final datasource = HistoryLocalDatasource(UserDatabaseHelper.instance);
  return HistoryRepositoryImpl(datasource);
}
