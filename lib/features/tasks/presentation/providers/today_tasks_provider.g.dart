// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_tasks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayTasksHash() => r'4cd3e8bc866d68df77673b72373e7f01d31c71fb';

/// Watches all tasks visible on the Today screen: dated tasks for today
/// + daily instances for today. Returns a unified, sorted list.
///
/// Sort order:
///   1. Status group: pending > snoozed > done > closed
///   2. Priority descending: urgent > high > medium > low > none
///   3. sort_order ascending
///
/// Copied from [todayTasks].
@ProviderFor(todayTasks)
final todayTasksProvider = AutoDisposeStreamProvider<List<TodayTask>>.internal(
  todayTasks,
  name: r'todayTasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayTasksRef = AutoDisposeStreamProviderRef<List<TodayTask>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
