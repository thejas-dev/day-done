// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsDaoHash() => r'b30250ebab9c676c06089cfa66a65ae8e24456db';

/// See also [settingsDao].
@ProviderFor(settingsDao)
final settingsDaoProvider = Provider<SettingsDao>.internal(
  settingsDao,
  name: r'settingsDaoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsDaoRef = ProviderRef<SettingsDao>;
String _$settingsStreamHash() => r'f652fafaa6575bad3f065999a1187a54f59e81d4';

/// Stream of the single settings row, reactively updated.
///
/// Copied from [settingsStream].
@ProviderFor(settingsStream)
final settingsStreamProvider = StreamProvider<Setting>.internal(
  settingsStream,
  name: r'settingsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsStreamRef = StreamProviderRef<Setting>;
String _$settingsActionsHash() => r'469a388c6fbf9618dbf628bece5f0d9451c68b2f';

/// Notifier for settings mutations (bedtime, morning check-in, notification mode).
///
/// Copied from [SettingsActions].
@ProviderFor(SettingsActions)
final settingsActionsProvider =
    NotifierProvider<SettingsActions, void>.internal(
      SettingsActions.new,
      name: r'settingsActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettingsActions = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
