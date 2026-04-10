import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/core/utils/notification_utils.dart';
import 'package:todo_tracker/features/notifications/notification_service.dart';
import 'package:todo_tracker/features/notifications/services/notification_scheduler.dart';
import 'package:todo_tracker/features/settings/presentation/providers/settings_provider.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/today_summary_provider.dart';

part 'notification_providers.g.dart';

/// Singleton [NotificationService] — initialized once, kept alive.
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  final service = NotificationService();
  // Fire-and-forget initialization.
  service.init();
  return service;
}

/// Singleton [NotificationScheduler] — stateless pure logic.
@Riverpod(keepAlive: true)
NotificationScheduler notificationScheduler(Ref ref) {
  return const NotificationScheduler();
}

/// Singleton [NotificationUtils] — orchestration layer.
@Riverpod(keepAlive: true)
NotificationUtils notificationUtils(Ref ref) {
  return NotificationUtils(
    service: ref.watch(notificationServiceProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
  );
}

/// Watches settings + today summary and triggers a reschedule whenever either
/// changes. This is a keepAlive provider that runs as a side effect.
@Riverpod(keepAlive: true)
void notificationRescheduleTrigger(Ref ref) {
  final settingsAsync = ref.watch(settingsStreamProvider);
  final summary = ref.watch(todaySummaryProvider);

  settingsAsync.whenData((settings) {
    final pendingCount = summary.pending + summary.snoozed;
    final utils = ref.read(notificationUtilsProvider);

    if (pendingCount > 0) {
      utils.reschedule(
        bedtime: settings.bedtime,
        morningCheckin: settings.morningCheckin,
        mode: settings.notificationMode,
        pendingCount: pendingCount,
      );
    } else if (summary.total > 0) {
      // All tasks resolved — handle "all done early" logic.
      utils.handleAllTasksResolved(bedtime: settings.bedtime);
    } else {
      // No tasks at all — cancel everything.
      ref.read(notificationServiceProvider).cancelAll();
    }
  });
}
