import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/menu_type_display.dart';
import '../../../../core/utils/share_format.dart';
import '../../../favorite/presentation/widgets/favorite_button.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../store_finder/presentation/widgets/find_store_button.dart';
import '../../domain/entities/menu_item.dart';

class MenuDetailScreen extends ConsumerWidget {
  const MenuDetailScreen({
    super.key,
    required this.menuItem,
    this.sideItem,
    this.drinkItem,
    this.dessertItem,
  });

  final MenuItem menuItem;
  final MenuItem? sideItem;
  final MenuItem? drinkItem;
  final MenuItem? dessertItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: Row(
                  children: [
                    _FranchiseBadge(
                      franchise: menuItem.franchise,
                      brightness: theme.brightness,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '메뉴 상세',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final text = formatComboForShare(
                          mainItem: menuItem,
                          sideItem: sideItem,
                          drinkItem: drinkItem,
                          dessertItem: dessertItem,
                        );
                        Share.share(text);
                      },
                      icon: const Icon(Icons.share_outlined),
                      tooltip: '공유',
                    ),
                    FavoriteButton(
                      mainItemId: menuItem.id,
                      sideItemId: sideItem?.id,
                      drinkItemId: drinkItem?.id,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Menu sections
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Column(
                  children: [
                    _MenuItemCard(
                      label: MenuTypeDisplay.label(menuItem.type),
                      icon: MenuTypeDisplay.icon(menuItem.type),
                      item: menuItem,
                    ),
                    if (sideItem != null)
                      _MenuItemCard(
                        label: MenuTypeDisplay.label(sideItem!.type),
                        icon: MenuTypeDisplay.icon(sideItem!.type),
                        item: sideItem!,
                      ),
                    if (drinkItem != null)
                      _MenuItemCard(
                        label: MenuTypeDisplay.label(drinkItem!.type),
                        icon: MenuTypeDisplay.icon(drinkItem!.type),
                        item: drinkItem!,
                      ),
                    if (dessertItem != null)
                      _MenuItemCard(
                        label: MenuTypeDisplay.label(dessertItem!.type),
                        icon: MenuTypeDisplay.icon(dessertItem!.type),
                        item: dessertItem!,
                      ),
                  ],
                ),
              ),
              // Total price
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 가격',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatKRW(_totalPrice),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    FindStoreButton(
                      franchiseCode: menuItem.franchise,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => _openFranchiseSite(
                        menuItem.franchise,
                      ),
                      icon: const Icon(
                        Icons.open_in_new,
                        size: 18,
                      ),
                      label: const Text('공식 사이트'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Add to history button
              Center(
                child: FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(historyListProvider.notifier)
                        .addFromRecommendation(
                          mainItemId: menuItem.id,
                          sideItemId: sideItem?.id,
                          drinkItemId: drinkItem?.id,
                          totalPrice: _totalPrice,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('주문 이력에 추가했습니다'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('이 조합 선택'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openFranchiseSite(String franchise) async {
    final urlString =
        AppConstants.franchiseUrls[franchise];
    if (urlString == null) return;
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  int get _totalPrice =>
      menuItem.price +
      (sideItem?.price ?? 0) +
      (drinkItem?.price ?? 0) +
      (dessertItem?.price ?? 0);
}

class _FranchiseBadge extends StatelessWidget {
  const _FranchiseBadge({
    required this.franchise,
    required this.brightness,
  });

  final String franchise;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.franchiseColor(franchise, brightness);
    final name = AppConstants.franchiseNames[franchise] ?? franchise;
    final emoji = AppConstants.franchiseEmojis[franchise] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$emoji $name',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.label,
    required this.icon,
    required this.item,
  });

  final String label;
  final IconData icon;
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                icon,
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
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        formatKRW(item.price),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (item.calories != null)
                        _InfoChip(
                          icon: Icons.local_fire_department,
                          text: '${item.calories} kcal',
                        ),
                      if (item.calories != null && item.tags.isNotEmpty)
                        const SizedBox(width: AppSpacing.xs),
                      ...item.tags.map(
                        (tag) => Padding(
                          padding: const EdgeInsets.only(
                            right: AppSpacing.xs,
                          ),
                          child: _InfoChip(text: tag),
                        ),
                      ),
                    ],
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({this.icon, required this.text});

  final IconData? icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: 2),
          ],
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
