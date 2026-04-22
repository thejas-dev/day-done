import 'package:flutter/material.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';

/// Per-chip colour override — used when a chip's palette is driven by
/// something other than the active/inactive primary state (e.g. priority
/// chips on the create sheet, or label chips on the filter bar).
class ChipDSColors {
  const ChipDSColors({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}

/// Pill chip — design ref `primitives.jsx:131 Chip`.
///
/// Default look: transparent background, hairline border, secondary text.
/// Active look: primary container fill, primary border, primary text.
/// Pass [colors] to override (priority chips on the create sheet etc.).
class ChipDS extends StatelessWidget {
  const ChipDS({
    super.key,
    required this.label,
    this.active = false,
    this.colors,
    this.icon,
    this.trailing,
    this.onTap,
  });

  final String label;
  final bool active;
  final ChipDSColors? colors;

  /// Optional leading icon — sized to 14, tinted to match foreground.
  final Widget? icon;

  /// Optional trailing widget — e.g. an `× close` icon for label chips.
  final Widget? trailing;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final defaultBg = active
        ? (isLight
            ? AppColors.primaryContainer
            : AppColors.primaryContainerDark)
        : Colors.transparent;
    final defaultBorder = active
        ? (isLight ? AppColors.primary : AppColors.primaryDark)
        : (isLight ? AppColors.chipBorderLight : AppColors.chipBorderDark);
    final defaultFg = active
        ? (isLight ? AppColors.primary : AppColors.primaryDark)
        : (isLight
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryDark);

    final bg = colors?.background ?? defaultBg;
    final border = colors?.border ?? defaultBorder;
    final fg = colors?.foreground ?? defaultFg;

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme.merge(
              data: IconThemeData(color: fg, size: 14),
              child: icon!,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            IconTheme.merge(
              data: IconThemeData(color: fg, size: 14),
              child: trailing!,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return chip;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.smAll,
        onTap: onTap,
        child: chip,
      ),
    );
  }
}
