import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_format.dart';
import '../../domain/entities/recommendation.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.rank,
    this.onTap,
  });

  final Recommendation recommendation;
  final int rank;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final main = recommendation.mainItem;
    final franchiseName =
        AppConstants.franchiseNames[main.franchise] ?? main.franchise;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      '$rank',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
              const SizedBox(height: 8),
              if (recommendation.sideItem != null ||
                  recommendation.drinkItem != null)
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Wrap(
                    spacing: 8,
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
              const SizedBox(height: 8),
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
                  Text(
                    formatKRW(recommendation.totalPrice),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
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
}

class _SubItemChip extends StatelessWidget {
  const _SubItemChip({required this.label, required this.price});

  final String label;
  final int price;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        '+ $label (${formatKRW(price)})',
        style: Theme.of(context).textTheme.labelSmall,
      ),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
