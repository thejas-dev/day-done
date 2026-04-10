import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:todo_tracker/core/database/app_database.dart';
import 'package:todo_tracker/core/database/tables/daily_instances_table.dart';
import 'package:todo_tracker/core/database/tables/tasks_table.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks, DailyInstances])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  // ── Basic watches ───────────────────────────────────────────────────────

  /// Watch all non-deleted tasks ordered by sortOrder.
  Stream<List<Task>> watchAllTasks() {
    return (select(tasks)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  /// Watch tasks for a specific date (dated tasks due on [date]).
  Stream<List<Task>> watchTasksForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(tasks)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                t.type.equalsValue(TaskType.dated) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.priority),
            (t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .watch();
  }

  /// Watch tasks sorted by priority (urgent→none), then sort_order.
  Stream<List<Task>> watchTasksByPriority() {
    return (select(tasks)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.priority),
            (t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .watch();
  }

  /// Watch tasks that have a given label (case-insensitive JSON search).
  Stream<List<Task>> watchTasksByLabel(String label) {
    // JSON array contains the label — use LIKE for simple prefix match
    final lowerLabel = label.toLowerCase();
    return (select(tasks)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                t.labels.lower().like('%"$lowerLabel"%'),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.priority),
            (t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .watch();
  }

  /// Get all distinct label strings used across non-deleted tasks.
  Future<List<String>> getDistinctLabels() async {
    final rows = await (select(tasks)
          ..where((t) => t.isDeleted.equals(false)))
        .map((row) => row.labels)
        .get();

    final labelSet = <String>{};
    for (final jsonStr in rows) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is String && item.isNotEmpty) {
              labelSet.add(item);
            }
          }
        }
      } catch (_) {
        // skip malformed rows
      }
    }
    return labelSet.toList()..sort();
  }

  // ── Daily instances ─────────────────────────────────────────────────────

  /// Watch all DailyInstances for a given date joined with their template tasks.
  Stream<List<DailyInstanceWithTask>> watchDailyInstancesForDate(
      DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final query = select(dailyInstances).join([
      innerJoin(tasks, tasks.id.equalsExp(dailyInstances.taskId)),
    ])
      ..where(
        dailyInstances.date.isBiggerOrEqualValue(start) &
            dailyInstances.date.isSmallerThanValue(end) &
            tasks.isDeleted.equals(false),
      )
      ..orderBy([
        OrderingTerm.desc(dailyInstances.priority),
        OrderingTerm.asc(tasks.sortOrder),
      ]);

    return query.watch().map((rows) => rows
        .map(
          (row) => DailyInstanceWithTask(
            instance: row.readTable(dailyInstances),
            task: row.readTable(tasks),
          ),
        )
        .toList());
  }

  /// Ensure a DailyInstance exists for every active daily task on [date].
  /// Idempotent — skips tasks that already have an instance for that date.
  Future<void> instantiateDailyTasks(
    DateTime date,
    String Function() idGenerator,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    // All active daily template tasks
    final templates = await (select(tasks)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                t.type.equalsValue(TaskType.daily),
          ))
        .get();

    for (final template in templates) {
      // Check if instance already exists
      final existing = await (select(dailyInstances)
            ..where(
              (d) =>
                  d.taskId.equals(template.id) &
                  d.date.isBiggerOrEqualValue(start) &
                  d.date.isSmallerThanValue(end),
            ))
          .getSingleOrNull();

      if (existing == null) {
        await into(dailyInstances).insert(
          DailyInstancesCompanion.insert(
            id: idGenerator(),
            taskId: template.id,
            date: start,
            status: TaskStatus.pending,
          ),
        );
      }
    }
  }

  // ── Single task operations ───────────────────────────────────────────────

  Future<Task?> getTaskById(String id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertTask(TasksCompanion companion) async {
    await into(tasks).insert(companion);
  }

  Future<void> updateTask(TasksCompanion companion) async {
    await (update(tasks)..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
  }

  /// Soft-delete a task.
  Future<void> deleteTask(String id) async {
    await (update(tasks)..where((t) => t.id.equals(id)))
        .write(const TasksCompanion(isDeleted: Value(true)));
  }

  // ── Status mutations (always via DAO) ───────────────────────────────────

  /// Update status for a **dated** task only.
  /// For daily tasks, use [updateDailyInstanceStatus] instead.
  Future<void> updateTaskStatus(
    String id,
    TaskStatus status, {
    DateTime? resolvedAt,
    DateTime? snoozeUntil,
  }) async {
    final rows = await (update(tasks)
          ..where((t) =>
              t.id.equals(id) &
              t.type.equals(TaskType.dated.index)))
        .write(
      TasksCompanion(
        status: Value(status),
        resolvedAt: Value(resolvedAt),
        snoozeUntil: Value(snoozeUntil),
      ),
    );
    assert(rows > 0, 'updateTaskStatus called on a daily template or missing task: $id');
  }

  Future<void> updateDailyInstanceStatus(
    String instanceId,
    TaskStatus status, {
    DateTime? resolvedAt,
    DateTime? snoozeUntil,
  }) async {
    await (update(dailyInstances)
          ..where((d) => d.id.equals(instanceId)))
        .write(
      DailyInstancesCompanion(
        status: Value(status),
        resolvedAt: Value(resolvedAt),
        snoozeUntil: Value(snoozeUntil),
      ),
    );
  }

  // ── Priority & labels (editable from any status) ─────────────────────────

  Future<void> updateTaskPriority(String id, Priority priority) async {
    await (update(tasks)..where((t) => t.id.equals(id)))
        .write(TasksCompanion(priority: Value(priority)));
  }

  Future<void> updateTaskLabels(String id, List<String> labels) async {
    await (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(labels: Value(jsonEncode(labels))),
    );
  }

  Future<void> updateDailyInstancePriority(
      String instanceId, Priority priority) async {
    await (update(dailyInstances)
          ..where((d) => d.id.equals(instanceId)))
        .write(DailyInstancesCompanion(priority: Value(priority)));
  }

  Future<void> updateDailyInstanceLabels(
      String instanceId, List<String> labels) async {
    await (update(dailyInstances)
          ..where((d) => d.id.equals(instanceId)))
        .write(DailyInstancesCompanion(labels: Value(jsonEncode(labels))));
  }

  // ── Calendar & Backlog ────────────────────────────────────────────────────

  /// Watch all dated tasks sorted by date ascending, then priority descending.
  Stream<List<Task>> watchAllDatedTasks() {
    return (select(tasks)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                t.type.equalsValue(TaskType.dated) &
                t.date.isNotNull(),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.date),
            (t) => OrderingTerm.desc(t.priority),
            (t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .watch();
  }

  /// Returns a stream of task counts per date for a given month.
  /// Combines dated task counts and daily instance counts.
  Stream<Map<DateTime, int>> watchTaskCountsForMonth(
      int year, int month) {
    final start = DateTime(year, month, 1);
    final end = (month < 12) ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);

    // Dated tasks in this month
    final datedQuery = select(tasks)
      ..where(
        (t) =>
            t.isDeleted.equals(false) &
            t.type.equalsValue(TaskType.dated) &
            t.date.isBiggerOrEqualValue(start) &
            t.date.isSmallerThanValue(end),
      );

    // Daily instances in this month
    final dailyQuery = select(dailyInstances).join([
      innerJoin(tasks, tasks.id.equalsExp(dailyInstances.taskId)),
    ])
      ..where(
        dailyInstances.date.isBiggerOrEqualValue(start) &
            dailyInstances.date.isSmallerThanValue(end) &
            tasks.isDeleted.equals(false),
      );

    // Combine both streams using combineLatest pattern.
    final datedStream = datedQuery.watch();
    final dailyStream = dailyQuery.watch();

    final controller = StreamController<Map<DateTime, int>>();
    List<Task>? latestDated;
    List<TypedResult>? latestDaily;

    void emit() {
      if (latestDated == null || latestDaily == null) return;
      final counts = <DateTime, int>{};

      for (final task in latestDated!) {
        if (task.date != null) {
          final dateKey = DateTime(
              task.date!.year, task.date!.month, task.date!.day);
          counts[dateKey] = (counts[dateKey] ?? 0) + 1;
        }
      }

      for (final row in latestDaily!) {
        final instance = row.readTable(dailyInstances);
        final dateKey = DateTime(
            instance.date.year, instance.date.month, instance.date.day);
        counts[dateKey] = (counts[dateKey] ?? 0) + 1;
      }

      controller.add(counts);
    }

    final sub1 = datedStream.listen(
      (data) { latestDated = data; emit(); },
      onError: controller.addError,
    );
    final sub2 = dailyStream.listen(
      (data) { latestDaily = data; emit(); },
      onError: controller.addError,
    );

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
    };

    return controller.stream;
  }

  // ── Sort order ───────────────────────────────────────────────────────────

  Future<void> updateSortOrder(String id, int sortOrder) async {
    await (update(tasks)..where((t) => t.id.equals(id)))
        .write(TasksCompanion(sortOrder: Value(sortOrder)));
  }

  // ── Resolution (end-of-day) ─────────────────────────────────────────────

  /// Get all unresolved dated tasks for [date] (pending or snoozed).
  Future<List<Task>> getUnresolvedDatedTasks(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return (select(tasks)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                t.type.equalsValue(TaskType.dated) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end) &
                (t.status.equalsValue(TaskStatus.pending) |
                    t.status.equalsValue(TaskStatus.snoozed)),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.priority),
            (t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .get();
  }

  /// Get all unresolved daily instances for [date] (pending or snoozed),
  /// joined with their template tasks.
  Future<List<DailyInstanceWithTask>> getUnresolvedDailyInstances(
      DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final query = select(dailyInstances).join([
      innerJoin(tasks, tasks.id.equalsExp(dailyInstances.taskId)),
    ])
      ..where(
        dailyInstances.date.isBiggerOrEqualValue(start) &
            dailyInstances.date.isSmallerThanValue(end) &
            tasks.isDeleted.equals(false) &
            (dailyInstances.status.equalsValue(TaskStatus.pending) |
                dailyInstances.status.equalsValue(TaskStatus.snoozed)),
      )
      ..orderBy([
        OrderingTerm.desc(dailyInstances.priority),
        OrderingTerm.asc(tasks.sortOrder),
      ]);

    final rows = await query.get();
    return rows
        .map(
          (row) => DailyInstanceWithTask(
            instance: row.readTable(dailyInstances),
            task: row.readTable(tasks),
          ),
        )
        .toList();
  }

  /// Reschedule a **dated** task to a new date.
  /// Daily tasks cannot be rescheduled — their instances are date-bound.
  Future<void> rescheduleTask(String id, DateTime newDate) async {
    final rows = await (update(tasks)
          ..where((t) =>
              t.id.equals(id) &
              t.type.equals(TaskType.dated.index)))
        .write(
      TasksCompanion(
        date: Value(newDate),
        status: const Value(TaskStatus.pending),
        resolvedAt: const Value(null),
        snoozeUntil: const Value(null),
      ),
    );
    assert(rows > 0, 'rescheduleTask called on a daily template or missing task: $id');
  }
}

/// Value object pairing a DailyInstance with its template Task.
class DailyInstanceWithTask {
  final DailyInstance instance;
  final Task task;

  const DailyInstanceWithTask({
    required this.instance,
    required this.task,
  });
}
