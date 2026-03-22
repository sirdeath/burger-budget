import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/menu_type_display.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/menu_item.dart';
import '../providers/menu_search_provider.dart';
import 'menu_price_tile.dart';


class FranchiseMenuView extends ConsumerWidget {
  const FranchiseMenuView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        ref.watch(selectedCatalogFranchiseProvider);
    final catalogAsync = ref.watch(menuCatalogProvider);
    final query = ref.watch(menuBoardQueryProvider);
    final sortMode = ref.watch(menuBoardSortProvider);

    return Column(
      children: [
        _FranchiseChips(
          selected: selected,
          onSelected: (code) => ref
              .read(
                selectedCatalogFranchiseProvider.notifier,
              )
              .select(code),
        ),
        Expanded(
          child: catalogAsync.when(
            data: (grouped) {
              final filtered = _filterAndSort(
                grouped,
                query,
                sortMode,
              );
              return _GroupedMenuList(grouped: filtered);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => ErrorView(
              message: error.toString(),
              onRetry: () =>
                  ref.invalidate(menuCatalogProvider),
            ),
          ),
        ),
      ],
    );
  }

  static Map<MenuType, List<MenuItem>> _filterAndSort(
    Map<MenuType, List<MenuItem>> grouped,
    String query,
    MenuBoardSortMode sortMode,
  ) {
    final result = <MenuType, List<MenuItem>>{};
    for (final entry in grouped.entries) {
      var items = entry.value;
      if (query.isNotEmpty) {
        items = items
            .where((i) => i.name.contains(query))
            .toList();
      }
      if (items.isEmpty) continue;
      items = List.of(items);
      _sortItems(items, sortMode);
      result[entry.key] = items;
    }
    return result;
  }

  static void _sortItems(
    List<MenuItem> items,
    MenuBoardSortMode mode,
  ) {
    switch (mode) {
      case MenuBoardSortMode.popular:
        items.sort((a, b) {
          final aSig = AppConstants.isSignatureMenu(
                  a.franchise, a.name)
              ? 0
              : 1;
          final bSig = AppConstants.isSignatureMenu(
                  b.franchise, b.name)
              ? 0
              : 1;
          if (aSig != bSig) return aSig.compareTo(bSig);
          return a.name.compareTo(b.name);
        });
      case MenuBoardSortMode.priceAsc:
        items.sort(
          (a, b) => a.price.compareTo(b.price),
        );
      case MenuBoardSortMode.priceDesc:
        items.sort(
          (a, b) => b.price.compareTo(a.price),
        );
      case MenuBoardSortMode.nameAsc:
        items.sort(
          (a, b) => a.name.compareTo(b.name),
        );
    }
  }
}

class _FranchiseChips extends StatelessWidget {
  const _FranchiseChips({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: AppConstants.franchiseCodes.map((code) {
          final isSelected = code == selected;
          final color = AppTheme.franchiseColor(
            code,
            theme.brightness,
          );
          final name =
              AppConstants.franchiseNames[code] ?? code;
          final emoji =
              AppConstants.franchiseEmojis[code] ?? '';

          return Padding(
            padding: const EdgeInsets.only(
              right: AppSpacing.sm,
            ),
            child: FilterChip(
              selected: isSelected,
              label: Text('$emoji $name'),
              labelStyle: TextStyle(
                color: isSelected ? color : null,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              selectedColor:
                  color.withValues(alpha: 0.15),
              side: isSelected
                  ? BorderSide(
                      color:
                          color.withValues(alpha: 0.5),
                    )
                  : null,
              showCheckmark: false,
              onSelected: (_) => onSelected(code),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GroupedMenuList extends StatelessWidget {
  const _GroupedMenuList({required this.grouped});

  final Map<MenuType, List<MenuItem>> grouped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = grouped.entries.toList();

    if (entries.isEmpty) {
      return Center(
        child: Text(
          '검색 결과가 없습니다',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.lg,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final type = entries[index].key;
        final items = entries[index].value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    MenuTypeDisplay.icon(type),
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    MenuTypeDisplay.label(type),
                    style: theme.textTheme.titleSmall
                        ?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${items.length}',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            ...items.map(
              (item) => MenuPriceTile(item: item),
            ),
            if (index < entries.length - 1)
              const Divider(height: AppSpacing.lg),
          ],
        );
      },
    );
  }
}
