import 'package:flutter/material.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';

/// Primary CTA — design ref `styles.css` `.btn-primary` + `primitives.jsx`.
///
/// **12px** radius (not full pill), **48px** height, **`--text-on-accent`** = white on
/// primary fill (design system; `AppColors.textOnAccentDark` is for other surfaces).
class PrimaryButtonDS extends StatelessWidget {
  const PrimaryButtonDS({
    super.key,
    required this.label,
    this.onPressed,
    this.full = true,
    this.danger = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Stretch to fill available width. Defaults to true (matches sheets / EOD).
  final bool full;

  /// Replace primary fill with `error` — used for destructive CTAs.
  final bool danger;

  /// Optional leading icon, tinted to match foreground colour.
  final Widget? icon;

  static const Color _onAccentFill = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final disabled = onPressed == null;

    final bg = disabled
        ? (isLight ? const Color(0xFFCFD4D9) : const Color(0xFF2E2E2E))
        : danger
            ? AppColors.errorColor(brightness)
            : (isLight ? AppColors.primary : AppColors.primaryDark);

    final fg = disabled
        ? (isLight ? AppColors.textDisabledLight : AppColors.textDisabledDark)
        : _onAccentFill;

    final shadow = (disabled || !isLight)
        ? null
        : const [
            BoxShadow(
              color: Color(0x2E00796B),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ];

    final inner = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.mdAll,
        boxShadow: shadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            IconTheme.merge(
              data: IconThemeData(color: fg, size: 18),
              child: icon!,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onPressed,
        child: inner,
      ),
    );

    return SizedBox(width: full ? double.infinity : null, child: button);
  }
}
