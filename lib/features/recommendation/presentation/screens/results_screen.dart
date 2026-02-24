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
    this.personCount = 1,
  });

  final int budget;
  final List<String> franchises;
  final int personCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortMode = ref.watch(selectedSortModeProvider);
    final menuTypeFilter =
        ref.watch(selectedMenuTypeFilterProvider);
    final perPersonBudget =
        personCount > 1 ? budget ~/ personCount : budget;
    final asyncRecommendations = ref.watch(
      recommendationsProvider(
        budget: budget,
        franchises: franchises,
        sort: sortMode,
        personCount: personCount,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          personCount > 1
              ? '$personCount인 추천 (${formatKRW(budget)})'
              : '추천 결과 (${formatKRW(budget)})',
        ),
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
          if (personCount > 1)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Card(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '$personCount인 기준 · '
                        '1인당 ${formatKRW(perPersonBudget)}',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                ref
                    .read(displayedCountStateProvider.notifier)
                    .reset();
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
                    personCount: personCount,
                  ),
                ),
              ),
              data: (allRecommendations) {
                final setCount = allRecommendations
                    .where((r) => r.isSet)
                    .length;
                final singleCount =
                    allRecommendations.length - setCount;
                final recommendations = switch (menuTypeFilter)
                {
                  MenuTypeFilter.all =>
                    allRecommendations,
                  MenuTypeFilter.setOnly =>
                    allRecommendations
                        .where((r) => r.isSet)
                        .toList(),
                  MenuTypeFilter.singleOnly =>
                    allRecommendations
                        .where((r) => !r.isSet)
                        .toList(),
                };
                if (recommendations.isEmpty &&
                    allRecommendations.isEmpty) {
                  return EmptyState(
                    icon: Icons.no_meals,
                    title: '추천 가능한 메뉴가 없습니다',
                    description: personCount > 1
                        ? '${formatKRW(budget)} ($personCount인) '
                            '예산으로는 조합을 찾지 못했어요.\n'
                            '예산을 올리거나 인원을 줄여 보세요.'
                        : '${formatKRW(budget)} 예산으로는 '
                            '조합을 찾지 못했어요.\n'
                            '예산을 올리거나 다른 프랜차이즈를 '
                            '선택해 보세요.',
                    actionLabel: '예산 조정하기',
                    onAction: () => Navigator.pop(context),
                  );
                }
                final displayedCount =
                    ref.watch(displayedCountStateProvider);
                final visible = recommendations.length >
                        displayedCount
                    ? recommendations.sublist(0, displayedCount)
                    : recommendations;
                final totalCount = recommendations.length;
                final hasMore = displayedCount < totalCount;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: SegmentedButton<MenuTypeFilter>(
                        segments: [
                          ButtonSegment(
                            value: MenuTypeFilter.all,
                            label: Text(
                              '전체 (${allRecommendations.length})',
                            ),
                          ),
                          ButtonSegment(
                            value: MenuTypeFilter.setOnly,
                            label: Text('세트 ($setCount)'),
                            icon: const Icon(Icons.lunch_dining),
                          ),
                          ButtonSegment(
                            value: MenuTypeFilter.singleOnly,
                            label: Text('단품 ($singleCount)'),
                            icon: const Icon(Icons.restaurant),
                          ),
                        ],
                        selected: {menuTypeFilter},
                        onSelectionChanged: (selected) {
                          ref
                              .read(
                                selectedMenuTypeFilterProvider
                                    .notifier,
                              )
                              .setFilter(selected.first);
                          ref
                              .read(
                                displayedCountStateProvider
                                    .notifier,
                              )
                              .reset();
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (recommendations.isEmpty)
                      Expanded(
                        child: EmptyState(
                          icon: Icons.no_meals,
                          title:
                              '${menuTypeFilter == MenuTypeFilter.setOnly ? '세트' : '단품'} 메뉴가 없습니다',
                          description:
                              '필터를 변경하거나 "전체"를 선택해 보세요.',
                          actionLabel: '전체 보기',
                          onAction: () => ref
                              .read(
                                selectedMenuTypeFilterProvider
                                    .notifier,
                              )
                              .setFilter(MenuTypeFilter.all),
                        ),
                      )
                    else
                    Expanded(
                      child: _StaggeredCardList(
                        key: ValueKey(
                          '$sortMode-$menuTypeFilter',
                        ),
                        recommendations: visible,
                        perPersonBudget: perPersonBudget,
                        totalCount: totalCount,
                        hasMore: hasMore,
                        onLoadMore: () => ref
                            .read(
                              displayedCountStateProvider.notifier,
                            )
                            .loadMore(totalCount),
                        onTap: (r) => _showDetail(context, r),
                      ),
                    ),
                  ],
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
        dessertItem: recommendation.dessertItem,
      ),
    );
  }
}

class _StaggeredCardList extends StatefulWidget {
  const _StaggeredCardList({
    super.key,
    required this.recommendations,
    required this.perPersonBudget,
    required this.totalCount,
    required this.hasMore,
    required this.onLoadMore,
    required this.onTap,
  });

  final List<Recommendation> recommendations;
  final int perPersonBudget;
  final int totalCount;
  final bool hasMore;
  final VoidCallback onLoadMore;
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

  bool _loadingMore = false;

  @override
  Widget build(BuildContext context) {
    final count = widget.recommendations.length;
    // 항상 footer 1개 추가 (로딩 스피너 또는 결과 요약)
    final itemCount = count + 1;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (widget.hasMore &&
            !_loadingMore &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          _loadingMore = true;
          widget.onLoadMore();
          // 다음 프레임에서 가드 해제
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _loadingMore = false;
          });
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= count) {
            if (widget.hasMore) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text(
                  '${widget.totalCount}개의 추천 조합',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .outline,
                  ),
                ),
              ),
            );
          }
          final start = (index / count) * 0.6;
          final end = start + 0.4;
          final animation = CurvedAnimation(
            parent: _controller,
            curve: Interval(
              start,
              end.clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          );
          return RepaintBoundary(
            child: FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: RecommendationCard(
                  recommendation: widget.recommendations[index],
                  rank: index + 1,
                  budget: widget.perPersonBudget,
                  onTap: () =>
                      widget.onTap(widget.recommendations[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
