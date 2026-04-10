import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_tracker/core/constants/route_constants.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/today_tasks_provider.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/filter_chip_bar.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/task_tile.dart';

/// The main Today screen showing all tasks grouped by status.
///
/// Groups: Pending, Snoozed, Done, Closed.
/// Includes a filter chip bar at top (hidden when irrelevant).
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  TaskFilter _filter = const TaskFilter();

  @override
  Widget build(BuildContext context) {
    final todayTasksAsync = ref.watch(todayTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RouteConstants.settings),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(RouteConstants.taskCreate),
          ),
        ],
      ),
      body: todayTasksAsync.when(
        data: (tasks) => _buildContent(context, tasks),
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
    );
  }

  Widget _buildContent(BuildContext context, List<TodayTask> allTasks) {
    if (allTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No tasks for today',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap + to add a task',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final filteredTasks = _filter.apply(allTasks);

    // Group tasks by status
    final pending =
        filteredTasks.where((t) => t.status == TaskStatus.pending).toList();
    final snoozed =
        filteredTasks.where((t) => t.status == TaskStatus.snoozed).toList();
    final done =
        filteredTasks.where((t) => t.status == TaskStatus.done).toList();
    final closed =
        filteredTasks.where((t) => t.status == TaskStatus.closed).toList();

    return CustomScrollView(
      slivers: [
        // Filter chip bar (uses unfiltered list to compute available filters)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.sm,
            ),
            child: FilterChipBar(
              tasks: allTasks,
              onFilterChanged: (filter) {
                setState(() => _filter = filter);
              },
            ),
          ),
        ),

        // Pending section
        if (pending.isNotEmpty) ...[
          _SectionHeader(
            title: 'Pending',
            count: pending.length,
          ),
          _TaskSliverList(tasks: pending),
        ],

        // Snoozed section
        if (snoozed.isNotEmpty) ...[
          _SectionHeader(
            title: 'Snoozed',
            count: snoozed.length,
          ),
          _TaskSliverList(tasks: snoozed),
        ],

        // Done section
        if (done.isNotEmpty) ...[
          _SectionHeader(
            title: 'Done',
            count: done.length,
          ),
          _TaskSliverList(tasks: done),
        ],

        // Closed section
        if (closed.isNotEmpty) ...[
          _SectionHeader(
            title: 'Closed',
            count: closed.length,
          ),
          _TaskSliverList(tasks: closed),
        ],

        // No results after filtering
        if (filteredTasks.isEmpty && allTasks.isNotEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list_off,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No tasks match current filters',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

        // Bottom padding
        const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl5)),
      ],
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(width: AppSpacing.sm),
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
                '$count',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskSliverList extends StatelessWidget {
  const _TaskSliverList({required this.tasks});

  final List<TodayTask> tasks;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) => TaskTile(task: tasks[index]),
    );
  }
}
