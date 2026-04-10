import 'package:todo_tracker/core/constants/notification_constants.dart';
import 'package:todo_tracker/features/settings/domain/notification_mode.dart';

/// A scheduled notification to be dispatched by the notification service.
/// Pure data — no Flutter dependencies.
class ScheduledNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;

  /// Whether this notification should use the critical/DND-bypass channel.
  final bool isCritical;

  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    this.isCritical = false,
  });

  @override
  String toString() =>
      'ScheduledNotification(id: $id, title: $title, at: $scheduledTime, '
      'critical: $isCritical)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduledNotification) return false;
    return id == other.id &&
        title == other.title &&
        body == other.body &&
        scheduledTime == other.scheduledTime &&
        isCritical == other.isCritical;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, body, scheduledTime, isCritical);
}

/// Pure-logic scheduler: given settings + pending count, returns a list of
/// [ScheduledNotification]s. No Flutter dependencies — fully testable.
class NotificationScheduler {
  const NotificationScheduler();

  /// Compute the notification schedule for today.
  ///
  /// [bedtime] — the user's configured bedtime (hour + minute used).
  /// [morningCheckin] — the user's configured morning check-in time.
  /// [mode] — minimal / standard / persistent.
  /// [pendingCount] — number of unresolved tasks right now.
  /// [now] — current time (injectable for testing).
  ///
  /// Returns an empty list if [pendingCount] is 0.
  List<ScheduledNotification> computeSchedule({
    required DateTime bedtime,
    required DateTime morningCheckin,
    required NotificationMode mode,
    required int pendingCount,
    DateTime? now,
  }) {
    if (pendingCount <= 0) return [];

    final currentTime = now ?? DateTime.now();

    // Resolve bedtime to today's date (or tomorrow if bedtime is after midnight).
    final bedtimeToday = _resolveBedtime(bedtime, currentTime);
    final morningToday = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      morningCheckin.hour,
      morningCheckin.minute,
    );

    // Get the notification types for this mode.
    final types = switch (mode) {
      NotificationMode.minimal => NotificationModeConfig.minimal,
      NotificationMode.standard => NotificationModeConfig.standard,
      NotificationMode.persistent => NotificationModeConfig.persistent,
    };

    final schedule = <ScheduledNotification>[];

    for (final type in types) {
      final notification = _buildNotification(
        type: type,
        bedtime: bedtimeToday,
        morning: morningToday,
        pendingCount: pendingCount,
      );

      if (notification != null && notification.scheduledTime.isAfter(currentTime)) {
        schedule.add(notification);
      }
    }

    // Sort by scheduled time ascending.
    schedule.sort(
        (a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    return schedule;
  }

  /// Resolve bedtime hour/minute to an actual DateTime.
  /// Bedtime range is 6 PM - 3 AM. If hour < 6 (e.g. 1 AM, 2 AM, 3 AM),
  /// it's the next calendar day.
  DateTime _resolveBedtime(DateTime bedtime, DateTime now) {
    final hour = bedtime.hour;
    final minute = bedtime.minute;

    // If bedtime is in the early morning (before 6 AM), it's "tonight"
    // which is actually tomorrow's calendar date.
    if (hour < 6) {
      final tomorrow = DateTime(now.year, now.month, now.day).add(
        const Duration(days: 1),
      );
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, hour, minute);
    }

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  ScheduledNotification? _buildNotification({
    required NotificationType type,
    required DateTime bedtime,
    required DateTime morning,
    required int pendingCount,
  }) {
    return switch (type) {
      NotificationType.morning => ScheduledNotification(
          id: NotificationIds.morning,
          title: NotificationContent.morningTitle,
          body: NotificationContent.morningBody(pendingCount),
          scheduledTime: morning,
        ),
      NotificationType.tMinus4h => ScheduledNotification(
          id: NotificationIds.tMinus4h,
          title: NotificationContent.tMinus4hTitle,
          body: NotificationContent.tMinus4hBody(pendingCount),
          scheduledTime: bedtime.subtract(const Duration(hours: 4)),
        ),
      NotificationType.tMinus2h => ScheduledNotification(
          id: NotificationIds.tMinus2h,
          title: NotificationContent.tMinus2hTitle,
          body: NotificationContent.tMinus2hBody(pendingCount),
          scheduledTime: bedtime.subtract(const Duration(hours: 2)),
        ),
      NotificationType.tMinus1h => ScheduledNotification(
          id: NotificationIds.tMinus1h,
          title: NotificationContent.tMinus1hTitle,
          body: NotificationContent.tMinus1hBody(pendingCount),
          scheduledTime: bedtime.subtract(const Duration(hours: 1)),
          isCritical: true,
        ),
      NotificationType.tMinus30m => ScheduledNotification(
          id: NotificationIds.tMinus30m,
          title: NotificationContent.tMinus30mTitle,
          body: NotificationContent.tMinus30mBody(pendingCount),
          scheduledTime: bedtime.subtract(const Duration(minutes: 30)),
          isCritical: true,
        ),
      NotificationType.tMinus10m => ScheduledNotification(
          id: NotificationIds.tMinus10m,
          title: NotificationContent.tMinus10mTitle,
          body: NotificationContent.tMinus10mBody(pendingCount),
          scheduledTime: bedtime.subtract(const Duration(minutes: 10)),
          isCritical: true,
        ),
      NotificationType.bedtime => ScheduledNotification(
          id: NotificationIds.bedtime,
          title: NotificationContent.bedtimeTitle,
          body: NotificationContent.bedtimeBody(pendingCount),
          scheduledTime: bedtime,
          isCritical: true,
        ),
    };
  }
}
