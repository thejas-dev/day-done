// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_day_tasks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarDayTasksHash() => r'00c845c2a5e58d8a4f832ff05beae4777297e126';

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

/// Watches all tasks for a given [date]: dated tasks + daily instances.
/// Returns a unified, sorted list — same pattern as todayTasksProvider
/// but parameterized by date.
///
/// Copied from [calendarDayTasks].
@ProviderFor(calendarDayTasks)
const calendarDayTasksProvider = CalendarDayTasksFamily();

/// Watches all tasks for a given [date]: dated tasks + daily instances.
/// Returns a unified, sorted list — same pattern as todayTasksProvider
/// but parameterized by date.
///
/// Copied from [calendarDayTasks].
class CalendarDayTasksFamily extends Family<AsyncValue<List<TodayTask>>> {
  /// Watches all tasks for a given [date]: dated tasks + daily instances.
  /// Returns a unified, sorted list — same pattern as todayTasksProvider
  /// but parameterized by date.
  ///
  /// Copied from [calendarDayTasks].
  const CalendarDayTasksFamily();

  /// Watches all tasks for a given [date]: dated tasks + daily instances.
  /// Returns a unified, sorted list — same pattern as todayTasksProvider
  /// but parameterized by date.
  ///
  /// Copied from [calendarDayTasks].
  CalendarDayTasksProvider call(DateTime date) {
    return CalendarDayTasksProvider(date);
  }

  @override
  CalendarDayTasksProvider getProviderOverride(
    covariant CalendarDayTasksProvider provider,
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
  String? get name => r'calendarDayTasksProvider';
}

/// Watches all tasks for a given [date]: dated tasks + daily instances.
/// Returns a unified, sorted list — same pattern as todayTasksProvider
/// but parameterized by date.
///
/// Copied from [calendarDayTasks].
class CalendarDayTasksProvider
    extends AutoDisposeStreamProvider<List<TodayTask>> {
  /// Watches all tasks for a given [date]: dated tasks + daily instances.
  /// Returns a unified, sorted list — same pattern as todayTasksProvider
  /// but parameterized by date.
  ///
  /// Copied from [calendarDayTasks].
  CalendarDayTasksProvider(DateTime date)
    : this._internal(
        (ref) => calendarDayTasks(ref as CalendarDayTasksRef, date),
        from: calendarDayTasksProvider,
        name: r'calendarDayTasksProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$calendarDayTasksHash,
        dependencies: CalendarDayTasksFamily._dependencies,
        allTransitiveDependencies:
            CalendarDayTasksFamily._allTransitiveDependencies,
        date: date,
      );

  CalendarDayTasksProvider._internal(
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
    Stream<List<TodayTask>> Function(CalendarDayTasksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalendarDayTasksProvider._internal(
        (ref) => create(ref as CalendarDayTasksRef),
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
  AutoDisposeStreamProviderElement<List<TodayTask>> createElement() {
    return _CalendarDayTasksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarDayTasksProvider && other.date == date;
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
mixin CalendarDayTasksRef on AutoDisposeStreamProviderRef<List<TodayTask>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _CalendarDayTasksProviderElement
    extends AutoDisposeStreamProviderElement<List<TodayTask>>
    with CalendarDayTasksRef {
  _CalendarDayTasksProviderElement(super.provider);

  @override
  DateTime get date => (origin as CalendarDayTasksProvider).date;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
