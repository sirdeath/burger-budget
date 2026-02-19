import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

enum ErrorType {
  network,
  database,
  general,
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.errorType = ErrorType.general,
    this.onRetry,
  });

  final String message;
  final ErrorType errorType;
  final VoidCallback? onRetry;

  factory ErrorView.fromError({
    Key? key,
    required Object error,
    VoidCallback? onRetry,
  }) {
    final msg = error.toString();
    ErrorType type;
    if (msg.contains('SocketException') ||
        msg.contains('HttpException') ||
        msg.contains('NetworkException') ||
        msg.contains('timeout')) {
      type = ErrorType.network;
    } else if (msg.contains('DatabaseException') ||
        msg.contains('SqliteException')) {
      type = ErrorType.database;
    } else {
      type = ErrorType.general;
    }
    return ErrorView(
      key: key,
      message: msg,
      errorType: type,
      onRetry: onRetry,
    );
  }

  IconData get _icon => switch (errorType) {
        ErrorType.network => Icons.wifi_off,
        ErrorType.database => Icons.storage,
        ErrorType.general => Icons.error_outline,
      };

  String get _title => switch (errorType) {
        ErrorType.network => '네트워크에 연결할 수 없습니다',
        ErrorType.database => '데이터를 불러올 수 없습니다',
        ErrorType.general => '오류가 발생했습니다',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
