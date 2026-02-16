import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholderColor = theme.colorScheme.surfaceContainerHighest;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: placeholderColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                _Placeholder(width: 120, height: 16, color: placeholderColor),
                const Spacer(),
                _Placeholder(
                  width: 64,
                  height: 24,
                  color: placeholderColor,
                  borderRadius: 12,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Row(
                children: [
                  _Placeholder(
                    width: 80,
                    height: 24,
                    color: placeholderColor,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _Placeholder(
                    width: 80,
                    height: 24,
                    color: placeholderColor,
                    borderRadius: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Placeholder(width: 60, height: 14, color: placeholderColor),
                _Placeholder(width: 80, height: 16, color: placeholderColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.width,
    required this.height,
    required this.color,
    this.borderRadius = 4,
  });

  final double width;
  final double height;
  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
