import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

import 'package:todo_tracker/core/database/app_database.dart';
import 'package:todo_tracker/core/database/daos/task_dao.dart';

/// Unique task name for the midnight daily task instantiation.
const _midnightTaskName = 'com.daydone.instantiateDailyTasks';

/// Top-level callback for Workmanager. Runs in its own isolate, so it
/// creates its own database connection.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName == _midnightTaskName ||
          taskName == Workmanager.iOSBackgroundTask) {
        final db = AppDatabase();
        final dao = TaskDao(db);
        final uuid = const Uuid();

        final today = DateTime.now();
        final dateOnly = DateTime(today.year, today.month, today.day);

        await dao.instantiateDailyTasks(dateOnly, () => uuid.v4());
        await db.close();
      }
      return true;
    } catch (e) {
      debugPrint('WorkmanagerService: background task failed: $e');
      return false;
    }
  });
}

/// Handles registration of background tasks via Workmanager.
class WorkmanagerService {
  /// Initialize Workmanager and register the periodic midnight task.
  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    // Register a periodic task that runs approximately every 24 hours.
    // Android minimum periodic interval is 15 minutes; we use 24 hours.
    // The OS will schedule this at roughly midnight each day.
    await Workmanager().registerPeriodicTask(
      _midnightTaskName,
      _midnightTaskName,
      frequency: const Duration(hours: 24),
      initialDelay: _calculateInitialDelay(),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  /// Calculate delay until the next midnight from now.
  static Duration _calculateInitialDelay() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    return nextMidnight.difference(now);
  }
}
