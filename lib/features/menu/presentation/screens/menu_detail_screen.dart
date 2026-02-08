import 'package:flutter/material.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../store_finder/presentation/widgets/find_store_button.dart';
import '../../domain/entities/menu_item.dart';

class MenuDetailScreen extends StatelessWidget {
  const MenuDetailScreen({
    super.key,
    required this.menuItem,
    this.sideItem,
    this.drinkItem,
  });

  final MenuItem menuItem;
  final MenuItem? sideItem;
  final MenuItem? drinkItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildItemSection(context, '메인', menuItem),
                if (sideItem != null) ...[
                  const Divider(height: 32),
                  _buildItemSection(context, '사이드', sideItem!),
                ],
                if (drinkItem != null) ...[
                  const Divider(height: 32),
                  _buildItemSection(context, '음료', drinkItem!),
                ],
                const Divider(height: 32),
                Row(
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
                const SizedBox(height: 24),
                Center(
                  child: FindStoreButton(
                    franchiseCode: menuItem.franchise,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  int get _totalPrice =>
      menuItem.price +
      (sideItem?.price ?? 0) +
      (drinkItem?.price ?? 0);

  Widget _buildItemSection(
    BuildContext context,
    String label,
    MenuItem item,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatKRW(item.price),
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (item.calories != null)
          _InfoRow(icon: Icons.local_fire_department, text: '${item.calories} kcal'),
        if (item.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 4,
              children: item.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        labelStyle: theme.textTheme.labelSmall,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }
}
