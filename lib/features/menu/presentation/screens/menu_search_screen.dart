import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/menu_type_display.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/menu_item.dart';
import '../providers/menu_search_provider.dart';
import 'menu_detail_screen.dart';

class MenuSearchScreen extends ConsumerStatefulWidget {
  const MenuSearchScreen({super.key});

  @override
  ConsumerState<MenuSearchScreen> createState() => _MenuSearchScreenState();
}

class _MenuSearchScreenState extends ConsumerState<MenuSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(menuSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('메뉴 검색'),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '메뉴 이름을 입력하세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(menuSearchQueryProvider.notifier)
                              .update('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(menuSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
          // Search results
          Expanded(
            child: searchResults.when(
              data: (results) {
                if (ref.watch(menuSearchQueryProvider).trim().isEmpty) {
                  return const EmptyState(
                    icon: Icons.search,
                    title: '메뉴를 검색해보세요',
                    description: '원하는 메뉴의 이름을 입력하면\n전체 프랜차이즈에서 검색합니다',
                  );
                }

                if (results.isEmpty) {
                  return _NoResultsView(
                    onSuggestionTap: (query) {
                      _searchController.text = query;
                      ref
                          .read(menuSearchQueryProvider.notifier)
                          .update(query);
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return _MenuSearchResultCard(
                      item: item,
                      onTap: () {
                        _showMenuDetail(context, item);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => ErrorView(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(menuSearchResultsProvider);
                },
              ),
            ),
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

class _MenuSearchResultCard extends StatelessWidget {
  const _MenuSearchResultCard({
    required this.item,
    required this.onTap,
  });

  final MenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Menu icon placeholder
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getMenuIcon(item.type),
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _FranchiseBadge(
                          franchise: item.franchise,
                          brightness: theme.brightness,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _getTypeLabel(item.type),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Text(
                          formatKRW(item.price),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.calories != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${item.calories} kcal',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMenuIcon(MenuType type) => MenuTypeDisplay.icon(type);

  String _getTypeLabel(MenuType type) => MenuTypeDisplay.label(type);
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
    final color = AppTheme.franchiseColor(franchise, brightness);
    final name = AppConstants.franchiseNames[franchise] ?? franchise;
    final emoji = AppConstants.franchiseEmojis[franchise] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$emoji $name',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
