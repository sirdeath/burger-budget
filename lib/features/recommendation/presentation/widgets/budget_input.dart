import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
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

  void _formatDisplay() {
    final raw = _controller.text.replaceAll(',', '');
    final value = int.tryParse(raw);
    if (value != null &&
        value >= AppConstants.minBudget &&
        value <= AppConstants.maxBudget) {
      _controller.text = formatKRW(value).replaceAll('원', '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: InputDecoration(
        labelText: '예산',
        hintText: '예산을 입력하세요',
        prefixText: '\u20a9 ',
        suffixText: '원',
        helperText:
            '${formatKRW(AppConstants.minBudget)} ~ ${formatKRW(AppConstants.maxBudget)}',
        errorText: _warningText,
        errorStyle: TextStyle(color: theme.colorScheme.error),
      ),
      onChanged: _onChanged,
      onSubmitted: (_) => _formatDisplay(),
    );
  }
}
