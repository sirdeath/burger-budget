import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_format.dart';
import '../../domain/entities/recommendation.dart';
import '../../../menu/presentation/screens/menu_detail_screen.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/recommendation_card.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({
    super.key,
    required this.budget,
    required this.franchises,
  });

  final int budget;
  final List<String> franchises;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortMode = ref.watch(selectedSortModeProvider);
    final asyncRecommendations = ref.watch(
      recommendationsProvider(
        budget: budget,
        franchises: franchises,
        sort: sortMode,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('추천 결과 (${formatKRW(budget)})'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: SegmentedButton<SortMode>(
              segments: const [
                ButtonSegment(
                  value: SortMode.bestValue,
                  label: Text('가성비 순'),
                  icon: Icon(Icons.trending_up),
                ),
                ButtonSegment(
                  value: SortMode.lowestCalories,
                  label: Text('칼로리 낮은 순'),
                  icon: Icon(Icons.local_fire_department),
                ),
              ],
              selected: {sortMode},
              onSelectionChanged: (selected) {
                ref
                    .read(selectedSortModeProvider.notifier)
                    .setSortMode(selected.first);
              },
            ),
          ),
          Expanded(
            child: asyncRecommendations.when(
              loading: () => const _SkeletonList(),
              error: (error, _) => _ErrorView(
                message: '$error',
                onRetry: () => ref.invalidate(
                  recommendationsProvider(
                    budget: budget,
                    franchises: franchises,
                    sort: sortMode,
                  ),
                ),
              ),
              data: (recommendations) {
                if (recommendations.isEmpty) {
                  return _EmptyView(budget: budget);
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    return RecommendationCard(
                      recommendation: recommendations[index],
                      rank: index + 1,
                      budget: budget,
                      onTap: () => _showDetail(
                        context,
                        recommendations[index],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Recommendation recommendation) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MenuDetailScreen(
        menuItem: recommendation.mainItem,
        sideItem: recommendation.sideItem,
        drinkItem: recommendation.drinkItem,
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      itemCount: 3,
      itemBuilder: (_, _) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholderColor = theme.colorScheme.surfaceContainerHighest;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: placeholderColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 64,
                  height: 24,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 60,
                  height: 14,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.budget});

  final int budget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.no_meals,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '추천 가능한 메뉴가 없습니다',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${formatKRW(budget)} 예산으로는 조합을 찾지 못했어요.\n'
              '예산을 올리거나 다른 프랜차이즈를 선택해 보세요.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('예산 조정하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '오류가 발생했습니다',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
