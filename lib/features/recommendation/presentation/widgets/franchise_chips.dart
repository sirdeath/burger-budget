import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/recommendation_provider.dart';

class FranchiseChips extends ConsumerWidget {
  const FranchiseChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedFranchisesProvider);
    final isAllSelected =
        selected.length == AppConstants.franchiseCodes.length;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        FilterChip(
          label: const Text('전체'),
          selected: isAllSelected,
          onSelected: (_) =>
              ref.read(selectedFranchisesProvider.notifier).toggleAll(),
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        ...AppConstants.franchiseCodes.map((code) {
          final name = AppConstants.franchiseNames[code]!;
          final color = AppTheme.franchiseColor(
            code,
            Theme.of(context).brightness,
          );
          return FilterChip(
            label: Text(name),
            selected: selected.contains(code),
            onSelected: (_) =>
                ref.read(selectedFranchisesProvider.notifier).toggle(code),
            selectedColor: color.withValues(alpha: 0.2),
            checkmarkColor: color,
          );
        }),
      ],
    );
  }
}
