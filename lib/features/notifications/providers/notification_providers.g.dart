// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationServiceHash() =>
    r'58da87941dbfa08925105dcc4d74091ee38c8593';

/// Singleton [NotificationService] — initialized once, kept alive.
///
/// Copied from [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider = Provider<NotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationServiceRef = ProviderRef<NotificationService>;
String _$notificationSchedulerHash() =>
    r'da7ae505e62e6d73bdc38a272dcc1151ea6c13df';

/// Singleton [NotificationScheduler] — stateless pure logic.
///
/// Copied from [notificationScheduler].
@ProviderFor(notificationScheduler)
final notificationSchedulerProvider = Provider<NotificationScheduler>.internal(
  notificationScheduler,
  name: r'notificationSchedulerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationSchedulerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationSchedulerRef = ProviderRef<NotificationScheduler>;
String _$notificationUtilsHash() => r'2ebfe413111075bce0ffa39d53eca365898fd72b';

/// Singleton [NotificationUtils] — orchestration layer.
///
/// Copied from [notificationUtils].
@ProviderFor(notificationUtils)
final notificationUtilsProvider = Provider<NotificationUtils>.internal(
  notificationUtils,
  name: r'notificationUtilsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationUtilsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationUtilsRef = ProviderRef<NotificationUtils>;
String _$notificationRescheduleTriggerHash() =>
    r'60c0d6acf92874e58555ce9da2bf7a1833a998d5';

/// Watches settings + today summary and triggers a reschedule whenever either
/// changes. This is a keepAlive provider that runs as a side effect.
///
/// Copied from [notificationRescheduleTrigger].
@ProviderFor(notificationRescheduleTrigger)
final notificationRescheduleTriggerProvider = Provider<void>.internal(
  notificationRescheduleTrigger,
  name: r'notificationRescheduleTriggerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationRescheduleTriggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationRescheduleTriggerRef = ProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
