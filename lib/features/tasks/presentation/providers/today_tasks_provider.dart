import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/core/database/daos/task_dao.dart';
import 'package:todo_tracker/features/tasks/domain/task_model.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';

part 'today_tasks_provider.g.dart';

/// Watches all tasks visible on the Today screen: dated tasks for today
/// + daily instances for today. Returns a unified, sorted list.
///
/// Sort order:
///   1. Status group: pending > snoozed > done > closed
///   2. Priority descending: urgent > high > medium > low > none
///   3. sort_order ascending
@riverpod
Stream<List<TodayTask>> todayTasks(Ref ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final today = DateTime.now();

  final datedStream = repo.watchTasksForDate(today);
  final dailyStream = repo.watchDailyInstancesForDate(today);

  // Combine both streams without rxdart using a StreamController.
  final controller = StreamController<List<TodayTask>>();

  List<TaskModel>? latestDated;
  List<DailyInstanceWithTask>? latestDaily;

  void emit() {
    if (latestDated == null || latestDaily == null) return;

    final List<TodayTask> combined = [
      ...latestDated!.map(TodayTask.fromDatedTask),
      ...latestDaily!.map(TodayTask.fromDailyInstance),
    ];

    combined.sort((a, b) {
      // 1. Status group (lower = higher priority)
      final statusCmp = a.statusGroupOrder.compareTo(b.statusGroupOrder);
      if (statusCmp != 0) return statusCmp;

      // 2. Priority descending (higher index = more urgent = sorts first)
      final priorityCmp = b.prioritySortValue.compareTo(a.prioritySortValue);
      if (priorityCmp != 0) return priorityCmp;

      // 3. sort_order ascending
      return a.sortOrder.compareTo(b.sortOrder);
    });

    controller.add(combined);
  }

  final sub1 = datedStream.listen(
    (data) {
      latestDated = data;
      emit();
    },
    onError: controller.addError,
  );

  final sub2 = dailyStream.listen(
    (data) {
      latestDaily = data;
      emit();
    },
    onError: controller.addError,
  );

  ref.onDispose(() {
    sub1.cancel();
    sub2.cancel();
    controller.close();
  });

  return controller.stream;
}
