import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/data_update_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(dataUpdateNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '데이터 정보',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.storage,
                    label: '데이터 버전',
                    value: 'v${updateState.localVersion}',
                  ),
                  const Divider(height: 24),
                  if (updateState.message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        updateState.message!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: updateState.status == UpdateStatus.error
                              ? theme.colorScheme.error
                              : updateState.status == UpdateStatus.success
                                  ? theme.colorScheme.primary
                                  : null,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: updateState.status == UpdateStatus.checking ||
                              updateState.status == UpdateStatus.downloading
                          ? null
                          : () => ref
                              .read(dataUpdateNotifierProvider.notifier)
                              .checkAndUpdate(),
                      icon: updateState.status == UpdateStatus.checking ||
                              updateState.status == UpdateStatus.downloading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        updateState.status == UpdateStatus.checking
                            ? '확인 중...'
                            : updateState.status == UpdateStatus.downloading
                                ? '다운로드 중...'
                                : '업데이트 확인',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '앱 정보',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _InfoTile(
                    icon: Icons.info_outline,
                    label: '버전',
                    value: '1.0.0',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
