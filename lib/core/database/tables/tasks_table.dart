import 'package:drift/drift.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';

@TableIndex(name: 'idx_tasks_type_status', columns: {#type, #status})
@TableIndex(name: 'idx_tasks_date', columns: {#date})
@TableIndex(name: 'idx_tasks_is_deleted', columns: {#isDeleted})
@TableIndex(name: 'idx_tasks_priority', columns: {#priority})
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(max: 200)();
  TextColumn get notes => text().nullable().withLength(max: 1000)();
  IntColumn get type => intEnum<TaskType>()();
  DateTimeColumn get date => dateTime().nullable()();
  IntColumn get status => intEnum<TaskStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get snoozeUntil => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get priority =>
      intEnum<Priority>().withDefault(const Constant(0))();
  TextColumn get labels => text().withDefault(const Constant('[]'))();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
