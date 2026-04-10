import 'package:todo_tracker/core/constants/notification_constants.dart';
import 'package:todo_tracker/features/notifications/notification_service.dart';
import 'package:todo_tracker/features/notifications/services/notification_scheduler.dart';
import 'package:todo_tracker/features/settings/domain/notification_mode.dart';

/// Orchestrates notification scheduling: given settings + pending count,
/// computes the schedule via [NotificationScheduler] and applies it via
/// [NotificationService].
class NotificationUtils {
  const NotificationUtils({
    required this.service,
    required this.scheduler,
  });

  final NotificationService service;
  final NotificationScheduler scheduler;

  /// Recompute and reschedule all notifications for today based on current
  /// settings and pending task count.
  Future<void> reschedule({
    required DateTime bedtime,
    required DateTime morningCheckin,
    required NotificationMode mode,
    required int pendingCount,
  }) async {
    final schedule = scheduler.computeSchedule(
      bedtime: bedtime,
      morningCheckin: morningCheckin,
      mode: mode,
      pendingCount: pendingCount,
    );

    await service.scheduleAll(schedule);
  }

  /// Called when all tasks have been resolved. If resolved before T-1h,
  /// cancel all remaining notifications and send a congratulatory message.
  /// If resolved after T-1h, just cancel remaining notifications.
  Future<void> handleAllTasksResolved({
    required DateTime bedtime,
  }) async {
    await service.cancelAll();

    final now = DateTime.now();

    // Resolve bedtime to today
    final bedtimeHour = bedtime.hour;
    final bedtimeMinute = bedtime.minute;
    DateTime bedtimeToday;
    if (bedtimeHour < 6) {
      final tomorrow = DateTime(now.year, now.month, now.day)
          .add(const Duration(days: 1));
      bedtimeToday = DateTime(
          tomorrow.year, tomorrow.month, tomorrow.day,
          bedtimeHour, bedtimeMinute);
    } else {
      bedtimeToday = DateTime(
          now.year, now.month, now.day, bedtimeHour, bedtimeMinute);
    }

    final tMinus1h = bedtimeToday.subtract(const Duration(hours: 1));

    // If resolved before T-1h, send "all done early" notification.
    if (now.isBefore(tMinus1h)) {
      await service.showImmediate(
        id: NotificationIds.allDoneEarly,
        title: NotificationContent.allDoneEarlyTitle,
        body: NotificationContent.allDoneEarlyBody,
      );
    }
  }

  /// Called when bedtime setting changes — immediately reschedule.
  Future<void> onBedtimeChanged({
    required DateTime newBedtime,
    required DateTime morningCheckin,
    required NotificationMode mode,
    required int pendingCount,
  }) async {
    await reschedule(
      bedtime: newBedtime,
      morningCheckin: morningCheckin,
      mode: mode,
      pendingCount: pendingCount,
    );
  }
}
