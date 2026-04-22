import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_tracker/core/constants/route_constants.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/theme/app_theme.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_action_provider.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/snooze_picker_sheet.dart';

/// Context menu — `styles.css` `.bsheet` + `build-slides.js` `sheetB_Context`.
Future<void> showTaskActionSheet(BuildContext context, TodayTask task) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _TaskActionSheet(task: task, anchorContext: context),
  );
}

class _TaskActionSheet extends ConsumerWidget {
  const _TaskActionSheet({required this.task, required this.anchorContext});

  final TodayTask task;
  final BuildContext anchorContext;

  static const _handleW = 36.0;
  static const _handleH = 4.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(taskActionsProvider.notifier);
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final sheetBg = isLight
        ? AppColors.surfaceRaisedLight
        : AppColors.surfaceRaisedDark;
    final secondary = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;
    final disabled = isLight
        ? AppColors.textDisabledLight
        : AppColors.textDisabledDark;
    final success = AppColors.successColor(theme.brightness);
    final error = AppColors.errorColor(theme.brightness);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    Future<void> applySnooze(DateTime until) async {
      if (task.isDailyInstance) {
        await actions.snoozeDailyInstance(task.id, until);
      } else {
        await actions.snooze(task.taskId, until);
      }
    }

    Future<void> openSnoozePicker() async {
      Navigator.pop(context);
      final until = await showSnoozePickerSheet(anchorContext);
      if (until == null || !anchorContext.mounted) return;
      await applySnooze(until);
    }

    Future<void> openReschedule() async {
      Navigator.pop(context);
      final isLight = Theme.of(anchorContext).brightness == Brightness.light;
      final primary = isLight ? AppColors.primary : AppColors.primaryDark;
      final dialogBg = isLight
          ? AppColors.surfaceRaisedLight
          : AppColors.surfaceRaisedDark;
      final onSurface = isLight
          ? AppColors.textPrimaryLight
          : AppColors.textPrimaryDark;
      final secondary = isLight
          ? AppColors.textSecondaryLight
          : AppColors.textSecondaryDark;
      final picked = await showDatePicker(
        context: anchorContext,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        builder: (context, child) {
          final base = Theme.of(context);
          return Theme(
            data: base.copyWith(
              datePickerTheme: DatePickerThemeData(
                backgroundColor: dialogBg,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                headerForegroundColor: onSurface,
                dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return isLight
                        ? AppColors.textOnAccentLight
                        : AppColors.textOnAccentDark;
                  }
                  return onSurface;
                }),
                dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return primary;
                  return null;
                }),
                todayForegroundColor: WidgetStateProperty.all(primary),
                todayBackgroundColor: WidgetStateProperty.all(
                  primary.withValues(alpha: 0.18),
                ),
                yearForegroundColor: WidgetStateProperty.all(onSurface),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: secondary,
                  minimumSize: const Size(64, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child!,
            ),
          );
        },
      );
      if (picked == null || !anchorContext.mounted) return;
      await actions.rescheduleTask(task.taskId, picked);
    }

    final rows = <Widget>[];

    void hairline() {
      rows.add(const SizedBox(height: 4));
      rows.add(
        Divider(
          height: 1,
          thickness: 1,
          color: isLight ? AppColors.dividerLight : AppColors.dividerDark,
        ),
      );
      rows.add(const SizedBox(height: 4));
    }

    if (task.status == TaskStatus.done) {
      rows.add(
        _OptRow(
          icon: Icons.undo,
          label: 'Undo Done',
          iconColor: secondary,
          labelColor: theme.colorScheme.onSurface,
          onTap: () async {
            Navigator.pop(context);
            if (task.isDailyInstance) {
              await actions.undoDailyInstanceDone(task.id);
            } else {
              await actions.undoDone(task.taskId);
            }
          },
        ),
      );
      rows.add(
        _OptRow(
          icon: Icons.edit_outlined,
          label: 'Edit',
          onTap: () {
            Navigator.pop(context);
            anchorContext.push(RouteConstants.taskEditPath(task.taskId));
          },
        ),
      );
    } else if (task.status == TaskStatus.closed) {
      rows.add(
        _OptRow(
          icon: Icons.refresh,
          label: 'Reopen',
          onTap: () async {
            Navigator.pop(context);
            if (task.isDailyInstance) {
              await actions.undoDailyInstanceDone(task.id);
            } else {
              await actions.undoDone(task.taskId);
            }
          },
        ),
      );
      rows.add(
        _OptRow(
          icon: Icons.edit_outlined,
          label: 'Edit',
          onTap: () {
            Navigator.pop(context);
            anchorContext.push(RouteConstants.taskEditPath(task.taskId));
          },
        ),
      );
    } else {
      rows.add(
        _OptRow(
          icon: Icons.check_circle,
          label: 'Mark Done',
          iconColor: success,
          labelColor: success,
          onTap: () async {
            Navigator.pop(context);
            if (task.isDailyInstance) {
              await actions.markDailyInstanceDone(task.id);
            } else {
              await actions.markDone(task.taskId);
            }
          },
        ),
      );

      rows.add(
        _OptRow(
          icon: Icons.schedule,
          label: task.status == TaskStatus.snoozed ? 'Change snooze' : 'Snooze',
          onTap: openSnoozePicker,
        ),
      );

      final isDatedTask = !task.isDailyInstance && task.type == TaskType.dated;
      if (isDatedTask) {
        rows.add(
          _OptRow(
            icon: Icons.event_outlined,
            label: 'Reschedule',
            onTap: openReschedule,
          ),
        );
      }

      rows.add(
        _OptRow(
          icon: Icons.skip_next,
          label: 'Skip Today',
          onTap: () async {
            Navigator.pop(context);
            await actions.skipToday(task);
          },
        ),
      );

      rows.add(
        _OptRow(
          icon: Icons.do_not_disturb_on_outlined,
          label: 'Close (won\'t do)',
          iconColor: error,
          labelColor: error,
          onTap: () async {
            Navigator.pop(context);
            if (task.isDailyInstance) {
              await actions.markDailyInstanceClosed(task.id);
            } else {
              await actions.markClosed(task.taskId);
            }
          },
        ),
      );

      rows.add(
        _OptRow(
          icon: Icons.edit_outlined,
          label: 'Edit',
          onTap: () {
            Navigator.pop(context);
            anchorContext.push(RouteConstants.taskEditPath(task.taskId));
          },
        ),
      );

      if (!task.isDailyInstance) {
        hairline();
        rows.add(
          _OptRow(
            icon: Icons.delete_outline,
            label: 'Delete',
            destructive: true,
            onTap: () async {
              Navigator.pop(context);
              await actions.deleteTask(task.taskId);
            },
          ),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            color: sheetBg,
            boxShadow: isLight
                ? AppTheme.sheetShadowLight
                : AppTheme.sheetShadowDark,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),
                      Center(
                        child: Opacity(
                          opacity: 0.5,
                          child: Container(
                            width: _handleW,
                            height: _handleH,
                            decoration: BoxDecoration(
                              color: disabled,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TASK',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.1,
                                color: secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isLight
                      ? AppColors.dividerLight
                      : AppColors.dividerDark,
                ),
                ...rows,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `.opt-row` — padding 12×20, gap 14, 22px icon; `.destructive` → error.
class _OptRow extends StatelessWidget {
  const _OptRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.brightness == Brightness.light
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;
    final error = AppColors.errorColor(theme.brightness);

    final ic = destructive ? error : (iconColor ?? secondary);
    final lc = destructive
        ? error
        : (labelColor ?? theme.colorScheme.onSurface);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: ic),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: lc,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
