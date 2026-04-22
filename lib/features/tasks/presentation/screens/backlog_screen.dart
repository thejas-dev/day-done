import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/widgets/section_header.dart';
import 'package:todo_tracker/features/tasks/domain/task_model.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/backlog_provider.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/filter_chip_bar.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/task_tile.dart';

/// Shows future dated tasks grouped by date ascending.
/// Includes a filter chip bar for priority/label filtering.
class BacklogScreen extends ConsumerStatefulWidget {
  const BacklogScreen({super.key});

  @override
  ConsumerState<BacklogScreen> createState() => _BacklogScreenState();
}

class _BacklogScreenState extends ConsumerState<BacklogScreen> {
  TaskFilter _filter = const TaskFilter();

  @override
  Widget build(BuildContext context) {
    final backlogAsync = ref.watch(backlogTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backlog')),
      body: backlogAsync.when(
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

  Widget _buildContent(BuildContext context, List<TaskModel> allDatedTasks) {
    final now = DateTime.now();
    final todayEnd = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));

    // Future tasks (tomorrow+) and null-date backlog tasks
    final futureTasks = allDatedTasks.where((task) {
      if (task.date == null) return true; // include null-date backlog tasks
      return !task.date!.isBefore(todayEnd); // exclude today
    }).toList();

    if (futureTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No upcoming tasks',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Dated tasks will appear here',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Convert to TodayTask for filter compatibility and TaskTile reuse
    final allTodayTasks = futureTasks.map(TodayTask.fromDatedTask).toList();
    final filteredTasks = _filter.apply(allTodayTasks);

    // Separate null-date tasks from dated tasks
    final noDateTasks = <TodayTask>[];
    final grouped = <DateTime, List<TodayTask>>{};
    for (final task in filteredTasks) {
      final model = futureTasks.firstWhere((m) => m.id == task.id);
      if (model.date == null) {
        noDateTasks.add(task);
      } else {
        final dateKey = DateTime(
          model.date!.year,
          model.date!.month,
          model.date!.day,
        );
        grouped.putIfAbsent(dateKey, () => []).add(task);
      }
    }

    final sortedDates = grouped.keys.toList()..sort();

    return CustomScrollView(
      slivers: [
        // Filter chip bar (uses all future tasks, unfiltered)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: FilterChipBar(
              tasks: allTodayTasks,
              onFilterChanged: (filter) {
                setState(() => _filter = filter);
              },
            ),
          ),
        ),

        if (filteredTasks.isEmpty && allTodayTasks.isNotEmpty)
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
          )
        else ...[
          for (final date in sortedDates) ...[
            _DateHeader(date: date),
            SliverList.builder(
              itemCount: grouped[date]!.length,
              itemBuilder: (context, index) =>
                  TaskTile(task: grouped[date]![index]),
            ),
          ],
          if (noDateTasks.isNotEmpty) ...[
            _DateHeader(date: null),
            SliverList.builder(
              itemCount: noDateTasks.length,
              itemBuilder: (context, index) =>
                  TaskTile(task: noDateTasks[index]),
            ),
          ],
        ],

        const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl5)),
      ],
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    String label;
    if (date == null) {
      label = 'No date';
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final dateOnly = DateTime(date!.year, date!.month, date!.day);

      if (dateOnly == today) {
        label = 'Today';
      } else if (dateOnly == tomorrow) {
        label = 'Tomorrow';
      } else {
        label = _formatDate(date!);
      }
    }

    return SliverToBoxAdapter(child: SectionHeaderDS(label: label));
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
