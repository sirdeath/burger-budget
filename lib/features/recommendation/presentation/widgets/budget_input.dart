import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_format.dart';
import '../providers/recommendation_provider.dart';

class BudgetInputWidget extends ConsumerStatefulWidget {
  const BudgetInputWidget({super.key});

  @override
  ConsumerState<BudgetInputWidget> createState() => _BudgetInputState();
}

class _BudgetInputState extends ConsumerState<BudgetInputWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _warningText;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _formatDisplay();
    }
  }

  void _onChanged(String text) {
    if (_isSyncing) return;

    final raw = text.replaceAll(',', '');
    final value = int.tryParse(raw);

    if (raw.isEmpty) {
      ref.read(budgetStateProvider.notifier).setBudget(null);
      setState(() => _warningText = null);
      return;
    }

    if (value == null) {
      ref.read(budgetStateProvider.notifier).setBudget(null);
      setState(() => _warningText = null);
      return;
    }

    if (value > AppConstants.maxBudget) {
      ref.read(budgetStateProvider.notifier).setBudget(null);
      setState(() {
        _warningText =
            '최대 ${formatKRW(AppConstants.maxBudget)}까지 입력 가능합니다';
      });
      return;
    }

    if (value < AppConstants.minBudget) {
      ref.read(budgetStateProvider.notifier).setBudget(null);
      setState(() {
        _warningText =
            '최소 ${formatKRW(AppConstants.minBudget)} 이상 입력하세요';
      });
      return;
    }

    ref.read(budgetStateProvider.notifier).setBudget(value);
    setState(() => _warningText = null);
  }

  void _onPresetTap(int preset) {
    _isSyncing = true;
    _controller.text = '$preset';
    ref.read(budgetStateProvider.notifier).setBudget(preset);
    setState(() => _warningText = null);
    _formatDisplay();
    _isSyncing = false;
  }

  void _formatDisplay() {
    final raw = _controller.text.replaceAll(',', '');
    final value = int.tryParse(raw);
    if (value != null &&
        value >= AppConstants.minBudget &&
        value <= AppConstants.maxBudget) {
      _controller.text = formatKRW(value).replaceAll('원', '');
    }
  }

  String _formatPresetLabel(int preset) {
    if (preset >= 10000) {
      final man = preset / 10000;
      return man == man.toInt()
          ? '${man.toInt()}만'
          : '$man만';
    }
    return '${preset ~/ 1000}천';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budget = ref.watch(budgetStateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: InputDecoration(
                  labelText: '예산',
                  hintText: '직접 입력',
                  prefixText: '\u20a9 ',
                  suffixText: '원',
                  errorText: _warningText,
                  errorStyle: TextStyle(
                    color: theme.colorScheme.error,
                  ),
                  isDense: true,
                ),
                onChanged: _onChanged,
                onSubmitted: (_) => _formatDisplay(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          children: AppConstants.budgetPresets.map((preset) {
            final isSelected = budget == preset;
            return ChoiceChip(
              label: Text(_formatPresetLabel(preset)),
              selected: isSelected,
              onSelected: (_) => _onPresetTap(preset),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }
}
