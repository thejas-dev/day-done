// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backlog_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$backlogTasksHash() => r'277baa7b2a2a566f63a97fe5d6898ff62ce086f5';

/// Watches all dated tasks sorted by date ascending, priority descending.
/// The UI filters to future dates and groups by date.
///
/// Copied from [backlogTasks].
@ProviderFor(backlogTasks)
final backlogTasksProvider =
    AutoDisposeStreamProvider<List<TaskModel>>.internal(
      backlogTasks,
      name: r'backlogTasksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$backlogTasksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BacklogTasksRef = AutoDisposeStreamProviderRef<List<TaskModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
