import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../providers/menu_search_provider.dart';
import '../widgets/category_compare_view.dart';
import '../widgets/franchise_menu_view.dart';

enum _BoardTab { franchise, compare }

class MenuBoardScreen extends ConsumerStatefulWidget {
  const MenuBoardScreen({super.key});

  @override
  ConsumerState<MenuBoardScreen> createState() =>
      _MenuBoardScreenState();
}

class _MenuBoardScreenState
    extends ConsumerState<MenuBoardScreen> {
  _BoardTab _tab = _BoardTab.franchise;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(menuBoardQueryProvider);
    final sortMode = ref.watch(menuBoardSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('메뉴판'),
      ),
      body: Column(
        children: [
          // 탭 전환
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: SegmentedButton<_BoardTab>(
              segments: const [
                ButtonSegment(
                  value: _BoardTab.franchise,
                  icon: Icon(Icons.store, size: 18),
                  label: Text('브랜드별'),
                ),
                ButtonSegment(
                  value: _BoardTab.compare,
                  icon: Icon(
                    Icons.compare_arrows,
                    size: 18,
                  ),
                  label: Text('비교'),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (selected) {
                setState(() => _tab = selected.first);
              },
            ),
          ),
          // 검색바
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '메뉴 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(
                                menuBoardQueryProvider
                                    .notifier,
                              )
                              .update('');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
              ),
              onChanged: (value) {
                ref
                    .read(
                      menuBoardQueryProvider.notifier,
                    )
                    .update(value);
              },
            ),
          ),
          // 정렬 칩
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                _SortChip(
                  label: '가격 낮은순',
                  selected: sortMode ==
                      MenuBoardSortMode.priceAsc,
                  onSelected: () => ref
                      .read(
                        menuBoardSortProvider.notifier,
                      )
                      .select(MenuBoardSortMode.priceAsc),
                  theme: theme,
                ),
                const SizedBox(width: AppSpacing.xs),
                _SortChip(
                  label: '가격 높은순',
                  selected: sortMode ==
                      MenuBoardSortMode.priceDesc,
                  onSelected: () => ref
                      .read(
                        menuBoardSortProvider.notifier,
                      )
                      .select(
                        MenuBoardSortMode.priceDesc,
                      ),
                  theme: theme,
                ),
                const SizedBox(width: AppSpacing.xs),
                _SortChip(
                  label: '이름순',
                  selected: sortMode ==
                      MenuBoardSortMode.nameAsc,
                  onSelected: () => ref
                      .read(
                        menuBoardSortProvider.notifier,
                      )
                      .select(MenuBoardSortMode.nameAsc),
                  theme: theme,
                ),
              ],
            ),
          ),
          // 본문
          Expanded(
            child: _tab == _BoardTab.franchise
                ? const FranchiseMenuView()
                : const CategoryCompareView(),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: theme.textTheme.labelSmall,
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize:
          MaterialTapTargetSize.shrinkWrap,
    );
  }
}
