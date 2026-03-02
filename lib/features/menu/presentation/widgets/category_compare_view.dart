import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/menu_type_display.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/menu_item.dart';
import '../providers/menu_search_provider.dart';
import 'menu_price_tile.dart';

class CategoryCompareView extends ConsumerWidget {
  const CategoryCompareView({super.key});

  static const _types = [
    MenuType.set_,
    MenuType.burger,
    MenuType.side,
    MenuType.drink,
    MenuType.dessert,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        ref.watch(selectedCompareTypeProvider);
    final compareAsync =
        ref.watch(categoryCompareProvider);
    final query = ref.watch(menuBoardQueryProvider);
    final sortMode = ref.watch(menuBoardSortProvider);

    return Column(
      children: [
        _TypeChips(
          selected: selected,
          onSelected: (type) => ref
              .read(
                selectedCompareTypeProvider.notifier,
              )
              .select(type),
          itemCounts: compareAsync.whenOrNull(
            data: (items) =>
                _filterItems(items, query).length,
          ),
        ),
        Expanded(
          child: compareAsync.when(
            data: (items) {
              final processed = _filterAndSort(
                items,
                query,
                sortMode,
              );
              return _CompareList(items: processed);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => ErrorView(
              message: error.toString(),
              onRetry: () =>
                  ref.invalidate(categoryCompareProvider),
            ),
          ),
        ),
      ],
    );
  }

  static List<MenuItem> _filterItems(
    List<MenuItem> items,
    String query,
  ) {
    if (query.isEmpty) return items;
    return items
        .where((i) => i.name.contains(query))
        .toList();
  }

  static List<MenuItem> _filterAndSort(
    List<MenuItem> items,
    String query,
    MenuBoardSortMode sortMode,
  ) {
    final filtered = _filterItems(items, query);
    final sorted = List.of(filtered);
    switch (sortMode) {
      case MenuBoardSortMode.priceAsc:
        sorted.sort(
          (a, b) => a.price.compareTo(b.price),
        );
      case MenuBoardSortMode.priceDesc:
        sorted.sort(
          (a, b) => b.price.compareTo(a.price),
        );
      case MenuBoardSortMode.nameAsc:
        sorted.sort(
          (a, b) => a.name.compareTo(b.name),
        );
    }
    return sorted;
  }
}

class _TypeChips extends StatelessWidget {
  const _TypeChips({
    required this.selected,
    required this.onSelected,
    this.itemCounts,
  });

  final MenuType selected;
  final ValueChanged<MenuType> onSelected;
  final int? itemCounts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children:
            CategoryCompareView._types.map((type) {
          final isSelected = type == selected;

          return Padding(
            padding: const EdgeInsets.only(
              right: AppSpacing.sm,
            ),
            child: FilterChip(
              selected: isSelected,
              avatar: Icon(
                MenuTypeDisplay.icon(type),
                size: 18,
              ),
              label: Text(
                isSelected && itemCounts != null
                    ? '${MenuTypeDisplay.label(type)}'
                        ' ($itemCounts)'
                    : MenuTypeDisplay.label(type),
              ),
              labelStyle: TextStyle(
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              showCheckmark: false,
              onSelected: (_) => onSelected(type),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CompareList extends StatelessWidget {
  const _CompareList({required this.items});

  final List<MenuItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final theme = Theme.of(context);
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        return MenuPriceTile(
          item: items[index],
          showFranchise: true,
        );
      },
    );
  }
}
