import 'package:flutter/material.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';

/// Inline text link — design ref `primitives.jsx:320 TextLink`.
///
/// `titleMedium` w500, primary colour by default. Used for "Skip / Not now"
/// links beneath onboarding CTAs and the "Delete Task" link in edit sheets
/// (pass `color: errorColor`).
class TextLinkDS extends StatelessWidget {
  const TextLinkDS({
    super.key,
    required this.label,
    this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final fg = color ?? (isLight ? AppColors.primary : AppColors.primaryDark);

    final text = Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: fg,
            fontWeight: FontWeight.w500,
          ),
    );

    if (onTap == null) return text;
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: text,
      ),
    );
  }
}
