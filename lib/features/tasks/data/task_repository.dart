import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:todo_tracker/core/database/app_database.dart';
import 'package:todo_tracker/core/database/daos/task_dao.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_model.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';
import 'package:uuid/uuid.dart';

/// Bridges [TaskDao] ↔ [TaskModel].
/// All DB mutations go through this repository.
class TaskRepository {
  TaskRepository(this._dao);

  final TaskDao _dao;
  final _uuid = const Uuid();

  // ── Watch streams ────────────────────────────────────────────────────────

  Stream<List<TaskModel>> watchAllTasks() {
    return _dao.watchAllTasks().map(
          (rows) => rows.map(TaskModel.fromRow).toList(),
        );
  }

  Stream<List<TaskModel>> watchTasksForDate(DateTime date) {
    return _dao.watchTasksForDate(date).map(
          (rows) => rows.map(TaskModel.fromRow).toList(),
        );
  }

  Stream<List<TaskModel>> watchTasksByPriority() {
    return _dao.watchTasksByPriority().map(
          (rows) => rows.map(TaskModel.fromRow).toList(),
        );
  }

  Stream<List<TaskModel>> watchTasksByLabel(String label) {
    return _dao.watchTasksByLabel(label).map(
          (rows) => rows.map(TaskModel.fromRow).toList(),
        );
  }

  Stream<List<DailyInstanceWithTask>> watchDailyInstancesForDate(
      DateTime date) {
    return _dao.watchDailyInstancesForDate(date);
  }

  /// Watch all dated tasks sorted by date asc, priority desc.
  Stream<List<TaskModel>> watchAllDatedTasks() {
    return _dao.watchAllDatedTasks().map(
          (rows) => rows.map(TaskModel.fromRow).toList(),
        );
  }

  /// Watch task counts per date for a given month (for calendar dots).
  Stream<Map<DateTime, int>> watchTaskCountsForMonth(int year, int month) {
    return _dao.watchTaskCountsForMonth(year, month);
  }

  // ── Queries ──────────────────────────────────────────────────────────────

  Future<TaskModel?> getTaskById(String id) async {
    final row = await _dao.getTaskById(id);
    return row == null ? null : TaskModel.fromRow(row);
  }

  Future<List<String>> getDistinctLabels() {
    return _dao.getDistinctLabels();
  }

  // ── Create ───────────────────────────────────────────────────────────────

  Future<TaskModel> createTask({
    required String title,
    String? notes,
    required TaskType type,
    DateTime? date,
    Priority priority = Priority.none,
    List<String> labels = const [],
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = TasksCompanion.insert(
      id: id,
      title: title,
      notes: Value(notes),
      type: type,
      date: Value(date),
      status: TaskStatus.pending,
      createdAt: now,
      priority: Value(priority),
      labels: Value(jsonEncode(labels)),
    );

    await _dao.insertTask(companion);
    final row = await _dao.getTaskById(id);
    return TaskModel.fromRow(row!);
  }

  // ── Update ───────────────────────────────────────────────────────────────

  Future<TaskModel> updateTask({
    required String id,
    String? title,
    String? notes,
    DateTime? date,
    Priority? priority,
    List<String>? labels,
    bool clearNotes = false,
    bool clearDate = false,
  }) async {
    final companion = TasksCompanion(
      id: Value(id),
      title: title != null ? Value(title) : const Value.absent(),
      notes: clearNotes
          ? const Value(null)
          : (notes != null ? Value(notes) : const Value.absent()),
      date: clearDate
          ? const Value(null)
          : (date != null ? Value(date) : const Value.absent()),
      priority: priority != null ? Value(priority) : const Value.absent(),
      labels:
          labels != null ? Value(jsonEncode(labels)) : const Value.absent(),
    );

    await _dao.updateTask(companion);
    final row = await _dao.getTaskById(id);
    return TaskModel.fromRow(row!);
  }

  // ── Status mutations ─────────────────────────────────────────────────────

  Future<void> markTaskDone(String id) async {
    await _dao.updateTaskStatus(
      id,
      TaskStatus.done,
      resolvedAt: DateTime.now(),
    );
  }

  Future<void> markTaskClosed(String id) async {
    await _dao.updateTaskStatus(
      id,
      TaskStatus.closed,
      resolvedAt: DateTime.now(),
    );
  }

  Future<void> snoozeTask(String id, DateTime snoozeUntil) async {
    await _dao.updateTaskStatus(
      id,
      TaskStatus.snoozed,
      snoozeUntil: snoozeUntil,
    );
  }

  Future<void> undoTaskDone(String id) async {
    await _dao.updateTaskStatus(id, TaskStatus.pending);
  }

  Future<void> updateTaskPriority(String id, Priority priority) {
    return _dao.updateTaskPriority(id, priority);
  }

  Future<void> updateTaskLabels(String id, List<String> labels) {
    return _dao.updateTaskLabels(id, labels);
  }

  // ── Daily instances ──────────────────────────────────────────────────────

  Future<void> instantiateDailyTasks(DateTime date) {
    return _dao.instantiateDailyTasks(date, _uuid.v4);
  }

  Future<void> markDailyInstanceDone(String instanceId) {
    return _dao.updateDailyInstanceStatus(
      instanceId,
      TaskStatus.done,
      resolvedAt: DateTime.now(),
    );
  }

  Future<void> markDailyInstanceClosed(String instanceId) {
    return _dao.updateDailyInstanceStatus(
      instanceId,
      TaskStatus.closed,
      resolvedAt: DateTime.now(),
    );
  }

  Future<void> snoozeDailyInstance(
      String instanceId, DateTime snoozeUntil) async {
    await _dao.updateDailyInstanceStatus(
      instanceId,
      TaskStatus.snoozed,
      snoozeUntil: snoozeUntil,
    );
  }

  Future<void> undoDailyInstanceDone(String instanceId) {
    return _dao.updateDailyInstanceStatus(instanceId, TaskStatus.pending);
  }

  Future<void> updateDailyInstancePriority(
      String instanceId, Priority priority) {
    return _dao.updateDailyInstancePriority(instanceId, priority);
  }

  Future<void> updateDailyInstanceLabels(
      String instanceId, List<String> labels) {
    return _dao.updateDailyInstanceLabels(instanceId, labels);
  }

  // ── Resolution (end-of-day) ───────────────────────────────────────────────

  Future<List<TaskModel>> getUnresolvedDatedTasks(DateTime date) async {
    final rows = await _dao.getUnresolvedDatedTasks(date);
    return rows.map(TaskModel.fromRow).toList();
  }

  Future<List<DailyInstanceWithTask>> getUnresolvedDailyInstances(
      DateTime date) {
    return _dao.getUnresolvedDailyInstances(date);
  }

  Future<void> rescheduleTask(String id, DateTime newDate) {
    return _dao.rescheduleTask(id, newDate);
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteTask(String id) {
    return _dao.deleteTask(id);
  }

  // ── Sort order ───────────────────────────────────────────────────────────

  Future<void> updateSortOrder(String id, int sortOrder) {
    return _dao.updateSortOrder(id, sortOrder);
  }
}
