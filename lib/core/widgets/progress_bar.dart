import 'package:flutter/material.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';

/// Linear progress bar — design ref `primitives.jsx:151 ProgressBar`.
///
/// Defaults derive fill colour from [pct]: ≥80 → success, >0 → partial,
/// 0 → divider. Override with [color] / [trackColor] when needed (e.g. the
/// resolution screen drives its own palette).
class ProgressBarDS extends StatelessWidget {
  const ProgressBarDS({
    super.key,
    required this.pct,
    this.color,
    this.trackColor,
    this.height = 4,
    this.glow = false,
  });

  /// Percent in 0..100.
  final double pct;
  final Color? color;
  final Color? trackColor;
  final double height;

  /// Adds a soft halo behind the fill — used in dark mode to lift the bar.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final defaultTrack =
        isLight ? AppColors.dividerLight : AppColors.dividerDark;

    final fill = color ??
        (pct >= 80
            ? AppColors.successColor(brightness)
            : pct > 0
                ? (isLight ? AppColors.partialLight : AppColors.partialDark)
                : defaultTrack);
    final track = trackColor ?? defaultTrack;
    final clamped = pct.clamp(0.0, 100.0) / 100.0;

    return ClipRRect(
      borderRadius: AppRadius.progressAll,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(color: track),
            FractionallySizedBox(
              widthFactor: clamped,
              child: Container(
                decoration: BoxDecoration(
                  color: fill,
                  boxShadow: glow
                      ? [
                          BoxShadow(
                            color: fill.withValues(alpha: 0.55),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
