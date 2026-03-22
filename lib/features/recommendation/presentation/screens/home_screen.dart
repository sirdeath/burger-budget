import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../menu/presentation/screens/menu_detail_screen.dart';
import '../../../menu/presentation/screens/menu_search_screen.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/budget_input.dart' show BudgetInputWidget;
import '../widgets/franchise_chips.dart';
import 'results_screen.dart';

class _SlideUpRoute extends PageRouteBuilder<void> {
  _SlideUpRoute({required Widget child})
      : super(
          pageBuilder: (_, _, _) => child,
          transitionsBuilder: (_, animation, _, child) {
            final tween = Tween(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _budgetFade;
  late final Animation<Offset> _budgetSlide;
  late final Animation<double> _franchiseFade;
  late final Animation<Offset> _franchiseSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  final _budgetCardKey = GlobalKey();
  final _franchiseCardKey = GlobalKey();

  static const _totalDuration = Duration(milliseconds: 800);
  static const _slideOffset = Offset(0, 0.08);

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: _totalDuration,
    );

    _titleFade = _interval(0.0, 0.5);
    _titleSlide = _slideInterval(0.0, 0.5);
    _budgetFade = _interval(0.15, 0.65);
    _budgetSlide = _slideInterval(0.15, 0.65);
    _franchiseFade = _interval(0.3, 0.8);
    _franchiseSlide = _slideInterval(0.3, 0.8);
    _buttonFade = _interval(0.45, 1.0);
    _buttonSlide = _slideInterval(0.45, 1.0);

    _staggerController.forward();
  }

  Animation<double> _interval(double begin, double end) {
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(begin, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _slideInterval(double begin, double end) {
    return Tween(begin: _slideOffset, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _showValidationHint({required bool hasBudget}) {
    final message = !hasBudget
        ? '예산을 입력해주세요'
        : '프랜차이즈를 선택해주세요';
    final targetKey =
        !hasBudget ? _budgetCardKey : _franchiseCardKey;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));

    final targetContext = targetKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasBudget =
        ref.watch(budgetStateProvider.select((b) => b != null));
    final hasFranchises = ref.watch(
      selectedFranchisesProvider.select((f) => f.isNotEmpty),
    );
    final canRecommend = hasBudget && hasFranchises;
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('buzit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '메뉴 검색',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const MenuSearchScreen(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleFade,
                          child: Text(
                            '예산을 입력하고\n프랜차이즈를 선택하세요',
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const _LastOrderCard(),
                      const SizedBox(height: AppSpacing.md),
                      SlideTransition(
                        position: _budgetSlide,
                        child: FadeTransition(
                          opacity: _budgetFade,
                          child: Card(
                            key: _budgetCardKey,
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '예산 설정',
                                    style:
                                        theme.textTheme.titleSmall,
                                  ),
                                  const SizedBox(
                                    height: AppSpacing.sm,
                                  ),
                                  const BudgetInputWidget(),
                                  const SizedBox(
                                    height: AppSpacing.md,
                                  ),
                                  const _PersonCountAndDelivery(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SlideTransition(
                        position: _franchiseSlide,
                        child: FadeTransition(
                          opacity: _franchiseFade,
                          child: Card(
                            key: _franchiseCardKey,
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '프랜차이즈',
                                    style:
                                        theme.textTheme.titleSmall,
                                  ),
                                  const SizedBox(
                                    height: AppSpacing.sm,
                                  ),
                                  const FranchiseChips(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SlideTransition(
                position: _buttonSlide,
                child: FadeTransition(
                  opacity: _buttonFade,
                  child: AnimatedScale(
                    scale: canRecommend ? 1.0 : 0.95,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (!canRecommend) {
                          _showValidationHint(
                            hasBudget: hasBudget,
                          );
                          return;
                        }
                        HapticFeedback.mediumImpact();
                        final budget =
                            ref.read(budgetStateProvider)!;
                        final franchises = ref
                            .read(selectedFranchisesProvider)
                            .toList();
                        final personCount =
                            ref.read(personCountStateProvider);
                        Navigator.push(
                          context,
                          _SlideUpRoute(
                            child: ResultsScreen(
                              budget: budget,
                              franchises: franchises,
                              personCount: personCount,
                            ),
                          ),
                        );
                      },
                      style: canRecommend
                          ? null
                          : FilledButton.styleFrom(
                              backgroundColor: theme
                                  .colorScheme.onSurface
                                  .withValues(alpha: 0.12),
                              foregroundColor: theme
                                  .colorScheme.onSurface
                                  .withValues(alpha: 0.38),
                            ),
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('추천받기'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonCountAndDelivery extends ConsumerWidget {
  const _PersonCountAndDelivery();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(personCountStateProvider);
    final isDelivery = ref.watch(deliveryModeStateProvider);
    final theme = Theme.of(context);

    return Row(
      children: [
        // 인원 스테퍼
        Text(
          '인원',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton.outlined(
          onPressed: count > 1
              ? () {
                  HapticFeedback.selectionClick();
                  ref
                      .read(personCountStateProvider.notifier)
                      .setCount(count - 1);
                }
              : null,
          icon: const Icon(Icons.remove, size: 16),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          padding: EdgeInsets.zero,
          iconSize: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.person,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              if (count > 1)
                Positioned(
                  right: -10,
                  top: -4,
                  child: Text(
                    '×$count',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        IconButton.outlined(
          onPressed: count < 4
              ? () {
                  HapticFeedback.selectionClick();
                  ref
                      .read(personCountStateProvider.notifier)
                      .setCount(count + 1);
                }
              : null,
          icon: const Icon(Icons.add, size: 16),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          padding: EdgeInsets.zero,
          iconSize: 16,
        ),
        const Spacer(),
        // 주문 방식
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              label: Text('매장'),
            ),
            ButtonSegment(
              value: true,
              label: Text('배달'),
            ),
          ],
          selected: {isDelivery},
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize:
                MaterialTapTargetSize.shrinkWrap,
          ),
          onSelectionChanged: (selected) {
            HapticFeedback.selectionClick();
            ref
                .read(deliveryModeStateProvider.notifier)
                .setMode(isDelivery: selected.first);
          },
        ),
      ],
    );
  }
}

class _LastOrderCard extends ConsumerWidget {
  const _LastOrderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastOrder = ref.watch(lastOrderHistoryProvider);

    return lastOrder.when(
      data: (order) {
        if (order == null) return const SizedBox.shrink();

        final theme = Theme.of(context);
        final franchise = order.mainItem.franchise;
        final color = AppTheme.franchiseColor(
          franchise,
          theme.brightness,
        );
        final name = AppConstants.franchiseNames[franchise] ??
            franchise;
        final emoji =
            AppConstants.franchiseEmojis[franchise] ?? '';
        final dateFormat = DateFormat('M/d HH:mm');

        final items = <String>[order.mainItem.name];
        if (order.sideItem != null) {
          items.add(order.sideItem!.name);
        }
        if (order.drinkItem != null) {
          items.add(order.drinkItem!.name);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs,
                bottom: AppSpacing.xs,
              ),
              child: Text(
                '최근 선택',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => MenuDetailScreen(
                menuItem: order.mainItem,
                sideItem: order.sideItem,
                drinkItem: order.drinkItem,
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$emoji $name',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: color),
                        ),
                        Text(
                          items.join(' + '),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatKRW(order.totalPrice),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateFormat.format(order.createdAt),
                        style: theme.textTheme.labelSmall
                            ?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
