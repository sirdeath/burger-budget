import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../app_shell/presentation/providers/navigation_provider.dart';
import '../../domain/entities/order_history.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 이력'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearAllDialog(context, ref),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long,
              title: '주문 이력이 없습니다',
              description: '추천 결과에서 조합을 선택하면\n이력에 자동으로 기록됩니다.',
              actionLabel: '첫 추천 시작하기',
              actionIcon: Icons.restaurant_menu,
              onAction: () {
                ref
                    .read(navigationIndexProvider.notifier)
                    .setIndex(0);
              },
            );
          }

          // Calculate stats
          final totalOrders = history.length;
          final totalSpent = history.fold<int>(
            0,
            (sum, item) => sum + item.totalPrice,
          );

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: history.length + 1, // +1 for stats card
            itemBuilder: (context, index) {
              if (index == 0) {
                return _StatsCard(
                  totalOrders: totalOrders,
                  totalSpent: totalSpent,
                );
              }
              final order = history[index - 1];
              return Dismissible(
                key: ValueKey(order.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.delete,
                    color:
                        Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                onDismissed: (_) async {
                  await ref
                      .read(historyListProvider.notifier)
                      .remove(order.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('주문 이력에서 삭제했습니다'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: _HistoryCard(
                  order: order,
                  onDelete: () async {
                    await ref
                        .read(historyListProvider.notifier)
                        .remove(order.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('주문 이력에서 삭제했습니다'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(historyListProvider),
        ),
      ),
    );
  }

  Future<void> _showClearAllDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('모든 주문 이력을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(historyListProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 주문 이력을 삭제했습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.totalOrders,
    required this.totalSpent,
  });

  final int totalOrders;
  final int totalSpent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '총 주문 횟수',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$totalOrders회',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '총 지출',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    formatKRW(totalSpent),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.order,
    required this.onDelete,
  });

  final OrderHistory order;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatItemName(order.mainItemId),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (order.sideItemId != null) ...[
                    Text(
                      '사이드: ${_formatItemName(order.sideItemId!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  if (order.drinkItemId != null) ...[
                    Text(
                      '음료: ${_formatItemName(order.drinkItemId!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        formatKRW(order.totalPrice),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        dateFormat.format(order.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatItemName(String itemId) {
    // Convert ID like "mcd_bigmac" to "BigMac"
    // or "bk_whopper_jr" to "Whopper Jr"
    final parts = itemId.split('_');
    if (parts.length > 1) {
      return parts
          .skip(1)
          .map(
            (part) => part[0].toUpperCase() + part.substring(1),
          )
          .join(' ');
    }
    return itemId;
  }
}
