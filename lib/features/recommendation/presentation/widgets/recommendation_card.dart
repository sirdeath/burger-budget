import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_format.dart';
import '../../domain/entities/recommendation.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.rank,
    this.budget,
    this.onTap,
  });

  final Recommendation recommendation;
  final int rank;
  final int? budget;
  final VoidCallback? onTap;

  bool get _isTop => rank == 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final main = recommendation.mainItem;
    final franchiseName =
        AppConstants.franchiseNames[main.franchise] ?? main.franchise;
    final franchiseColor = AppTheme.franchiseColor(
      main.franchise,
      theme.brightness,
    );

    final remaining = budget != null ? budget! - recommendation.totalPrice : 0;
    final semanticLabel = '$rank위 ${main.name}, '
        '$franchiseName, '
        '${formatKRW(recommendation.totalPrice)}'
        '${budget != null ? ', 잔액 ${formatKRW(remaining)}' : ''}';

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Card(
      shape: _isTop
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: franchiseColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _RankBadge(
                            rank: rank,
                            isTop: _isTop,
                            theme: theme,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              main.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              franchiseName,
                              style: theme.textTheme.labelSmall,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (recommendation.sideItem != null ||
                          recommendation.drinkItem != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 36),
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
                            children: [
                              if (recommendation.sideItem != null)
                                _SubItemChip(
                                  label: recommendation.sideItem!.name,
                                  price: recommendation.sideItem!.price,
                                ),
                              if (recommendation.drinkItem != null)
                                _SubItemChip(
                                  label: recommendation.drinkItem!.name,
                                  price: recommendation.drinkItem!.price,
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (recommendation.totalCalories != null)
                            Text(
                              '${recommendation.totalCalories} kcal',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatKRW(recommendation.totalPrice),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              if (budget != null) ...[
                                const SizedBox(width: AppSpacing.sm),
                                TweenAnimationBuilder<int>(
                                  tween: IntTween(
                                    begin: 0,
                                    end: budget! - recommendation.totalPrice,
                                  ),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, _) => Text(
                                    '(잔액 ${formatKRW(value)})',
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    required this.isTop,
    required this.theme,
  });

  final int rank;
  final bool isTop;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (isTop) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$rank',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 14,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Text(
        '$rank',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SubItemChip extends StatelessWidget {
  const _SubItemChip({required this.label, required this.price});

  final String label;
  final int price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '+ $label (${formatKRW(price)})',
        style: theme.textTheme.labelSmall,
      ),
    );
  }
}
