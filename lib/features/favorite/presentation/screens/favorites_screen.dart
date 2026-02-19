import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../app_shell/presentation/providers/navigation_provider.dart';
import '../../domain/entities/favorite.dart';
import '../providers/favorite_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteListProvider);

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
              return _FavoriteCard(
                favorite: favorite,
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
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(favoriteListProvider),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.favorite,
    required this.onDelete,
  });

  final Favorite favorite;
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
            // Favorite icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatItemName(favorite.mainItemId),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (favorite.sideItemId != null) ...[
                    Text(
                      '사이드: ${_formatItemName(favorite.sideItemId!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  if (favorite.drinkItemId != null) ...[
                    Text(
                      '음료: ${_formatItemName(favorite.drinkItemId!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    dateFormat.format(favorite.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
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
