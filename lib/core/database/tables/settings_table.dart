import 'package:drift/drift.dart';
import 'package:todo_tracker/features/settings/domain/notification_mode.dart';

class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  DateTimeColumn get bedtime => dateTime()();
  DateTimeColumn get morningCheckin => dateTime()();
  IntColumn get notificationMode => intEnum<NotificationMode>()();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get notificationPermissionAsked =>
      boolean().withDefault(const Constant(false))();
  IntColumn get notificationBannerDismissals =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lastBannerDismissedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
