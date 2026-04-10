import 'package:drift/drift.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/core/database/tables/tasks_table.dart';

@TableIndex(
  name: 'idx_daily_task_date',
  columns: {#taskId, #date},
  unique: true,
)
@TableIndex(name: 'idx_daily_date', columns: {#date})
class DailyInstances extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get status => intEnum<TaskStatus>()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get snoozeUntil => dateTime().nullable()();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
  IntColumn get priority => intEnum<Priority>().nullable()();
  TextColumn get labels => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
