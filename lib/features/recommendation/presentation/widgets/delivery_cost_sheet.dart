import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_format.dart';
import '../../domain/entities/recommendation.dart';

class DeliveryCostSheet extends StatefulWidget {
  const DeliveryCostSheet({
    super.key,
    required this.recommendation,
    required this.personCount,
  });

  final Recommendation recommendation;
  final int personCount;

  @override
  State<DeliveryCostSheet> createState() => _DeliveryCostSheetState();
}

class _DeliveryCostSheetState extends State<DeliveryCostSheet> {
  int _deliveryFee = 0;
  final _controller = TextEditingController();

  static const _presets = [0, 1000, 2000, 3000];

  int get _storeTotal => widget.recommendation.totalPrice;

  int get _deliveryTotal =>
      widget.recommendation.totalDeliveryPrice ?? _storeTotal;

  int get _hiddenDiff => _deliveryTotal - _storeTotal;

  int get _totalExtraCost => _hiddenDiff + _deliveryFee;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectPreset(int fee) {
    setState(() {
      _deliveryFee = fee;
      _controller.clear();
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diffPercent =
        _storeTotal > 0 ? (_totalExtraCost / _storeTotal * 100).round() : 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '배달비 계산기',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${widget.recommendation.mainItem.name} 기준',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 배달비 프리셋
            Text(
              '배달비',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _presets.map((fee) {
                final selected = _deliveryFee == fee &&
                    _controller.text.isEmpty;
                return ChoiceChip(
                  label: Text(
                    fee == 0 ? '무료' : formatKRW(fee),
                  ),
                  selected: selected,
                  onSelected: (_) => _selectPreset(fee),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: 160,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: '직접 입력',
                  prefixText: '\u20A9 ',
                  isDense: true,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onChanged: (value) {
                  final fee = int.tryParse(value) ?? 0;
                  setState(() => _deliveryFee = fee);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 비용 분석
            _CostRow(
              label: '매장 주문 시',
              value: formatKRW(_storeTotal),
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.xs),
            _CostRow(
              label: '배달 주문 시',
              value: '${formatKRW(_deliveryTotal)}'
                  '${_hiddenDiff > 0 ? ' (메뉴 +${formatKRW(_hiddenDiff)})' : ''}',
              theme: theme,
              isHighlight: _hiddenDiff > 0,
            ),
            if (_deliveryFee > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              _CostRow(
                label: '배달비',
                value: formatKRW(_deliveryFee),
                theme: theme,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _CostRow(
              label: '실제 추가비용',
              value: '+${formatKRW(_totalExtraCost)}'
                  ' (매장가의 +$diffPercent%)',
              theme: theme,
              isBold: true,
              isHighlight: true,
            ),
            const SizedBox(height: AppSpacing.lg),

            // 인원별 분할
            if (widget.personCount > 1 ||
                _totalExtraCost > 0) ...[
              Text(
                '인원별 추가비용',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: List.generate(4, (i) {
                  final n = i + 1;
                  final perPerson = _totalExtraCost ~/ n;
                  return _PersonChip(
                    count: n,
                    amount: perPerson,
                    isCurrentCount:
                        n == widget.personCount,
                    theme: theme,
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 핵심 메시지
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _deliveryFee == 0 && _hiddenDiff > 0
                    ? '무료배달이라도 '
                        '${formatKRW(_hiddenDiff)}은 더 내는 셈입니다'
                    : _totalExtraCost > 0
                        ? '배달비 포함 총 '
                            '${formatKRW(_totalExtraCost)} 추가'
                            ' (매장가의 +$diffPercent%)'
                        : '매장가와 동일합니다',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isBold = false,
    this.isHighlight = false,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final bool isBold;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final color = isHighlight
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: isBold ? FontWeight.bold : null,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
}

class _PersonChip extends StatelessWidget {
  const _PersonChip({
    required this.count,
    required this.amount,
    required this.isCurrentCount,
    required this.theme,
  });

  final int count;
  final int amount;
  final bool isCurrentCount;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isCurrentCount
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: isCurrentCount
            ? Border.all(color: theme.colorScheme.primary)
            : null,
      ),
      child: Text(
        '$count\uC778: +${formatKRW(amount)}',
        style: theme.textTheme.labelMedium?.copyWith(
          color: isCurrentCount
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
          fontWeight:
              isCurrentCount ? FontWeight.bold : null,
        ),
      ),
    );
  }
}
