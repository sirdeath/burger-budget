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
import '../../domain/entities/rich_favorite.dart';
import '../providers/favorite_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(richFavoriteListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기'),
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: '즐겨찾기가 비어있습니다',
              description: '추천 결과에서 마음에 드는 조합을\n즐겨찾기에 추가해보세요.',
              actionLabel: '추천받으러 가기',
              actionIcon: Icons.restaurant_menu,
              onAction: () {
                ref
                    .read(navigationIndexProvider.notifier)
                    .setIndex(0);
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return RepaintBoundary(
                child: Dismissible(
                key: ValueKey(favorite.id),
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
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                onDismissed: (_) async {
                  await ref
                      .read(favoriteListProvider.notifier)
                      .remove(favorite.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('즐겨찾기에서 제거했습니다'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: _RichFavoriteCard(
                  favorite: favorite,
                  onTap: () => _showDetail(context, favorite),
                  onDelete: () async {
                    await ref
                        .read(favoriteListProvider.notifier)
                        .remove(favorite.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('즐겨찾기에서 제거했습니다'),
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
          onRetry: () => ref.invalidate(richFavoriteListProvider),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, RichFavorite favorite) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MenuDetailScreen(
        menuItem: favorite.mainItem,
        sideItem: favorite.sideItem,
        drinkItem: favorite.drinkItem,
      ),
    );
  }
}

class _RichFavoriteCard extends StatelessWidget {
  const _RichFavoriteCard({
    required this.favorite,
    required this.onTap,
    required this.onDelete,
  });

  final RichFavorite favorite;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final franchise = AppConstants.franchiseNames[
        favorite.mainItem.franchise] ?? favorite.mainItem.franchise;

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
            // Favorite icon with franchise emoji
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  AppConstants.franchiseEmojis[
                      favorite.mainItem.franchise] ?? '🍔',
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          favorite.mainItem.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    franchise,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (favorite.sideItem != null) ...[
                    _ItemRow(
                      icon: MenuTypeDisplay.icon(
                        favorite.sideItem!.type,
                      ),
                      label: favorite.sideItem!.name,
                      price: favorite.sideItem!.price,
                      theme: theme,
                    ),
                    const SizedBox(height: 2),
                  ],
                  if (favorite.drinkItem != null) ...[
                    _ItemRow(
                      icon: MenuTypeDisplay.icon(
                        favorite.drinkItem!.type,
                      ),
                      label: favorite.drinkItem!.name,
                      price: favorite.drinkItem!.price,
                      theme: theme,
                    ),
                    const SizedBox(height: 2),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        formatKRW(favorite.totalPrice),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        dateFormat.format(favorite.createdAt),
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
