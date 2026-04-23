import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_tracker/core/constants/notification_constants.dart';
import 'package:todo_tracker/features/notifications/services/notification_scheduler.dart';

/// Wraps [FlutterLocalNotificationsPlugin] with DayDone-specific configuration.
/// Handles init, permission requests, channel creation, and scheduling.
class NotificationService {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initFuture;

  /// Initialize the notification plugin with platform-specific settings.
  /// Safe to call multiple times — subsequent calls return the same future.
  Future<void> init() {
    return _initFuture ??= _doInit();
  }

  Future<void> _doInit() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);
    await _createChannels();
  }

  /// Ensures init has completed before proceeding.
  Future<void> _ensureInitialized() async {
    await init();
  }

  /// Request notification permissions from the OS.
  /// Returns true if granted, false otherwise.
  Future<bool> requestPermissions() async {
    await _ensureInitialized();
    if (Platform.isIOS || Platform.isMacOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return false;

      // If notifications are already enabled, no runtime prompt is needed.
      final enabledBeforePrompt = await android.areNotificationsEnabled();
      if (enabledBeforePrompt ?? false) return true;

      final requestResult = await android.requestNotificationsPermission();
      if (requestResult != null) return requestResult;

      // Some Android versions/devices can return null; re-check OS state.
      final enabledAfterPrompt = await android.areNotificationsEnabled();
      return enabledAfterPrompt ?? false;
    }

    return false;
  }

  /// Create Android notification channels (standard + critical).
  Future<void> _createChannels() async {
    if (!Platform.isAndroid) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    // Standard channel
    const standardChannel = AndroidNotificationChannel(
      NotificationChannels.standardId,
      NotificationChannels.standardName,
      description: NotificationChannels.standardDescription,
      importance: Importance.defaultImportance,
    );

    // Critical channel — high importance for near-bedtime notifications
    const criticalChannel = AndroidNotificationChannel(
      NotificationChannels.criticalId,
      NotificationChannels.criticalName,
      description: NotificationChannels.criticalDescription,
      importance: Importance.high,
    );

    await android.createNotificationChannel(standardChannel);
    await android.createNotificationChannel(criticalChannel);
  }

  /// Schedule a single notification.
  Future<void> scheduleNotification(ScheduledNotification notification) async {
    await _ensureInitialized();

    final channelId = notification.isCritical
        ? NotificationChannels.criticalId
        : NotificationChannels.standardId;
    final channelName = notification.isCritical
        ? NotificationChannels.criticalName
        : NotificationChannels.standardName;
    final channelDescription = notification.isCritical
        ? NotificationChannels.criticalDescription
        : NotificationChannels.standardDescription;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: notification.isCritical
          ? Importance.high
          : Importance.defaultImportance,
      priority: notification.isCritical
          ? Priority.high
          : Priority.defaultPriority,
      styleInformation: const DefaultStyleInformation(true, true),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final tzScheduledDate = tz.TZDateTime.from(
      notification.scheduledTime,
      tz.local,
    );

    await _plugin.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      tzScheduledDate,
      details,
      androidScheduleMode: notification.isCritical
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule a list of notifications, cancelling existing ones first.
  Future<void> scheduleAll(List<ScheduledNotification> notifications) async {
    // Avoid cancelAll() before scheduling because some Android devices/builds
    // can have an unreadable persisted cache in the plugin, which makes cancel
    // paths throw and blocks all subsequent scheduling. Reusing stable IDs
    // allows zonedSchedule() to replace existing entries.
    for (final n in notifications) {
      await scheduleNotification(n);
    }
  }

  /// Show an immediate notification (e.g., "all done early").
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    bool isCritical = false,
  }) async {
    await _ensureInitialized();

    final channelId = isCritical
        ? NotificationChannels.criticalId
        : NotificationChannels.standardId;
    final channelName = isCritical
        ? NotificationChannels.criticalName
        : NotificationChannels.standardName;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: isCritical ? Importance.high : Importance.defaultImportance,
      priority: isCritical ? Priority.high : Priority.defaultPriority,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _ensureInitialized();
    try {
      await _plugin.cancelAll();
    } on PlatformException {
      // Workaround: some Android/plugin/device combos can throw when reading
      // persisted scheduled notifications during cancelAll(). Fallback to
      // explicit known IDs so rescheduling can proceed.
      const knownIds = <int>[
        NotificationIds.morning,
        NotificationIds.tMinus4h,
        NotificationIds.tMinus2h,
        NotificationIds.tMinus1h,
        NotificationIds.tMinus30m,
        NotificationIds.tMinus10m,
        NotificationIds.bedtime,
        NotificationIds.allDoneEarly,
      ];
      for (final id in knownIds) {
        try {
          await _plugin.cancel(id);
        } on PlatformException {
          // If cache is unreadable, individual cancel can fail too. Swallow to
          // prevent notification flow from breaking on repeated attempts.
        }
      }
    }
  }

  /// Cancel a specific notification by id.
  Future<void> cancelById(int id) async {
    await _ensureInitialized();
    try {
      await _plugin.cancel(id);
    } on PlatformException {
      // Some plugin cache states can break cancel-by-id on Android.
    }
  }
}
