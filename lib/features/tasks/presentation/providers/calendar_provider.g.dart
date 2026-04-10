// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarIndicatorsHash() =>
    r'109f2519354a56fd82ecc2bae95f34bc1ca80062';

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

/// Watches task counts per date for a given month (year, month).
/// Used for calendar dot indicators.
///
/// Copied from [calendarIndicators].
@ProviderFor(calendarIndicators)
const calendarIndicatorsProvider = CalendarIndicatorsFamily();

/// Watches task counts per date for a given month (year, month).
/// Used for calendar dot indicators.
///
/// Copied from [calendarIndicators].
class CalendarIndicatorsFamily extends Family<AsyncValue<Map<DateTime, int>>> {
  /// Watches task counts per date for a given month (year, month).
  /// Used for calendar dot indicators.
  ///
  /// Copied from [calendarIndicators].
  const CalendarIndicatorsFamily();

  /// Watches task counts per date for a given month (year, month).
  /// Used for calendar dot indicators.
  ///
  /// Copied from [calendarIndicators].
  CalendarIndicatorsProvider call(int year, int month) {
    return CalendarIndicatorsProvider(year, month);
  }

  @override
  CalendarIndicatorsProvider getProviderOverride(
    covariant CalendarIndicatorsProvider provider,
  ) {
    return call(provider.year, provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'calendarIndicatorsProvider';
}

/// Watches task counts per date for a given month (year, month).
/// Used for calendar dot indicators.
///
/// Copied from [calendarIndicators].
class CalendarIndicatorsProvider
    extends AutoDisposeStreamProvider<Map<DateTime, int>> {
  /// Watches task counts per date for a given month (year, month).
  /// Used for calendar dot indicators.
  ///
  /// Copied from [calendarIndicators].
  CalendarIndicatorsProvider(int year, int month)
    : this._internal(
        (ref) => calendarIndicators(ref as CalendarIndicatorsRef, year, month),
        from: calendarIndicatorsProvider,
        name: r'calendarIndicatorsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$calendarIndicatorsHash,
        dependencies: CalendarIndicatorsFamily._dependencies,
        allTransitiveDependencies:
            CalendarIndicatorsFamily._allTransitiveDependencies,
        year: year,
        month: month,
      );

  CalendarIndicatorsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
    required this.month,
  }) : super.internal();

  final int year;
  final int month;

  @override
  Override overrideWith(
    Stream<Map<DateTime, int>> Function(CalendarIndicatorsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalendarIndicatorsProvider._internal(
        (ref) => create(ref as CalendarIndicatorsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Map<DateTime, int>> createElement() {
    return _CalendarIndicatorsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarIndicatorsProvider &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalendarIndicatorsRef
    on AutoDisposeStreamProviderRef<Map<DateTime, int>> {
  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _CalendarIndicatorsProviderElement
    extends AutoDisposeStreamProviderElement<Map<DateTime, int>>
    with CalendarIndicatorsRef {
  _CalendarIndicatorsProviderElement(super.provider);

  @override
  int get year => (origin as CalendarIndicatorsProvider).year;
  @override
  int get month => (origin as CalendarIndicatorsProvider).month;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
