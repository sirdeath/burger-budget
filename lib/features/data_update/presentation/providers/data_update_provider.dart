import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/result.dart';

part 'data_update_provider.g.dart';

enum UpdateStatus { idle, checking, downloading, success, error }

@riverpod
class DataUpdateNotifier extends _$DataUpdateNotifier {
  @override
  ({UpdateStatus status, String? message, int localVersion}) build() {
    _loadVersion();
    return (status: UpdateStatus.idle, message: null, localVersion: 0);
  }

  Future<void> _loadVersion() async {
    final repo = ref.read(dataUpdateRepositoryProvider);
    final version = await repo.getLocalVersion();
    state = (
      status: state.status,
      message: state.message,
      localVersion: version,
    );
  }

  Future<void> checkAndUpdate() async {
    final repo = ref.read(dataUpdateRepositoryProvider);

    state = (
      status: UpdateStatus.checking,
      message: '업데이트 확인 중...',
      localVersion: state.localVersion,
    );

    final checkResult = await repo.checkForUpdate();
    switch (checkResult) {
      case Success(data: final hasUpdate):
        if (!hasUpdate) {
          state = (
            status: UpdateStatus.idle,
            message: '최신 데이터입니다',
            localVersion: state.localVersion,
          );
          return;
        }
      case Failure(message: final msg):
        state = (
          status: UpdateStatus.error,
          message: msg,
          localVersion: state.localVersion,
        );
        return;
    }

    state = (
      status: UpdateStatus.downloading,
      message: '데이터 다운로드 중...',
      localVersion: state.localVersion,
    );

    final downloadResult = await repo.downloadAndApply();
    switch (downloadResult) {
      case Success():
        final newVersion = await repo.getLocalVersion();
        state = (
          status: UpdateStatus.success,
          message: '업데이트 완료! (v$newVersion)',
          localVersion: newVersion,
        );
      case Failure(message: final msg):
        state = (
          status: UpdateStatus.error,
          message: msg,
          localVersion: state.localVersion,
        );
    }
  }
}
