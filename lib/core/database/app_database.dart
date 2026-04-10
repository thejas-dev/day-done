import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:todo_tracker/core/database/daos/settings_dao.dart';
import 'package:todo_tracker/core/database/daos/task_dao.dart';
import 'package:todo_tracker/core/database/tables/daily_instances_table.dart';
import 'package:todo_tracker/core/database/tables/settings_table.dart';
import 'package:todo_tracker/core/database/tables/sync_queue_table.dart';
import 'package:todo_tracker/core/database/tables/tasks_table.dart';
import 'package:todo_tracker/features/settings/domain/notification_mode.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Tasks, DailyInstances, Settings, SyncQueue], daos: [SettingsDao, TaskDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'app.db');
  }

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 5) {
            await customStatement(
              'ALTER TABLE daily_instances ADD COLUMN snooze_until INTEGER',
            );
          }
        },
      );
}
