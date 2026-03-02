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
  Future<String> getLocalVersion() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return prefs.getString(AppConstants.dbVersionKey) ??
          AppConstants.seedDbVersion;
    } on TypeError {
      // 기존 int 저장값 → String 마이그레이션
      await prefs.remove(AppConstants.dbVersionKey);
      return AppConstants.seedDbVersion;
    }
  }

  @override
  Future<Result<bool>> checkForUpdate() async {
    try {
      final manifest = await _remoteDatasource.fetchManifest();
      final localVersion = await getLocalVersion();
      return Success(
        _compareVersions(manifest.version, localVersion) > 0,
      );
    } on Exception catch (e) {
      return Failure('업데이트 확인 실패', e);
    }
  }

  @override
  Future<Result<void>> downloadAndApply() async {
    try {
      final manifest = await _remoteDatasource.fetchManifest();
      final localVersion = await getLocalVersion();

      if (_compareVersions(manifest.version, localVersion) <= 0) {
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
      await prefs.setString(
        AppConstants.dbVersionKey,
        manifest.version,
      );

      return const Success(null);
    } on Exception catch (e) {
      return Failure('데이터 업데이트 실패', e);
    }
  }

  static int _compareVersions(String a, String b) {
    final aParts = a.split('.').map(int.parse).toList();
    final bParts = b.split('.').map(int.parse).toList();
    if (aParts[0] != bParts[0]) {
      return aParts[0].compareTo(bParts[0]);
    }
    return aParts[1].compareTo(bParts[1]);
  }
}
