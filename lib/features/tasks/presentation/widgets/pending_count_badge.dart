import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/today_summary_provider.dart';

/// A small badge showing the number of pending tasks today.
///
/// Useful for tab bars or app bar indicators.
/// Shows nothing when there are 0 pending tasks.
class PendingCountBadge extends ConsumerWidget {
  const PendingCountBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(todaySummaryProvider);

    if (summary.pending == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(
        '${summary.pending}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
