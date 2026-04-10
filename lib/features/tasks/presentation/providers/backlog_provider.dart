import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/features/tasks/domain/task_model.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';

part 'backlog_provider.g.dart';

/// Watches all dated tasks sorted by date ascending, priority descending.
/// The UI filters to future dates and groups by date.
@riverpod
Stream<List<TaskModel>> backlogTasks(Ref ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchAllDatedTasks();
}
