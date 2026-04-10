import 'package:drift/drift.dart';
import 'package:todo_tracker/core/database/app_database.dart';
import 'package:todo_tracker/core/database/tables/settings_table.dart';
import 'package:todo_tracker/features/settings/domain/notification_mode.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  /// Watch the single settings row (id = 1).
  /// Ensures a default row exists before watching.
  Stream<Setting> watchSettings() {
    return (select(settings)..where((s) => s.id.equals(1)))
        .watchSingleOrNull()
        .asyncMap((row) async {
      if (row == null) {
        await _ensureDefaults();
        return (select(settings)..where((s) => s.id.equals(1))).getSingle();
      }
      return row;
    });
  }

  /// Get the current settings row, creating defaults if needed.
  Future<Setting> getSettings() async {
    final row = await (select(settings)..where((s) => s.id.equals(1)))
        .getSingleOrNull();
    if (row != null) return row;
    await _ensureDefaults();
    return (select(settings)..where((s) => s.id.equals(1))).getSingle();
  }

  /// Update the user's bedtime.
  Future<void> updateBedtime(DateTime bedtime) async {
    await (update(settings)..where((s) => s.id.equals(1)))
        .write(SettingsCompanion(bedtime: Value(bedtime)));
  }

  /// Update the morning check-in time.
  Future<void> updateMorningCheckin(DateTime morningCheckin) async {
    await (update(settings)..where((s) => s.id.equals(1)))
        .write(SettingsCompanion(morningCheckin: Value(morningCheckin)));
  }

  /// Update the notification mode.
  Future<void> updateNotificationMode(NotificationMode mode) async {
    await (update(settings)..where((s) => s.id.equals(1)))
        .write(SettingsCompanion(notificationMode: Value(mode)));
  }

  /// Mark onboarding as completed.
  Future<void> completeOnboarding() async {
    await (update(settings)..where((s) => s.id.equals(1)))
        .write(const SettingsCompanion(onboardingCompleted: Value(true)));
  }

  /// Mark that we have asked for notification permission.
  Future<void> updateNotificationPermissionAsked() async {
    await (update(settings)..where((s) => s.id.equals(1))).write(
        const SettingsCompanion(notificationPermissionAsked: Value(true)));
  }

  /// Insert default settings row if it doesn't exist yet.
  Future<void> _ensureDefaults() async {
    final existing = await (select(settings)..where((s) => s.id.equals(1)))
        .getSingleOrNull();
    if (existing != null) return;

    // Default bedtime: 11:00 PM today
    final now = DateTime.now();
    final defaultBedtime =
        DateTime(now.year, now.month, now.day, 23, 0);
    // Default morning check-in: 8:00 AM today
    final defaultMorningCheckin =
        DateTime(now.year, now.month, now.day, 8, 0);

    await into(settings).insert(
      SettingsCompanion.insert(
        bedtime: defaultBedtime,
        morningCheckin: defaultMorningCheckin,
        notificationMode: NotificationMode.standard,
      ),
    );
  }
}
