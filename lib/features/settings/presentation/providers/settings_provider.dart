import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/core/database/app_database.dart';
import 'package:todo_tracker/core/database/daos/settings_dao.dart';
import 'package:todo_tracker/features/settings/domain/notification_mode.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
SettingsDao settingsDao(Ref ref) {
  return SettingsDao(ref.watch(appDatabaseProvider));
}

/// Stream of the single settings row, reactively updated.
@Riverpod(keepAlive: true)
Stream<Setting> settingsStream(Ref ref) {
  return ref.watch(settingsDaoProvider).watchSettings();
}

/// Notifier for settings mutations (bedtime, morning check-in, notification mode).
@Riverpod(keepAlive: true)
class SettingsActions extends _$SettingsActions {
  @override
  void build() {
    // No state — this is a side-effect-only notifier.
  }

  SettingsDao get _dao => ref.read(settingsDaoProvider);

  Future<void> updateBedtime(DateTime bedtime) async {
    await _dao.updateBedtime(bedtime);
  }

  Future<void> updateMorningCheckin(DateTime morningCheckin) async {
    await _dao.updateMorningCheckin(morningCheckin);
  }

  Future<void> updateNotificationMode(NotificationMode mode) async {
    await _dao.updateNotificationMode(mode);
  }

  Future<void> completeOnboarding() async {
    await _dao.completeOnboarding();
  }

  Future<void> updateNotificationPermissionAsked() async {
    await _dao.updateNotificationPermissionAsked();
  }
}
