import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';

part 'calendar_provider.g.dart';

/// Watches task counts per date for a given month (year, month).
/// Used for calendar dot indicators.
@riverpod
Stream<Map<DateTime, int>> calendarIndicators(
  Ref ref,
  int year,
  int month,
) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTaskCountsForMonth(year, month);
}
