import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data_update/presentation/screens/settings_screen.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/budget_input.dart' show BudgetInputWidget;
import '../widgets/franchise_chips.dart';
import 'results_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetStateProvider);
    final franchises = ref.watch(selectedFranchisesProvider);
    final canRecommend = budget != null && franchises.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Burger Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '예산을 입력하고\n프랜차이즈를 선택하세요',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              const BudgetInputWidget(),
              const SizedBox(height: 24),
              Text(
                '프랜차이즈',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              const FranchiseChips(),
              const Spacer(),
              FilledButton.icon(
                onPressed: canRecommend
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => ResultsScreen(
                              budget: budget,
                              franchises: franchises.toList(),
                            ),
                          ),
                        )
                    : null,
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('추천받기'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
