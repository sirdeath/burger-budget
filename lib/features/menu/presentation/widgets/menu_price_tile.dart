import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/menu_type_display.dart';
import '../../domain/entities/menu_item.dart';
import '../screens/menu_detail_screen.dart';

class MenuPriceTile extends StatelessWidget {
  const MenuPriceTile({
    super.key,
    required this.item,
    this.showFranchise = false,
  });

  final MenuItem item;
  final bool showFranchise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diff = item.priceDiff;
    final hasDelivery = item.deliveryPrice != null;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 3,
      ),
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  MenuTypeDisplay.icon(item.type),
                  color:
                      theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (showFranchise)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 2,
                        ),
                        child: _FranchiseBadge(
                          franchise: item.franchise,
                          brightness: theme.brightness,
                        ),
                      ),
                    Text(
                      item.name,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.type == MenuType.set_ &&
                        (item.includesSide ||
                            item.includesDrink))
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 2),
                        child: Text(
                          _setIncludes,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(
                            color:
                                theme.colorScheme.outline,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatKRW(item.price),
                    style:
                        theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasDelivery)
                    Text(
                      '배달 ${formatKRW(item.deliveryPrice!)}'
                      '${diff != null && diff > 0 ? ' (+${formatKRW(diff)})' : ''}',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(
                        color: diff != null && diff > 0
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline,
                      ),
                    )
                  else
                    Text(
                      '매장전용',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _setIncludes {
    final parts = <String>[];
    if (item.includesSide) parts.add('사이드');
    if (item.includesDrink) parts.add('음료');
    return '${parts.join('+')} 포함';
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: MenuDetailScreen(menuItem: item),
      ),
    );
  }
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
    final color =
        AppTheme.franchiseColor(franchise, brightness);
    final name =
        AppConstants.franchiseNames[franchise] ?? franchise;
    final emoji =
        AppConstants.franchiseEmojis[franchise] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '$emoji $name',
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
