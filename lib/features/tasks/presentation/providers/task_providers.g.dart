// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$taskDaoHash() => r'70fb91b68d1f35a5b484bd5004d64d127bd9cbcd';

/// See also [taskDao].
@ProviderFor(taskDao)
final taskDaoProvider = Provider<TaskDao>.internal(
  taskDao,
  name: r'taskDaoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskDaoRef = ProviderRef<TaskDao>;
String _$taskRepositoryHash() => r'a9da2c9eb4791ca5b27a7b4c12caba2df64baf3d';

/// See also [taskRepository].
@ProviderFor(taskRepository)
final taskRepositoryProvider = Provider<TaskRepository>.internal(
  taskRepository,
  name: r'taskRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskRepositoryRef = ProviderRef<TaskRepository>;
String _$allTasksHash() => r'8c674ba84d8bdbee1803d72b144791c86406936b';

/// Watch all non-deleted tasks.
///
/// Copied from [allTasks].
@ProviderFor(allTasks)
final allTasksProvider = AutoDisposeStreamProvider<List<TaskModel>>.internal(
  allTasks,
  name: r'allTasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllTasksRef = AutoDisposeStreamProviderRef<List<TaskModel>>;
String _$tasksForDateHash() => r'6f23cd55519e3d6f5bec291ee6127359f8190db5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Watch dated tasks for a specific date.
///
/// Copied from [tasksForDate].
@ProviderFor(tasksForDate)
const tasksForDateProvider = TasksForDateFamily();

/// Watch dated tasks for a specific date.
///
/// Copied from [tasksForDate].
class TasksForDateFamily extends Family<AsyncValue<List<TaskModel>>> {
  /// Watch dated tasks for a specific date.
  ///
  /// Copied from [tasksForDate].
  const TasksForDateFamily();

  /// Watch dated tasks for a specific date.
  ///
  /// Copied from [tasksForDate].
  TasksForDateProvider call(DateTime date) {
    return TasksForDateProvider(date);
  }

  @override
  TasksForDateProvider getProviderOverride(
    covariant TasksForDateProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tasksForDateProvider';
}

/// Watch dated tasks for a specific date.
///
/// Copied from [tasksForDate].
class TasksForDateProvider extends AutoDisposeStreamProvider<List<TaskModel>> {
  /// Watch dated tasks for a specific date.
  ///
  /// Copied from [tasksForDate].
  TasksForDateProvider(DateTime date)
    : this._internal(
        (ref) => tasksForDate(ref as TasksForDateRef, date),
        from: tasksForDateProvider,
        name: r'tasksForDateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tasksForDateHash,
        dependencies: TasksForDateFamily._dependencies,
        allTransitiveDependencies:
            TasksForDateFamily._allTransitiveDependencies,
        date: date,
      );

  TasksForDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    Stream<List<TaskModel>> Function(TasksForDateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TasksForDateProvider._internal(
        (ref) => create(ref as TasksForDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TaskModel>> createElement() {
    return _TasksForDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksForDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TasksForDateRef on AutoDisposeStreamProviderRef<List<TaskModel>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _TasksForDateProviderElement
    extends AutoDisposeStreamProviderElement<List<TaskModel>>
    with TasksForDateRef {
  _TasksForDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as TasksForDateProvider).date;
}

String _$distinctLabelsHash() => r'93efc2f6965e7b64ae394c058170c8e7aad33945';

/// All distinct label strings used across tasks.
///
/// Copied from [distinctLabels].
@ProviderFor(distinctLabels)
final distinctLabelsProvider = AutoDisposeFutureProvider<List<String>>.internal(
  distinctLabels,
  name: r'distinctLabelsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$distinctLabelsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DistinctLabelsRef = AutoDisposeFutureProviderRef<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
