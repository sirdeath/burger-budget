import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/errors/result.dart';
import '../../domain/repositories/data_update_repository.dart';
import '../datasources/remote_manifest_datasource.dart';

class DataUpdateRepositoryImpl implements DataUpdateRepository {
  const DataUpdateRepositoryImpl(
    this._remoteDatasource,
    this._dbHelper,
  );

  final RemoteManifestDatasource _remoteDatasource;
  final DatabaseHelper _dbHelper;

  @override
  Future<int> getLocalVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.dbVersionKey) ?? 0;
  }

  @override
  Future<Result<bool>> checkForUpdate() async {
    try {
      final manifest = await _remoteDatasource.fetchManifest();
      final localVersion = await getLocalVersion();
      return Success(manifest.version > localVersion);
    } on Exception catch (e) {
      return Failure('업데이트 확인 실패', e);
    }
  }

  @override
  Future<Result<void>> downloadAndApply() async {
    try {
      final manifest = await _remoteDatasource.fetchManifest();
      final localVersion = await getLocalVersion();

      if (manifest.version <= localVersion) {
        return const Success(null);
      }

      final tempPath = await _remoteDatasource.downloadDatabase(
        manifest.dbUrl,
      );

      final isValid = _remoteDatasource.verifySha256(
        tempPath,
        manifest.sha256Hash,
      );
      if (!isValid) {
        await File(tempPath).delete();
        return const Failure('SHA-256 검증 실패');
      }

      await _dbHelper.replaceDatabase(tempPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.dbVersionKey, manifest.version);

      return const Success(null);
    } on Exception catch (e) {
      return Failure('데이터 업데이트 실패', e);
    }
  }
}
