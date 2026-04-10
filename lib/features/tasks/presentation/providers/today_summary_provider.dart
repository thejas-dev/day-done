import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/today_tasks_provider.dart';

part 'today_summary_provider.g.dart';

/// Summary statistics for today's tasks.
class TodaySummary {
  final int total;
  final int pending;
  final int done;
  final int closed;
  final int snoozed;

  /// Fraction of tasks resolved: (done + closed) / total.
  /// Returns 0.0 when there are no tasks.
  final double completionFraction;

  const TodaySummary({
    required this.total,
    required this.pending,
    required this.done,
    required this.closed,
    required this.snoozed,
    required this.completionFraction,
  });

  const TodaySummary.empty()
      : total = 0,
        pending = 0,
        done = 0,
        closed = 0,
        snoozed = 0,
        completionFraction = 0.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TodaySummary) return false;
    return total == other.total &&
        pending == other.pending &&
        done == other.done &&
        closed == other.closed &&
        snoozed == other.snoozed &&
        completionFraction == other.completionFraction;
  }

  @override
  int get hashCode =>
      Object.hash(total, pending, done, closed, snoozed, completionFraction);

  @override
  String toString() =>
      'TodaySummary(total: $total, pending: $pending, done: $done, '
      'closed: $closed, snoozed: $snoozed, '
      'completion: ${(completionFraction * 100).toStringAsFixed(0)}%)';
}

/// Derived provider that computes summary counts from today's tasks.
@riverpod
TodaySummary todaySummary(Ref ref) {
  final tasksAsync = ref.watch(todayTasksProvider);

  return tasksAsync.when(
    data: (tasks) => _computeSummary(tasks),
    loading: () => const TodaySummary.empty(),
    error: (_, _) => const TodaySummary.empty(),
  );
}

TodaySummary _computeSummary(List<TodayTask> tasks) {
  if (tasks.isEmpty) return const TodaySummary.empty();

  int pending = 0;
  int done = 0;
  int closed = 0;
  int snoozed = 0;

  for (final task in tasks) {
    switch (task.status) {
      case TaskStatus.pending:
        pending++;
      case TaskStatus.done:
        done++;
      case TaskStatus.closed:
        closed++;
      case TaskStatus.snoozed:
        snoozed++;
    }
  }

  final total = tasks.length;
  final completionFraction = total > 0 ? (done + closed) / total : 0.0;

  return TodaySummary(
    total: total,
    pending: pending,
    done: done,
    closed: closed,
    snoozed: snoozed,
    completionFraction: completionFraction,
  );
}
