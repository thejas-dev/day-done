import 'package:flutter/material.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';

/// Section heading — design ref `primitives.jsx:277 SectionHeader`.
///
///   PADDING · 4              [ optional right widget — e.g. counter ]
class SectionHeaderDS extends StatelessWidget {
  const SectionHeaderDS({
    super.key,
    required this.label,
    this.right,
  });

  /// Rendered upper-cased — pass title-case strings, this widget handles it.
  final String label;
  final Widget? right;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final color =
        isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        14,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          ?right,
        ],
      ),
    );
  }
}
