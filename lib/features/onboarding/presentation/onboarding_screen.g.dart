// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingPageHash() => r'caa2a535fce96ac98549dad3952810ee132141eb';

/// Tracks the current onboarding page index.
///
/// Copied from [OnboardingPage].
@ProviderFor(OnboardingPage)
final onboardingPageProvider =
    AutoDisposeNotifierProvider<OnboardingPage, int>.internal(
      OnboardingPage.new,
      name: r'onboardingPageProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingPageHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingPage = AutoDisposeNotifier<int>;
String _$onboardingBedtimeIndexHash() =>
    r'dccff9abc2a0c8ece37bef63d6d4fea936a2f575';

/// Tracks the selected bedtime slot index during onboarding.
/// Default: index of 11:00 PM in the bedtime slots list (= index 20).
///
/// Copied from [OnboardingBedtimeIndex].
@ProviderFor(OnboardingBedtimeIndex)
final onboardingBedtimeIndexProvider =
    AutoDisposeNotifierProvider<OnboardingBedtimeIndex, int>.internal(
      OnboardingBedtimeIndex.new,
      name: r'onboardingBedtimeIndexProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingBedtimeIndexHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingBedtimeIndex = AutoDisposeNotifier<int>;
String _$onboardingNotificationModeHash() =>
    r'd90be5de3053ad162855d91f3b04c3700946d3ef';

/// Tracks the selected notification mode during onboarding.
///
/// Copied from [OnboardingNotificationMode].
@ProviderFor(OnboardingNotificationMode)
final onboardingNotificationModeProvider =
    AutoDisposeNotifierProvider<
      OnboardingNotificationMode,
      NotificationMode
    >.internal(
      OnboardingNotificationMode.new,
      name: r'onboardingNotificationModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingNotificationModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingNotificationMode = AutoDisposeNotifier<NotificationMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
