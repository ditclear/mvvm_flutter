// Copyright 2018 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class DartInScope {
  final String _name;

  /// Constructor
  const DartInScope(this._name);

  @override
  String toString() {
    return "Scope ('$_name')";
  }
}

/// DartIns are the values passed to the [DartInNodes].
///
/// DartIns can be added to using either convenience functions such as
/// [provideValue] or by passing in DartIns.
class DartIns {
  // The DartIn for each given [Type] should return that type, but we can't
  // enforce that here directly. We can use APIs to make sure it's type-safe.
  final Map<DartInScope, Map<Type, DartIn<dynamic>>> _providers = {};

  /// Creates a new empty provider.
  DartIns();

  /// The default scope in which any type not with a defined scope resides.
  static const DartInScope defaultScope = DartInScope('_default');

  /// Creates a provider with the included providers.
  ///
  /// If a scope is provided, the values will be under that scope.
  factory DartIns.withDartIns(Map<Type, DartIn<dynamic>> providers, {DartInScope scope}) => DartIns()..provideAll(providers, scope: scope);

  /// Add a provider for a single type.
  ///
  /// Will override any existing provider of that type in this node with the
  /// given scope. If no [scope] is passed in, the default one will be used.
  void provide<T>(DartIn<T> provider, {DartInScope scope}) {
    // This should never happen.
//    assert(provider.type == T);

    _providersForScope(scope)[provider.type] = provider;
  }

  /// Provide many providers at once.
  ///
  /// Prefer using [provide] and [provideFrom] because that catches type
  /// errors at compile-time.
  void provideAll(Map<Type, DartIn> providers, {DartInScope scope}) {
    for (var entry in providers.entries) {
      if (entry.key != entry.value.type) {
        if (entry.value.type == dynamic) {
          throw ArgumentError('Not able to infer the type of provider for'
              ' ${entry.key} automatically. Add type argument to provider.');
        }
        throw ArgumentError('Type mismatch between ${entry.key} and provider '
            'of ${entry.value.type}.');
      }
    }

    _providersForScope(scope).addAll(providers);
  }

  /// Add in all the providers from another DartIns.
  void provideFrom(DartIns other) {
    for (final scope in other._providers.keys) {
      provideAll(other._providersForScope(scope), scope: scope);
    }
  }

  /// Syntactic sugar around adding a value based provider.
  ///
  /// If this value is [Listenable], widgets that use this value can be rebuilt
  /// on change. If no [scope] is passed in, the default one will be used.
  void provideValue<T>(T value, {DartInScope scope}) {
    provide(DartIn._value(value), scope: scope);
  }

  DartIn<T> getFromType<T>({DartInScope scope}) {
    return _providersForScope(scope)[T];
  }

  T value<T>({DartInScope scope, List values}) {
    return getFromType<T>(scope: scope)?.get(values: values);
  }

  Map<Type, DartIn<dynamic>> _providersForScope(scope) => _providers[scope ?? defaultScope] ??= {};
}

/// A DartIn provides a value on request.
///
/// If a provider implements [Listenable], it will be listened to by the
/// [Provide] widget to rebuild on change. Other than the built in providers,
/// one can implement DartIn to provide caching or linkages.
///
/// When a DartIn is instantiated within a [providers.provide] call, the type
/// can be inferred and therefore the type can be ommited, but otherwise,
/// [T] is required.
///
/// DartIn should be implemented and not extended.
abstract class DartIn<T> {
  /// Returns the value provided by the provider.
  ///
  /// Because providers could potentially initialize the value each time [get]
  /// is called, this should be called as infrequently as possible.
  T get({List values});

  /// The type that is provided by the provider.
  Type get type;

  /// Creates a provider with the value provided to it.
  factory DartIn._value(T value) => _ValueDartIn(value);

  /// Creates a provider which will initialize using the [_DartInFunction]
  /// the first time the value is requested.
  ///
  /// The context can be used to obtain other values from the provider. However,
  /// care should be taken with this to not have circular dependencies.
  factory DartIn._lazy(_DartInFunction<T> function) => _LazyDartIn<T>(function);

  /// Creates a provider that provides a new value for each
  /// requestor of the value.
  factory DartIn._withFactory(_DartInFunction<T> function) => _FactoryDartIn<T>(function);
}

/// Base mixin for providers.
abstract class _TypedDartIn<T> implements DartIn<T> {
  /// The type of the provider
  @override
  Type get type => T;
}

/// Contains a value which will never be disposed.
class _ValueDartIn<T> extends _TypedDartIn<T> {
  final T _value;

  @override
  T get({List values}) => _value;

  _ValueDartIn(this._value);
}

/// Function that returns an instance of T when called.
typedef _DartInFunction<T> = T Function({_ParameterList params});

/// Is initialized on demand, and disposed when no longer needed
/// if [dispose] is set to true.
/// When obtained statically, the value will never be disposed.
class _LazyDartIn<T> with _TypedDartIn<T> {
  final _DartInFunction<T> _initalizer;

  T _value;

  _LazyDartIn(this._initalizer);

  @override
  T get({List values}) {
    // Need to have a local copy for casting because
    // dart requires it.
    T value;
    if (_value == null) {
      value = _value ??= _initalizer(params: _ParameterList.parametersOf(values));
    }
    return _value;
  }
}

/// A provider who's value is obtained from providerFunction for each time the
/// value is requested.
///
/// This provider doesn't keep any values itself, so those values are disposed
/// when the containing widget is disposed.
class _FactoryDartIn<T> with _TypedDartIn<T> {
  final _DartInFunction<T> providerFunction;

  _FactoryDartIn(this.providerFunction);

  @override
  T get({List values}) => providerFunction(params: _ParameterList.parametersOf(values));
}

class Module {
  final List<DartIn> providerIns;
  Module(this.providerIns);
}

class _ParameterList {
  final List<Object> values;

  get(int i) {
    if (values == null || i > values.length - 1 || i < 0) {
      return null;
    }
    return values[i];
  }

  _ParameterList.parametersOf(this.values);
}

DartIn<T> factory<T>(_DartInFunction<T> value,{String scope }) => DartIn<T>._withFactory(value);

DartIn<T> single<T>(T value) => DartIn<T>._value(value);

DartIn<T> lazy<T>(_DartInFunction<T> value) => DartIn<T>._lazy(value);

T get<T>({DartInScope scope, List params}) {
  assert(_dartIns != null);
  return _dartIns.value<T>(scope: scope, values: params);
}

T inject<T>({DartInScope scope, List params}) => get<T>(scope: scope, params: params);

DartIns _dartIns;

startDartIn(List<Module> modules) {
  _dartIns = DartIns();
  for (var module in modules) {
    for (var providerIn in module.providerIns) {
      _dartIns.provide(providerIn);
    }
  }
}
