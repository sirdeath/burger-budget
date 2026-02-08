import '../../../../core/errors/result.dart';

abstract class DataUpdateRepository {
  Future<Result<bool>> checkForUpdate();
  Future<Result<void>> downloadAndApply();
  Future<int> getLocalVersion();
}
