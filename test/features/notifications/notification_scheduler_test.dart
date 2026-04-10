import 'package:flutter_test/flutter_test.dart';
import 'package:todo_tracker/core/constants/notification_constants.dart';
import 'package:todo_tracker/features/notifications/services/notification_scheduler.dart';
import 'package:todo_tracker/features/settings/domain/notification_mode.dart';

void main() {
  late NotificationScheduler scheduler;

  setUp(() {
    scheduler = const NotificationScheduler();
  });

  // Helper: create a bedtime DateTime with just hour/minute.
  DateTime bedtime(int hour, int minute) =>
      DateTime(2026, 4, 5, hour, minute);

  DateTime morning(int hour, int minute) =>
      DateTime(2026, 4, 5, hour, minute);

  group('computeSchedule', () {
    test('returns empty list when pendingCount is 0', () {
      final result = scheduler.computeSchedule(
        bedtime: bedtime(23, 0),
        morningCheckin: morning(8, 0),
        mode: NotificationMode.standard,
        pendingCount: 0,
        now: DateTime(2026, 4, 5, 10, 0),
      );

      expect(result, isEmpty);
    });

    test('returns empty list when pendingCount is negative', () {
      final result = scheduler.computeSchedule(
        bedtime: bedtime(23, 0),
        morningCheckin: morning(8, 0),
        mode: NotificationMode.standard,
        pendingCount: -1,
        now: DateTime(2026, 4, 5, 10, 0),
      );

      expect(result, isEmpty);
    });

    group('minimal mode', () {
      test('only schedules bedtime notification', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(23, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.minimal,
          pendingCount: 3,
          now: DateTime(2026, 4, 5, 10, 0),
        );

        expect(result.length, 1);
        expect(result[0].id, NotificationIds.bedtime);
        expect(result[0].scheduledTime,
            DateTime(2026, 4, 5, 23, 0));
        expect(result[0].isCritical, true);
      });

      test('returns empty when bedtime has passed', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(23, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.minimal,
          pendingCount: 3,
          now: DateTime(2026, 4, 5, 23, 30),
        );

        expect(result, isEmpty);
      });
    });

    group('standard mode', () {
      test('schedules morning + T-2h + T-1h + bedtime', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(23, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.standard,
          pendingCount: 5,
          now: DateTime(2026, 4, 5, 7, 0),
        );

        expect(result.length, 4);

        // Morning at 8:00
        expect(result[0].id, NotificationIds.morning);
        expect(result[0].scheduledTime,
            DateTime(2026, 4, 5, 8, 0));
        expect(result[0].isCritical, false);

        // T-2h at 21:00
        expect(result[1].id, NotificationIds.tMinus2h);
        expect(result[1].scheduledTime,
            DateTime(2026, 4, 5, 21, 0));

        // T-1h at 22:00
        expect(result[2].id, NotificationIds.tMinus1h);
        expect(result[2].scheduledTime,
            DateTime(2026, 4, 5, 22, 0));
        expect(result[2].isCritical, true);

        // Bedtime at 23:00
        expect(result[3].id, NotificationIds.bedtime);
        expect(result[3].scheduledTime,
            DateTime(2026, 4, 5, 23, 0));
      });

      test('filters out past notifications', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(23, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.standard,
          pendingCount: 2,
          now: DateTime(2026, 4, 5, 21, 30),
        );

        // Morning and T-2h are past, only T-1h and bedtime remain
        expect(result.length, 2);
        expect(result[0].id, NotificationIds.tMinus1h);
        expect(result[1].id, NotificationIds.bedtime);
      });
    });

    group('persistent mode', () {
      test('schedules all 7 notification types', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(23, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.persistent,
          pendingCount: 4,
          now: DateTime(2026, 4, 5, 7, 0),
        );

        expect(result.length, 7);

        expect(result[0].id, NotificationIds.morning);
        expect(result[1].id, NotificationIds.tMinus4h);
        expect(result[2].id, NotificationIds.tMinus2h);
        expect(result[3].id, NotificationIds.tMinus1h);
        expect(result[4].id, NotificationIds.tMinus30m);
        expect(result[5].id, NotificationIds.tMinus10m);
        expect(result[6].id, NotificationIds.bedtime);
      });

      test('T-4h is at 19:00 for 23:00 bedtime', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(23, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.persistent,
          pendingCount: 1,
          now: DateTime(2026, 4, 5, 7, 0),
        );

        final t4h = result.firstWhere((n) => n.id == NotificationIds.tMinus4h);
        expect(t4h.scheduledTime, DateTime(2026, 4, 5, 19, 0));
      });

      test('T-30m and T-10m are critical', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(23, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.persistent,
          pendingCount: 1,
          now: DateTime(2026, 4, 5, 7, 0),
        );

        final t30m =
            result.firstWhere((n) => n.id == NotificationIds.tMinus30m);
        final t10m =
            result.firstWhere((n) => n.id == NotificationIds.tMinus10m);
        expect(t30m.isCritical, true);
        expect(t10m.isCritical, true);
      });
    });

    group('bedtime after midnight', () {
      test('handles 1 AM bedtime correctly', () {
        // Bedtime at 1:00 AM — should resolve to tomorrow.
        final result = scheduler.computeSchedule(
          bedtime: bedtime(1, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.standard,
          pendingCount: 2,
          now: DateTime(2026, 4, 5, 10, 0),
        );

        // Bedtime resolves to 2026-04-06 01:00
        final bedtimeNotif =
            result.firstWhere((n) => n.id == NotificationIds.bedtime);
        expect(bedtimeNotif.scheduledTime,
            DateTime(2026, 4, 6, 1, 0));

        // T-1h at midnight (2026-04-06 00:00)
        final t1h =
            result.firstWhere((n) => n.id == NotificationIds.tMinus1h);
        expect(t1h.scheduledTime,
            DateTime(2026, 4, 6, 0, 0));

        // T-2h at 23:00 today
        final t2h =
            result.firstWhere((n) => n.id == NotificationIds.tMinus2h);
        expect(t2h.scheduledTime,
            DateTime(2026, 4, 5, 23, 0));
      });

      test('handles 3 AM bedtime correctly', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(3, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.minimal,
          pendingCount: 1,
          now: DateTime(2026, 4, 5, 10, 0),
        );

        expect(result.length, 1);
        expect(result[0].scheduledTime,
            DateTime(2026, 4, 6, 3, 0));
      });
    });

    group('notification content', () {
      test('body includes correct pending count (singular)', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(23, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.minimal,
          pendingCount: 1,
          now: DateTime(2026, 4, 5, 10, 0),
        );

        expect(result[0].body, contains('1 task'));
        expect(result[0].body, isNot(contains('1 tasks')));
      });

      test('body includes correct pending count (plural)', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(23, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.minimal,
          pendingCount: 5,
          now: DateTime(2026, 4, 5, 10, 0),
        );

        expect(result[0].body, contains('5 tasks'));
      });
    });

    group('sort order', () {
      test('notifications are sorted by scheduled time ascending', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(23, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.persistent,
          pendingCount: 3,
          now: DateTime(2026, 4, 5, 7, 0),
        );

        for (var i = 1; i < result.length; i++) {
          expect(
            result[i].scheduledTime.isAfter(result[i - 1].scheduledTime) ||
                result[i].scheduledTime == result[i - 1].scheduledTime,
            true,
            reason:
                '${result[i].scheduledTime} should be >= ${result[i - 1].scheduledTime}',
          );
        }
      });
    });

    group('edge cases', () {
      test('bedtime 6 PM with standard mode at 5 PM', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(18, 0),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.standard,
          pendingCount: 2,
          now: DateTime(2026, 4, 5, 17, 0),
        );

        // Only T-1h (17:00 is past now) and bedtime remain
        // T-2h = 16:00 (past), morning = 8:00 (past), T-1h = 17:00 (equal = past)
        // Only bedtime at 18:00 should remain
        expect(result.length, 1);
        expect(result[0].id, NotificationIds.bedtime);
      });

      test('15-minute increment bedtime at 10:45 PM', () {
        final result = scheduler.computeSchedule(
          bedtime: bedtime(22, 45),
          morningCheckin: morning(8, 0),
          mode: NotificationMode.standard,
          pendingCount: 1,
          now: DateTime(2026, 4, 5, 7, 0),
        );

        final bedtimeNotif =
            result.firstWhere((n) => n.id == NotificationIds.bedtime);
        expect(bedtimeNotif.scheduledTime,
            DateTime(2026, 4, 5, 22, 45));

        // T-1h at 21:45
        final t1h =
            result.firstWhere((n) => n.id == NotificationIds.tMinus1h);
        expect(t1h.scheduledTime,
            DateTime(2026, 4, 5, 21, 45));
      });
    });
  });
}
