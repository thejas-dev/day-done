import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_tracker/core/constants/route_constants.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_action_provider.dart';

/// Shows a bottom sheet with contextual actions for [task].
/// Closes itself after any action completes.
Future<void> showTaskActionSheet(
  BuildContext context,
  WidgetRef ref,
  TodayTask task,
) {
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => _TaskActionSheet(task: task, ref: ref),
  );
}

class _TaskActionSheet extends StatelessWidget {
  const _TaskActionSheet({required this.task, required this.ref});

  final TodayTask task;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final actions = ref.read(taskActionsProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.borderLight
                    : AppColors.borderDark,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),

            // Task title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1),

            // Edit (all statuses)
            _ActionTile(
              icon: Icons.edit_outlined,
              label: 'Edit',
              onTap: () {
                context.pop();
                context.push(RouteConstants.taskEditPath(task.taskId));
              },
            ),

            // Mark Done (pending or snoozed)
            if (task.status == TaskStatus.pending ||
                task.status == TaskStatus.snoozed) ...[
              _ActionTile(
                icon: Icons.check_circle_outline,
                label: 'Mark Done',
                color: AppColors.success,
                onTap: () async {
                  context.pop();
                  if (task.isDailyInstance) {
                    await actions.markDailyInstanceDone(task.id);
                  } else {
                    await actions.markDone(task.id);
                  }
                },
              ),
            ],

            // Undo Done
            if (task.status == TaskStatus.done) ...[
              _ActionTile(
                icon: Icons.undo,
                label: 'Undo Done',
                onTap: () async {
                  context.pop();
                  if (task.isDailyInstance) {
                    await actions.undoDailyInstanceDone(task.id);
                  } else {
                    await actions.undoDone(task.id);
                  }
                },
              ),
            ],

            // Cancel Snooze (snoozed only)
            if (task.status == TaskStatus.snoozed) ...[
              _ActionTile(
                icon: Icons.alarm_off,
                label: 'Cancel Snooze',
                onTap: () async {
                  context.pop();
                  if (task.isDailyInstance) {
                    await actions.undoDailyInstanceDone(task.id);
                  } else {
                    await actions.undoDone(task.id);
                  }
                },
              ),
            ],

            // Snooze (pending only)
            if (task.status == TaskStatus.pending) ...[
              _ActionTile(
                icon: Icons.snooze_outlined,
                label: 'Snooze',
                onTap: () async {
                  context.pop();
                  await _showSnoozePicker(context, actions);
                },
              ),
            ],

            // Reopen (closed only)
            if (task.status == TaskStatus.closed) ...[
              _ActionTile(
                icon: Icons.refresh,
                label: 'Reopen',
                onTap: () async {
                  context.pop();
                  if (task.isDailyInstance) {
                    await actions.undoDailyInstanceDone(task.id);
                  } else {
                    await actions.undoDone(task.id);
                  }
                },
              ),
            ],

            // Close (pending or snoozed)
            if (task.status == TaskStatus.pending ||
                task.status == TaskStatus.snoozed) ...[
              _ActionTile(
                icon: Icons.close,
                label: 'Close (won\'t do)',
                color: AppColors.error,
                onTap: () async {
                  context.pop();
                  if (task.isDailyInstance) {
                    await actions.markDailyInstanceClosed(task.id);
                  } else {
                    await actions.markClosed(task.id);
                  }
                },
              ),
            ],

            // Delete (pending or snoozed, non-daily only)
            if ((task.status == TaskStatus.pending ||
                    task.status == TaskStatus.snoozed) &&
                !task.isDailyInstance) ...[
              _ActionTile(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: AppColors.error,
                onTap: () async {
                  context.pop();
                  await actions.deleteTask(task.taskId);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showSnoozePicker(
    BuildContext context,
    TaskActions actions,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    final snoozeUntil = DateTime(picked.year, picked.month, picked.day, 9);
    if (task.isDailyInstance) {
      await actions.snoozeDailyInstance(task.id, snoozeUntil);
    } else {
      await actions.snooze(task.id, snoozeUntil);
    }
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).textTheme.bodyLarge?.color;
    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(label,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: effectiveColor)),
      onTap: onTap,
    );
  }
}
