import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/menu_type_display.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../app_shell/presentation/providers/navigation_provider.dart';
import '../../../menu/presentation/screens/menu_detail_screen.dart';
import '../../domain/entities/rich_order_history.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(richHistoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 이력'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: '전체 삭제',
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
                return RepaintBoundary(
                  child: _StatsCard(
                    totalOrders: totalOrders,
                    totalSpent: totalSpent,
                  ),
                );
              }
              final order = history[index - 1];
              return RepaintBoundary(
                child: Dismissible(
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
                child: _RichHistoryCard(
                  order: order,
                  onTap: () => _showDetail(context, order),
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
          onRetry: () => ref.invalidate(richHistoryListProvider),
        ),
      ),
    );
  }

  Future<void> _showClearAllDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
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

  void _showDetail(BuildContext context, RichOrderHistory order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MenuDetailScreen(
        menuItem: order.mainItem,
        sideItem: order.sideItem,
        drinkItem: order.drinkItem,
      ),
    );
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

class _RichHistoryCard extends StatelessWidget {
  const _RichHistoryCard({
    required this.order,
    required this.onTap,
    required this.onDelete,
  });

  final RichOrderHistory order;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final franchise = AppConstants.franchiseNames[
        order.mainItem.franchise] ?? order.mainItem.franchise;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Franchise icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  AppConstants.franchiseEmojis[
                      order.mainItem.franchise] ?? '🍔',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.mainItem.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    franchise,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (order.sideItem != null) ...[
                    _ItemRow(
                      icon: MenuTypeDisplay.icon(
                        order.sideItem!.type,
                      ),
                      label: order.sideItem!.name,
                      price: order.sideItem!.price,
                      theme: theme,
                    ),
                    const SizedBox(height: 2),
                  ],
                  if (order.drinkItem != null) ...[
                    _ItemRow(
                      icon: MenuTypeDisplay.icon(
                        order.drinkItem!.type,
                      ),
                      label: order.drinkItem!.name,
                      price: order.drinkItem!.price,
                      theme: theme,
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
              tooltip: '삭제',
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.icon,
    required this.label,
    required this.price,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final int price;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.outline),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          formatKRW(price),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
