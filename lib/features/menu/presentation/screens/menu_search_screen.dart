import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/menu_type_display.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/menu_item.dart';
import '../providers/menu_search_provider.dart';
import 'menu_detail_screen.dart';

class MenuSearchScreen extends ConsumerStatefulWidget {
  const MenuSearchScreen({super.key});

  @override
  ConsumerState<MenuSearchScreen> createState() =>
      _MenuSearchScreenState();
}

class _MenuSearchScreenState
    extends ConsumerState<MenuSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(menuSearchQueryProvider);
    final hasQuery = query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('메뉴'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '메뉴 이름을 검색하세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: '검색어 지우기',
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(
                                menuSearchQueryProvider
                                    .notifier,
                              )
                              .update('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref
                    .read(menuSearchQueryProvider.notifier)
                    .update(value);
              },
            ),
          ),
          Expanded(
            child: hasQuery
                ? _SearchResultsView(
                    onMenuTap: _showMenuDetail,
                    onSuggestionTap: (q) {
                      _searchController.text = q;
                      ref
                          .read(
                            menuSearchQueryProvider.notifier,
                          )
                          .update(q);
                    },
                  )
                : const _CatalogView(),
          ),
        ],
      ),
    );
  }

  void _showMenuDetail(BuildContext context, MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: MenuDetailScreen(menuItem: item),
      ),
    );
  }
}

// ── 검색 결과 뷰 ──

class _SearchResultsView extends ConsumerWidget {
  const _SearchResultsView({
    required this.onMenuTap,
    required this.onSuggestionTap,
  });

  final void Function(BuildContext, MenuItem) onMenuTap;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(menuSearchResultsProvider);

    return searchResults.when(
      data: (results) {
        if (results.isEmpty) {
          return _NoResultsView(
            onSuggestionTap: onSuggestionTap,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            return _MenuListTile(
              item: item,
              showFranchise: true,
              onTap: () => onMenuTap(context, item),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () =>
            ref.invalidate(menuSearchResultsProvider),
      ),
    );
  }
}

// ── 카탈로그 뷰 (검색어 없을 때) ──

class _CatalogView extends ConsumerWidget {
  const _CatalogView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        ref.watch(selectedCatalogFranchiseProvider);
    final catalogAsync = ref.watch(menuCatalogProvider);

    return Column(
      children: [
        // 프랜차이즈 탭바
        _FranchiseTabBar(
          selected: selected,
          onSelected: (code) => ref
              .read(
                selectedCatalogFranchiseProvider.notifier,
              )
              .select(code),
        ),
        // 카테고리별 메뉴 목록
        Expanded(
          child: catalogAsync.when(
            data: (grouped) => _CatalogList(
              grouped: grouped,
            ),
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
}

class _FranchiseTabBar extends StatelessWidget {
  const _FranchiseTabBar({
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
              selectedColor: color.withValues(alpha: 0.15),
              side: isSelected
                  ? BorderSide(
                      color: color.withValues(alpha: 0.5),
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

class _CatalogList extends StatelessWidget {
  const _CatalogList({required this.grouped});

  final Map<MenuType, List<MenuItem>> grouped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = grouped.entries.toList();

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
                    style:
                        theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${items.length}',
                    style:
                        theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            ...items.map(
              (item) => _MenuListTile(
                item: item,
                showFranchise: false,
                onTap: () => _showDetail(context, item),
              ),
            ),
            if (index < entries.length - 1)
              const Divider(height: AppSpacing.lg),
          ],
        );
      },
    );
  }

  void _showDetail(BuildContext context, MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: MenuDetailScreen(menuItem: item),
      ),
    );
  }
}

// ── 공용 위젯 ──

class _MenuListTile extends StatelessWidget {
  const _MenuListTile({
    required this.item,
    required this.showFranchise,
    required this.onTap,
  });

  final MenuItem item;
  final bool showFranchise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 3,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  MenuTypeDisplay.icon(item.type),
                  color:
                      theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (showFranchise)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 2,
                        ),
                        child: _FranchiseBadge(
                          franchise: item.franchise,
                          brightness: theme.brightness,
                        ),
                      ),
                    Text(
                      item.name,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatKRW(item.price),
                    style:
                        theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.calories != null)
                    Text(
                      '${item.calories} kcal',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView({required this.onSuggestionTap});

  final ValueChanged<String> onSuggestionTap;

  static const _suggestions = [
    '빅맥',
    '와퍼',
    '치킨',
    '불고기',
    '너겟',
    '콜라',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '검색 결과가 없습니다',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '이런 메뉴는 어떠세요?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: _suggestions
                  .map(
                    (s) => ActionChip(
                      label: Text(s),
                      onPressed: () => onSuggestionTap(s),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FranchiseBadge extends StatelessWidget {
  const _FranchiseBadge({
    required this.franchise,
    required this.brightness,
  });

  final String franchise;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final color =
        AppTheme.franchiseColor(franchise, brightness);
    final name =
        AppConstants.franchiseNames[franchise] ?? franchise;
    final emoji =
        AppConstants.franchiseEmojis[franchise] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '$emoji $name',
        style:
            Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
      ),
    );
  }
}
