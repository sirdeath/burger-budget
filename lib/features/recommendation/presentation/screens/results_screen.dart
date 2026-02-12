import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('오류: $error'),
              ),
              data: (recommendations) {
                if (recommendations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        const Text('예산 내 추천 가능한 메뉴가 없습니다'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    return RecommendationCard(
                      recommendation: recommendations[index],
                      rank: index + 1,
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
