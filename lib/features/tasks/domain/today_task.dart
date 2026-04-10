import 'dart:convert';

import 'package:todo_tracker/core/database/daos/task_dao.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_model.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';

/// A unified view-model for a task shown on the Today screen.
/// Can represent either a dated task or a daily instance (with its template).
class TodayTask {
  /// For dated tasks: the task id. For daily instances: the instance id.
  final String id;

  /// The underlying task id (same as [id] for dated tasks).
  final String taskId;

  /// Display title from the template task.
  final String title;

  /// Notes from the template task.
  final String? notes;

  final TaskType type;
  final TaskStatus status;
  final Priority priority;
  final List<String> labels;
  final int sortOrder;
  final DateTime? snoozeUntil;

  /// Whether this represents a daily instance (true) or a dated task (false).
  final bool isDailyInstance;

  const TodayTask({
    required this.id,
    required this.taskId,
    required this.title,
    this.notes,
    required this.type,
    required this.status,
    required this.priority,
    required this.labels,
    required this.sortOrder,
    this.snoozeUntil,
    required this.isDailyInstance,
  });

  /// Create from a dated [TaskModel].
  factory TodayTask.fromDatedTask(TaskModel task) {
    return TodayTask(
      id: task.id,
      taskId: task.id,
      title: task.title,
      notes: task.notes,
      type: task.type,
      status: task.status,
      priority: task.priority,
      labels: task.labels,
      sortOrder: task.sortOrder,
      snoozeUntil: task.snoozeUntil,
      isDailyInstance: false,
    );
  }

  /// Create from a [DailyInstanceWithTask].
  /// Uses instance-level priority/labels/status, falling back to template.
  factory TodayTask.fromDailyInstance(DailyInstanceWithTask diWithTask) {
    final instance = diWithTask.instance;
    final template = diWithTask.task;

    // Instance can override priority; if null, use template priority.
    final effectivePriority = instance.priority ?? template.priority;

    // Instance can override labels; if null, use template labels.
    List<String> effectiveLabels;
    if (instance.labels != null) {
      try {
        final decoded = jsonDecode(instance.labels!);
        effectiveLabels =
            decoded is List ? decoded.whereType<String>().toList() : [];
      } catch (_) {
        effectiveLabels = [];
      }
    } else {
      try {
        final decoded = jsonDecode(template.labels);
        effectiveLabels =
            decoded is List ? decoded.whereType<String>().toList() : [];
      } catch (_) {
        effectiveLabels = [];
      }
    }

    return TodayTask(
      id: instance.id,
      taskId: template.id,
      title: template.title,
      notes: template.notes,
      type: TaskType.daily,
      status: instance.status,
      priority: effectivePriority,
      labels: effectiveLabels,
      sortOrder: template.sortOrder,
      isDailyInstance: true,
    );
  }

  /// Status group ordering: pending=0, snoozed=1, done=2, closed=3.
  int get statusGroupOrder => switch (status) {
        TaskStatus.pending => 0,
        TaskStatus.snoozed => 1,
        TaskStatus.done => 2,
        TaskStatus.closed => 3,
      };

  /// Priority sort value (higher = more urgent, sorts first).
  int get prioritySortValue => priority.index;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TodayTask) return false;
    return id == other.id &&
        taskId == other.taskId &&
        title == other.title &&
        type == other.type &&
        status == other.status &&
        priority == other.priority &&
        sortOrder == other.sortOrder &&
        isDailyInstance == other.isDailyInstance &&
        _labelsEqual(labels, other.labels);
  }

  static bool _labelsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        id,
        taskId,
        title,
        type,
        status,
        priority,
        sortOrder,
        isDailyInstance,
        Object.hashAll(labels),
      );

  @override
  String toString() =>
      'TodayTask(id: $id, title: $title, status: $status, priority: $priority, '
      'isDailyInstance: $isDailyInstance)';
}
