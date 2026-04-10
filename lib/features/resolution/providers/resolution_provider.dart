import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';

part 'resolution_provider.g.dart';

/// Fetches all unresolved tasks (dated + daily instances) for a given date.
@riverpod
Future<List<TodayTask>> unresolvedTasks(Ref ref, DateTime date) async {
  final repo = ref.watch(taskRepositoryProvider);

  final datedTasks = await repo.getUnresolvedDatedTasks(date);
  final dailyInstances = await repo.getUnresolvedDailyInstances(date);

  final result = <TodayTask>[];

  for (final task in datedTasks) {
    result.add(TodayTask.fromDatedTask(task));
  }

  for (final diWithTask in dailyInstances) {
    result.add(TodayTask.fromDailyInstance(diWithTask));
  }

  return result;
}

/// Actions for resolving tasks in the end-of-day resolution screen.
@riverpod
class ResolutionActions extends _$ResolutionActions {
  @override
  void build() {
    // Side-effect-only notifier.
  }

  /// Mark a task as done. For daily instances, resolves the instance.
  Future<void> markDone(TodayTask task) async {
    final repo = ref.read(taskRepositoryProvider);
    if (task.isDailyInstance) {
      await repo.markDailyInstanceDone(task.id);
    } else {
      await repo.markTaskDone(task.id);
    }
  }

  /// Move a dated task to tomorrow. For daily instances, mark as closed
  /// (the next day's instance will be auto-created).
  Future<void> moveToTomorrow(TodayTask task) async {
    final repo = ref.read(taskRepositoryProvider);
    if (task.isDailyInstance) {
      // Daily tasks auto-create tomorrow's instance; close today's.
      await repo.markDailyInstanceClosed(task.id);
    } else {
      // Dated task: reschedule to tomorrow.
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      await repo.rescheduleTask(task.id, tomorrowDate);
    }
  }

  /// Close a task (won't do it, remove from today).
  Future<void> close(TodayTask task) async {
    final repo = ref.read(taskRepositoryProvider);
    if (task.isDailyInstance) {
      await repo.markDailyInstanceClosed(task.id);
    } else {
      await repo.markTaskClosed(task.id);
    }
  }
}
