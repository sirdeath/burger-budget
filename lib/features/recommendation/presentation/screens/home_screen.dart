import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
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
                      const SizedBox(height: AppSpacing.lg),
                      SlideTransition(
                        position: _budgetSlide,
                        child: FadeTransition(
                          opacity: _budgetFade,
                          child: Card(
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
                                  const _PersonCountSelector(),
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
                      onPressed: canRecommend
                          ? () {
                              HapticFeedback.mediumImpact();
                              final budget =
                                  ref.read(budgetStateProvider)!;
                              final franchises = ref
                                  .read(selectedFranchisesProvider)
                                  .toList();
                              final personCount = ref
                                  .read(personCountStateProvider);
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
                            }
                          : null,
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

class _PersonCountSelector extends ConsumerWidget {
  const _PersonCountSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(personCountStateProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '인원',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 1, label: Text('1인')),
            ButtonSegment(value: 2, label: Text('2인')),
            ButtonSegment(value: 3, label: Text('3인')),
            ButtonSegment(value: 4, label: Text('4인')),
          ],
          selected: {count},
          onSelectionChanged: (selected) {
            ref
                .read(personCountStateProvider.notifier)
                .setCount(selected.first);
          },
        ),
      ],
    );
  }
}
