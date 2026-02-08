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
      _formatAndSet();
    }
  }

  void _formatAndSet() {
    final text = _controller.text.replaceAll(',', '');
    final value = int.tryParse(text);
    if (value != null &&
        value >= AppConstants.minBudget &&
        value <= AppConstants.maxBudget) {
      ref.read(budgetStateProvider.notifier).setBudget(value);
      _controller.text = formatKRW(value).replaceAll('원', '');
    } else if (text.isEmpty) {
      ref.read(budgetStateProvider.notifier).setBudget(null);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        prefixText: '₩ ',
        suffixText: '원',
        helperText:
            '${formatKRW(AppConstants.minBudget)} ~ ${formatKRW(AppConstants.maxBudget)}',
      ),
      onSubmitted: (_) => _formatAndSet(),
    );
  }
}
