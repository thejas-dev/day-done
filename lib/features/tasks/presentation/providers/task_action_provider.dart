import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/features/tasks/data/task_repository.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_model.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';

part 'task_action_provider.g.dart';

@riverpod
class TaskActions extends _$TaskActions {
  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<TaskModel?> createTask({
    required String title,
    String? notes,
    required TaskType type,
    DateTime? date,
    Priority priority = Priority.none,
    List<String> labels = const [],
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final task = await _repo.createTask(
        title: title,
        notes: notes,
        type: type,
        date: date,
        priority: priority,
        labels: labels,
      );
      // For daily tasks, immediately create today's instance so it appears
      // on the Today screen without requiring an app restart.
      if (type == TaskType.daily) {
        await _repo.instantiateDailyTasks(DateTime.now());
      }
      return task;
    });
    state = result.whenData((_) {});
    return result.valueOrNull;
  }

  Future<TaskModel?> updateTask({
    required String id,
    String? title,
    String? notes,
    DateTime? date,
    Priority? priority,
    List<String>? labels,
    bool clearNotes = false,
    bool clearDate = false,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => _repo.updateTask(
          id: id,
          title: title,
          notes: notes,
          date: date,
          priority: priority,
          labels: labels,
          clearNotes: clearNotes,
          clearDate: clearDate,
        ));
    state = result.whenData((_) {});
    return result.valueOrNull;
  }

  Future<void> deleteTask(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.deleteTask(id));
  }

  Future<void> markDone(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.markTaskDone(id));
  }

  Future<void> markClosed(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.markTaskClosed(id));
  }

  Future<void> snooze(String id, DateTime snoozeUntil) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.snoozeTask(id, snoozeUntil));
  }

  /// Move a dated task's due date, or skip today's daily instance / bump dated to tomorrow.
  Future<void> rescheduleTask(String taskId, DateTime newDate) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.rescheduleTask(taskId, newDate));
  }

  /// "Skip today" — daily: close today's instance; dated: roll due date to tomorrow.
  Future<void> skipToday(TodayTask task) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (task.isDailyInstance) {
        await _repo.markDailyInstanceClosed(task.id);
      } else {
        final n = DateTime.now().add(const Duration(days: 1));
        await _repo.rescheduleTask(
          task.taskId,
          DateTime(n.year, n.month, n.day),
        );
      }
    });
  }

  Future<void> undoDone(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.undoTaskDone(id));
  }

  Future<void> updatePriority(String id, Priority priority) async {
    state = const AsyncLoading();
    state =
        await AsyncValue.guard(() => _repo.updateTaskPriority(id, priority));
  }

  Future<void> updateLabels(String id, List<String> labels) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.updateTaskLabels(id, labels));
  }

  // ── Daily instance actions ───────────────────────────────────────────────

  Future<void> markDailyInstanceDone(String instanceId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _repo.markDailyInstanceDone(instanceId));
  }

  Future<void> markDailyInstanceClosed(String instanceId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _repo.markDailyInstanceClosed(instanceId));
  }

  Future<void> snoozeDailyInstance(
      String instanceId, DateTime snoozeUntil) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _repo.snoozeDailyInstance(instanceId, snoozeUntil));
  }

  Future<void> undoDailyInstanceDone(String instanceId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _repo.undoDailyInstanceDone(instanceId));
  }
}
