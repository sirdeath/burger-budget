import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/share_format.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/skeleton_card.dart';
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
        actions: [
          if (asyncRecommendations.asData?.value.isNotEmpty ?? false)
            IconButton(
              onPressed: () {
                final text = formatResultsForShare(
                  budget: budget,
                  recommendations: asyncRecommendations.asData!.value,
                );
                Share.share(text);
              },
              icon: const Icon(Icons.share_outlined),
              tooltip: '결과 공유',
            ),
        ],
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
              loading: () => ListView.builder(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                itemCount: 3,
                itemBuilder: (_, _) => const SkeletonCard(),
              ),
              error: (error, _) => ErrorView(
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
                  return EmptyState(
                    icon: Icons.no_meals,
                    title: '추천 가능한 메뉴가 없습니다',
                    description:
                        '${formatKRW(budget)} 예산으로는 조합을 찾지 못했어요.\n'
                        '예산을 올리거나 다른 프랜차이즈를 선택해 보세요.',
                    actionLabel: '예산 조정하기',
                    onAction: () => Navigator.pop(context),
                  );
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _StaggeredCardList(
                    key: ValueKey(sortMode),
                    recommendations: recommendations,
                    budget: budget,
                    onTap: (r) => _showDetail(context, r),
                  ),
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

class _StaggeredCardList extends StatefulWidget {
  const _StaggeredCardList({
    super.key,
    required this.recommendations,
    required this.budget,
    required this.onTap,
  });

  final List<Recommendation> recommendations;
  final int budget;
  final void Function(Recommendation) onTap;

  @override
  State<_StaggeredCardList> createState() => _StaggeredCardListState();
}

class _StaggeredCardListState extends State<_StaggeredCardList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200 + widget.recommendations.length * 100,
      ),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.recommendations.length;
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      itemCount: count,
      itemBuilder: (context, index) {
        final start = (index / count) * 0.6;
        final end = start + 0.4;
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end.clamp(0.0, 1.0),
              curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: RecommendationCard(
              recommendation: widget.recommendations[index],
              rank: index + 1,
              budget: widget.budget,
              onTap: () => widget.onTap(widget.recommendations[index]),
            ),
          ),
        );
      },
    );
  }
}
