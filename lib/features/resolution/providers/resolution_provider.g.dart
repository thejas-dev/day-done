// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolution_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unresolvedTasksHash() => r'80b49a6ca444d49bb335b1d349c6d1859a12da8a';

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

/// Fetches all unresolved tasks (dated + daily instances) for a given date.
///
/// Copied from [unresolvedTasks].
@ProviderFor(unresolvedTasks)
const unresolvedTasksProvider = UnresolvedTasksFamily();

/// Fetches all unresolved tasks (dated + daily instances) for a given date.
///
/// Copied from [unresolvedTasks].
class UnresolvedTasksFamily extends Family<AsyncValue<List<TodayTask>>> {
  /// Fetches all unresolved tasks (dated + daily instances) for a given date.
  ///
  /// Copied from [unresolvedTasks].
  const UnresolvedTasksFamily();

  /// Fetches all unresolved tasks (dated + daily instances) for a given date.
  ///
  /// Copied from [unresolvedTasks].
  UnresolvedTasksProvider call(DateTime date) {
    return UnresolvedTasksProvider(date);
  }

  @override
  UnresolvedTasksProvider getProviderOverride(
    covariant UnresolvedTasksProvider provider,
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
  String? get name => r'unresolvedTasksProvider';
}

/// Fetches all unresolved tasks (dated + daily instances) for a given date.
///
/// Copied from [unresolvedTasks].
class UnresolvedTasksProvider
    extends AutoDisposeFutureProvider<List<TodayTask>> {
  /// Fetches all unresolved tasks (dated + daily instances) for a given date.
  ///
  /// Copied from [unresolvedTasks].
  UnresolvedTasksProvider(DateTime date)
    : this._internal(
        (ref) => unresolvedTasks(ref as UnresolvedTasksRef, date),
        from: unresolvedTasksProvider,
        name: r'unresolvedTasksProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$unresolvedTasksHash,
        dependencies: UnresolvedTasksFamily._dependencies,
        allTransitiveDependencies:
            UnresolvedTasksFamily._allTransitiveDependencies,
        date: date,
      );

  UnresolvedTasksProvider._internal(
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
    FutureOr<List<TodayTask>> Function(UnresolvedTasksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnresolvedTasksProvider._internal(
        (ref) => create(ref as UnresolvedTasksRef),
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
  AutoDisposeFutureProviderElement<List<TodayTask>> createElement() {
    return _UnresolvedTasksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnresolvedTasksProvider && other.date == date;
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
mixin UnresolvedTasksRef on AutoDisposeFutureProviderRef<List<TodayTask>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _UnresolvedTasksProviderElement
    extends AutoDisposeFutureProviderElement<List<TodayTask>>
    with UnresolvedTasksRef {
  _UnresolvedTasksProviderElement(super.provider);

  @override
  DateTime get date => (origin as UnresolvedTasksProvider).date;
}

String _$resolutionActionsHash() => r'8a1289ac5151a3ba5a4cd54368d7711473217ae7';

/// Actions for resolving tasks in the end-of-day resolution screen.
///
/// Copied from [ResolutionActions].
@ProviderFor(ResolutionActions)
final resolutionActionsProvider =
    AutoDisposeNotifierProvider<ResolutionActions, void>.internal(
      ResolutionActions.new,
      name: r'resolutionActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$resolutionActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ResolutionActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
