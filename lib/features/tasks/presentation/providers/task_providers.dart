import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/core/database/app_database.dart';
import 'package:todo_tracker/core/database/daos/task_dao.dart';
import 'package:todo_tracker/features/tasks/data/task_repository.dart';
import 'package:todo_tracker/features/tasks/domain/task_model.dart';

part 'task_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
TaskDao taskDao(Ref ref) {
  return ref.watch(appDatabaseProvider).taskDao;
}

@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) {
  return TaskRepository(ref.watch(taskDaoProvider));
}

/// Watch all non-deleted tasks.
@riverpod
Stream<List<TaskModel>> allTasks(Ref ref) {
  return ref.watch(taskRepositoryProvider).watchAllTasks();
}

/// Watch dated tasks for a specific date.
@riverpod
Stream<List<TaskModel>> tasksForDate(Ref ref, DateTime date) {
  return ref.watch(taskRepositoryProvider).watchTasksForDate(date);
}

/// All distinct label strings used across tasks.
@riverpod
Future<List<String>> distinctLabels(Ref ref) {
  return ref.watch(taskRepositoryProvider).getDistinctLabels();
}
