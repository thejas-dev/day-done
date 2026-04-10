import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/theme/app_theme.dart';
import 'package:todo_tracker/core/theme/app_typography.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/task_action_sheet.dart';

/// A single task row for the Today screen.
///
/// Displays:
/// - Priority-coloured left border (4px)
/// - Task title (bold if urgent, strikethrough if done)
/// - Label chips (max 3, with +N overflow indicator)
/// - Status icon on the trailing side
///
/// Tapping opens the task action bottom sheet.
class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task});

  final TodayTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final colors = AppColors.priorityColors(task.priority, brightness);
    final hasPriorityBorder = task.priority != Priority.none;

    return GestureDetector(
      onTap: () => _onTap(context, ref),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
          boxShadow: brightness == Brightness.light
              ? AppTheme.cardShadow
              : null,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.mdAll,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Priority left border
                if (hasPriorityBorder)
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.md),
                        bottomLeft: Radius.circular(AppRadius.md),
                      ),
                    ),
                  ),

                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: hasPriorityBorder ? AppSpacing.md : AppSpacing.lg,
                      right: AppSpacing.md,
                      top: AppSpacing.md,
                      bottom: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          task.title,
                          style: _titleStyle(context, brightness),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Labels
                        if (task.labels.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          _LabelChipsRow(labels: task.labels),
                        ],
                      ],
                    ),
                  ),
                ),

                // Status icon
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: _StatusIcon(status: task.status),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _titleStyle(BuildContext context, Brightness brightness) {
    if (task.status == TaskStatus.done || task.status == TaskStatus.closed) {
      return AppTypography.doneTaskTitle(brightness);
    }
    if (task.priority == Priority.urgent) {
      return AppTypography.urgentTaskTitle(brightness);
    }
    return Theme.of(context).textTheme.titleMedium ?? const TextStyle();
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    showTaskActionSheet(context, ref, task);
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (status) {
      TaskStatus.pending => (
          Icons.radio_button_unchecked,
          Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      TaskStatus.done => (Icons.check_circle, AppColors.success),
      TaskStatus.closed => (Icons.cancel_outlined, AppColors.error),
      TaskStatus.snoozed => (Icons.snooze, AppColors.warning),
    };

    return Icon(icon, size: 22, color: color);
  }
}

class _LabelChipsRow extends StatelessWidget {
  const _LabelChipsRow({required this.labels});

  final List<String> labels;

  static const int _maxVisible = 3;

  @override
  Widget build(BuildContext context) {
    final visible = labels.take(_maxVisible).toList();
    final overflow = labels.length - _maxVisible;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final label in visible)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.fullAll,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (overflow > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.fullAll,
            ),
            child: Text(
              '+$overflow',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }
}
