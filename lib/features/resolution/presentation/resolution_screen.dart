import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_tracker/core/constants/route_constants.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/utils/date_utils.dart';
import 'package:todo_tracker/features/resolution/providers/resolution_provider.dart';
import 'package:todo_tracker/features/settings/presentation/providers/settings_provider.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';

/// End-of-day resolution screen.
/// Lists all unresolved tasks and requires the user to resolve every one
/// before dismissing. Uses PopScope to block back navigation.
class ResolutionScreen extends ConsumerStatefulWidget {
  const ResolutionScreen({super.key});

  @override
  ConsumerState<ResolutionScreen> createState() => _ResolutionScreenState();
}

class _ResolutionScreenState extends ConsumerState<ResolutionScreen> {
  /// Track which tasks have been resolved in this session to provide
  /// immediate UI feedback while the provider refreshes.
  final Set<String> _resolvedIds = {};

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final settingsAsync = ref.watch(settingsStreamProvider);

    // Determine the logical date whose tasks need resolution.
    final date = settingsAsync.whenOrNull(
      data: (settings) => resolveLogicalDate(
        now,
        settings.bedtime.hour,
        settings.bedtime.minute,
      ),
    );

    // Fallback to yesterday if settings haven't loaded or bedtime logic
    // returns null (shouldn't happen since the guard already checked).
    final resolveDate = date ??
        DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 1));

    final unresolvedAsync = ref.watch(unresolvedTasksProvider(resolveDate));

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resolve Your Day'),
          automaticallyImplyLeading: false,
        ),
        body: unresolvedAsync.when(
          data: (tasks) {
            final remaining = tasks
                .where((t) => !_resolvedIds.contains(t.id))
                .toList();

            if (remaining.isEmpty) {
              // All resolved — allow navigation.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.go(RouteConstants.today);
                }
              });
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: AppColors.success),
                    SizedBox(height: AppSpacing.lg),
                    Text('All tasks resolved!'),
                  ],
                ),
              );
            }

            return _buildTaskList(context, remaining);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Failed to load tasks: $error',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<TodayTask> tasks) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Text(
            '${tasks.length} task${tasks.length == 1 ? '' : 's'} still unresolved. '
            'Choose an action for each one.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: tasks.length,
            itemBuilder: (context, index) => _ResolutionTaskCard(
              task: tasks[index],
              onResolved: () {
                setState(() => _resolvedIds.add(tasks[index].id));
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ResolutionTaskCard extends ConsumerWidget {
  const _ResolutionTaskCard({
    required this.task,
    required this.onResolved,
  });

  final TodayTask task;
  final VoidCallback onResolved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final priorityColors =
        AppColors.priorityColors(task.priority, theme.brightness);
    final hasPriorityBorder = priorityColors.border != Colors.transparent;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: hasPriorityBorder
            ? BorderSide(color: priorityColors.border, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task title + type badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (task.isDailyInstance)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: AppRadius.fullAll,
                    ),
                    child: Text(
                      'Daily',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
              ],
            ),

            // Labels
            if (task.labels.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                children: task.labels
                    .map(
                      (label) => Chip(
                        label: Text(label),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.check_circle_outline,
                    label: 'Done',
                    color: AppColors.success,
                    onPressed: () async {
                      await ref
                          .read(resolutionActionsProvider.notifier)
                          .markDone(task);
                      onResolved();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.arrow_forward,
                    label: task.isDailyInstance ? 'Skip' : 'Tomorrow',
                    color: theme.colorScheme.primary,
                    onPressed: () async {
                      await ref
                          .read(resolutionActionsProvider.notifier)
                          .moveToTomorrow(task);
                      onResolved();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.close,
                    label: 'Close',
                    color: AppColors.error,
                    onPressed: () async {
                      await ref
                          .read(resolutionActionsProvider.notifier)
                          .close(task);
                      onResolved();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.sm,
        ),
      ),
    );
  }
}
