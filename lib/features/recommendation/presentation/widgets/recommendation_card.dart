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
    this.deliveryMode = false,
  });

  final Recommendation recommendation;
  final int rank;
  final int? budget;
  final VoidCallback? onTap;
  final bool deliveryMode;

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

    final displayPrice = deliveryMode
        ? (recommendation.totalDeliveryPrice ??
            recommendation.totalPrice)
        : recommendation.totalPrice;
    final remaining =
        budget != null ? budget! - displayPrice : 0;
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
                          if (recommendation.isSet)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme
                                    .colorScheme.tertiaryContainer,
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: Text(
                                '세트',
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: theme.colorScheme
                                      .onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (recommendation.isSet)
                            const SizedBox(width: 4),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            if (recommendation.isSet)
                              _IncludedLabel(
                                side: main.includesSide,
                                drink: main.includesDrink,
                                theme: theme,
                              ),
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
                            if (recommendation.dessertItem != null)
                              _SubItemChip(
                                label: recommendation.dessertItem!.name,
                                price: recommendation.dessertItem!.price,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xs,
                              children: [
                                if (recommendation.totalCalories != null)
                                  Text(
                                    '${recommendation.totalCalories} kcal',
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                if (deliveryMode &&
                                    recommendation.totalPriceDiff !=
                                        null &&
                                    recommendation.totalPriceDiff! > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme.errorContainer,
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '매장가 대비 +${formatKRW(recommendation.totalPriceDiff!)}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: theme.colorScheme
                                            .onErrorContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatKRW(displayPrice),
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
                                    end: budget! - displayPrice,
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
                      if (main.priceUpdatedAt != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _PriceDateLabel(
                            date: main.priceUpdatedAt!,
                            theme: theme,
                          ),
                        ),
                      ],
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

class _IncludedLabel extends StatelessWidget {
  const _IncludedLabel({
    required this.side,
    required this.drink,
    required this.theme,
  });

  final bool side;
  final bool drink;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (side) '사이드',
      if (drink) '음료',
    ];
    if (parts.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${parts.join('+')} 포함',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onTertiaryContainer,
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

class _PriceDateLabel extends StatelessWidget {
  const _PriceDateLabel({
    required this.date,
    required this.theme,
  });

  final String date;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(date);
    final isStale = parsed != null &&
        DateTime.now().difference(parsed).inDays > 30;

    return Text(
      isStale ? '\u26A0 $date 기준' : '$date 기준',
      style: theme.textTheme.labelSmall?.copyWith(
        color: isStale
            ? theme.colorScheme.error
            : theme.colorScheme.outline,
        fontSize: 10,
      ),
    );
  }
}

