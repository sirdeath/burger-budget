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

  void _showPriceInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('가격 안내'),
        content: const Text(
          '메뉴판의 가격 정보는 각 프랜차이즈 공식 앱에서'
          ' 직접 확인하여 수집한 데이터입니다.\n\n'
          '가격 업데이트 일자가 표기되어 있으며,'
          ' 업데이트가 늦어져 실제 가격과 차이가'
          ' 있을 수 있습니다.\n\n'
          '차이가 발견되면 빠르게 반영하겠습니다.'
          ' 양해 부탁드립니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(menuBoardQueryProvider);
    final sortMode = ref.watch(menuBoardSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('메뉴판'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: '가격 안내',
            onPressed: () => _showPriceInfo(context),
          ),
        ],
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
                  label: '인기순',
                  selected: sortMode ==
                      MenuBoardSortMode.popular,
                  onSelected: () => ref
                      .read(
                        menuBoardSortProvider.notifier,
                      )
                      .select(MenuBoardSortMode.popular),
                  theme: theme,
                ),
                const SizedBox(width: AppSpacing.xs),
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
