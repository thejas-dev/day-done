import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/today_summary_provider.dart';

/// A horizontal progress bar showing today's completion fraction.
///
/// Fills from left to right as tasks are resolved (done + closed).
/// Shows the completion percentage as text below the bar.
class DailyProgressBar extends ConsumerWidget {
  const DailyProgressBar({super.key, this.height = 8.0});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(todaySummaryProvider);
    final fraction = summary.completionFraction.clamp(0.0, 1.0);

    if (summary.total == 0) return const SizedBox.shrink();

    final brightness = Theme.of(context).brightness;
    final trackColor = brightness == Brightness.light
        ? AppColors.borderLight
        : AppColors.borderDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: AppRadius.fullAll,
          child: SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Track
                    Container(
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: trackColor,
                        borderRadius: AppRadius.fullAll,
                      ),
                    ),
                    // Fill
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: constraints.maxWidth * fraction,
                      decoration: BoxDecoration(
                        color: _fillColor(fraction, context),
                        borderRadius: AppRadius.fullAll,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // Completion text
        Text(
          '${summary.done + summary.closed} of ${summary.total} completed',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Color _fillColor(double fraction, BuildContext context) {
    if (fraction >= 1.0) return AppColors.success;
    if (fraction >= 0.5) return Theme.of(context).colorScheme.primary;
    return AppColors.warning;
  }
}
