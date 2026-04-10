/// Notification IDs — unique per notification type to allow targeted cancel.
abstract class NotificationIds {
  static const int morning = 1000;
  static const int tMinus4h = 2000;
  static const int tMinus2h = 2001;
  static const int tMinus1h = 2002;
  static const int tMinus30m = 2003;
  static const int tMinus10m = 2004;
  static const int bedtime = 3000;
  static const int allDoneEarly = 4000;
}

/// Notification channel configuration for Android.
abstract class NotificationChannels {
  static const String standardId = 'daydone_standard';
  static const String standardName = 'Task Reminders';
  static const String standardDescription =
      'Standard reminders for pending tasks';

  static const String criticalId = 'daydone_critical';
  static const String criticalName = 'Urgent Reminders';
  static const String criticalDescription =
      'High-priority reminders near bedtime that bypass DND';
}

/// Content templates for each notification type.
abstract class NotificationContent {
  // Morning check-in
  static const String morningTitle = 'Good morning!';
  static String morningBody(int count) =>
      'You have $count task${count == 1 ? '' : 's'} today. Let\'s get started!';

  // T-4h
  static const String tMinus4hTitle = 'Heads up';
  static String tMinus4hBody(int count) =>
      '$count task${count == 1 ? '' : 's'} still pending. You have 4 hours.';

  // T-2h
  static const String tMinus2hTitle = 'Time check';
  static String tMinus2hBody(int count) =>
      '$count task${count == 1 ? '' : 's'} remaining. 2 hours until bedtime.';

  // T-1h
  static const String tMinus1hTitle = 'One hour left';
  static String tMinus1hBody(int count) =>
      '$count task${count == 1 ? '' : 's'} still unresolved. Wrap up soon!';

  // T-30m
  static const String tMinus30mTitle = 'Almost bedtime';
  static String tMinus30mBody(int count) =>
      '$count task${count == 1 ? '' : 's'} pending. 30 minutes left.';

  // T-10m
  static const String tMinus10mTitle = 'Last call';
  static String tMinus10mBody(int count) =>
      '$count task${count == 1 ? '' : 's'} unresolved. 10 minutes to bedtime!';

  // Bedtime
  static const String bedtimeTitle = 'Bedtime';
  static String bedtimeBody(int count) =>
      '$count task${count == 1 ? '' : 's'} still unresolved. Open DayDone to resolve.';

  // All done early
  static const String allDoneEarlyTitle = 'You\'re done for the day!';
  static const String allDoneEarlyBody =
      'All tasks resolved. Enjoy your evening!';
}

/// Which notification types belong to each mode.
enum NotificationType {
  morning,
  tMinus4h,
  tMinus2h,
  tMinus1h,
  tMinus30m,
  tMinus10m,
  bedtime,
}

/// Defines which notifications fire in each mode.
/// - minimal: bedtime only
/// - standard: morning + T-2h + T-1h + bedtime
/// - persistent: morning + T-4h + T-2h + T-1h + T-30m + T-10m + bedtime
abstract class NotificationModeConfig {
  static const List<NotificationType> minimal = [
    NotificationType.bedtime,
  ];

  static const List<NotificationType> standard = [
    NotificationType.morning,
    NotificationType.tMinus2h,
    NotificationType.tMinus1h,
    NotificationType.bedtime,
  ];

  static const List<NotificationType> persistent = [
    NotificationType.morning,
    NotificationType.tMinus4h,
    NotificationType.tMinus2h,
    NotificationType.tMinus1h,
    NotificationType.tMinus30m,
    NotificationType.tMinus10m,
    NotificationType.bedtime,
  ];
}
