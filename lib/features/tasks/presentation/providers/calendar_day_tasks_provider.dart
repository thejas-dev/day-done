import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/core/database/daos/task_dao.dart';
import 'package:todo_tracker/features/tasks/domain/task_model.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';

part 'calendar_day_tasks_provider.g.dart';

/// Watches all tasks for a given [date]: dated tasks + daily instances.
/// Returns a unified, sorted list — same pattern as todayTasksProvider
/// but parameterized by date.
@riverpod
Stream<List<TodayTask>> calendarDayTasks(Ref ref, DateTime date) {
  final repo = ref.watch(taskRepositoryProvider);

  final datedStream = repo.watchTasksForDate(date);
  final dailyStream = repo.watchDailyInstancesForDate(date);

  final controller = StreamController<List<TodayTask>>();

  List<TaskModel>? latestDated;
  List<DailyInstanceWithTask>? latestDaily;

  void emit() {
    if (latestDated == null || latestDaily == null) return;

    final combined = <TodayTask>[
      ...latestDated!.map(TodayTask.fromDatedTask),
      ...latestDaily!.map(TodayTask.fromDailyInstance),
    ];

    combined.sort((a, b) {
      final statusCmp = a.statusGroupOrder.compareTo(b.statusGroupOrder);
      if (statusCmp != 0) return statusCmp;
      final priorityCmp = b.prioritySortValue.compareTo(a.prioritySortValue);
      if (priorityCmp != 0) return priorityCmp;
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
