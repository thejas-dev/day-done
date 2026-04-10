import 'dart:convert';

import 'package:todo_tracker/core/database/app_database.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';

/// Immutable domain model for a task.
/// Constructed from a Drift [Task] row via [TaskModel.fromRow].
class TaskModel {
  final String id;
  final String title;
  final String? notes;
  final TaskType type;
  final DateTime? date;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? snoozeUntil;
  final int sortOrder;
  final Priority priority;
  final List<String> labels;
  final bool isDeleted;

  const TaskModel({
    required this.id,
    required this.title,
    this.notes,
    required this.type,
    this.date,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.snoozeUntil,
    required this.sortOrder,
    required this.priority,
    required this.labels,
    required this.isDeleted,
  });

  /// Construct from a Drift-generated [Task] row.
  factory TaskModel.fromRow(Task row) {
    List<String> parsedLabels = [];
    try {
      final decoded = jsonDecode(row.labels);
      if (decoded is List) {
        parsedLabels = decoded.whereType<String>().toList();
      }
    } catch (_) {
      parsedLabels = [];
    }

    return TaskModel(
      id: row.id,
      title: row.title,
      notes: row.notes,
      type: row.type,
      date: row.date,
      status: row.status,
      createdAt: row.createdAt,
      resolvedAt: row.resolvedAt,
      snoozeUntil: row.snoozeUntil,
      sortOrder: row.sortOrder,
      priority: row.priority,
      labels: parsedLabels,
      isDeleted: row.isDeleted,
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? notes,
    TaskType? type,
    DateTime? date,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    DateTime? snoozeUntil,
    int? sortOrder,
    Priority? priority,
    List<String>? labels,
    bool? isDeleted,
    bool clearNotes = false,
    bool clearDate = false,
    bool clearResolvedAt = false,
    bool clearSnoozeUntil = false,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: clearNotes ? null : (notes ?? this.notes),
      type: type ?? this.type,
      date: clearDate ? null : (date ?? this.date),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: clearResolvedAt ? null : (resolvedAt ?? this.resolvedAt),
      snoozeUntil:
          clearSnoozeUntil ? null : (snoozeUntil ?? this.snoozeUntil),
      sortOrder: sortOrder ?? this.sortOrder,
      priority: priority ?? this.priority,
      labels: labels ?? this.labels,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TaskModel) return false;
    return id == other.id &&
        title == other.title &&
        notes == other.notes &&
        type == other.type &&
        date == other.date &&
        status == other.status &&
        createdAt == other.createdAt &&
        resolvedAt == other.resolvedAt &&
        snoozeUntil == other.snoozeUntil &&
        sortOrder == other.sortOrder &&
        priority == other.priority &&
        _labelsEqual(labels, other.labels) &&
        isDeleted == other.isDeleted;
  }

  bool _labelsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        notes,
        type,
        date,
        status,
        createdAt,
        resolvedAt,
        snoozeUntil,
        sortOrder,
        priority,
        Object.hashAll(labels),
        isDeleted,
      );

  @override
  String toString() =>
      'TaskModel(id: $id, title: $title, type: $type, status: $status, '
      'priority: $priority, labels: $labels)';
}
