// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_edit_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskByIdHash() => r'db3bc2a165936bba539fbe013f09edb30989bb62';

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

/// See also [taskById].
@ProviderFor(taskById)
const taskByIdProvider = TaskByIdFamily();

/// See also [taskById].
class TaskByIdFamily extends Family<AsyncValue<TaskModel?>> {
  /// See also [taskById].
  const TaskByIdFamily();

  /// See also [taskById].
  TaskByIdProvider call(String id) {
    return TaskByIdProvider(id);
  }

  @override
  TaskByIdProvider getProviderOverride(covariant TaskByIdProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskByIdProvider';
}

/// See also [taskById].
class TaskByIdProvider extends AutoDisposeFutureProvider<TaskModel?> {
  /// See also [taskById].
  TaskByIdProvider(String id)
    : this._internal(
        (ref) => taskById(ref as TaskByIdRef, id),
        from: taskByIdProvider,
        name: r'taskByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$taskByIdHash,
        dependencies: TaskByIdFamily._dependencies,
        allTransitiveDependencies: TaskByIdFamily._allTransitiveDependencies,
        id: id,
      );

  TaskByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<TaskModel?> Function(TaskByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskByIdProvider._internal(
        (ref) => create(ref as TaskByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TaskModel?> createElement() {
    return _TaskByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskByIdRef on AutoDisposeFutureProviderRef<TaskModel?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TaskByIdProviderElement
    extends AutoDisposeFutureProviderElement<TaskModel?>
    with TaskByIdRef {
  _TaskByIdProviderElement(super.provider);

  @override
  String get id => (origin as TaskByIdProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
