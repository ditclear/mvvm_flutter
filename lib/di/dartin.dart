// Copyright 2018 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A [DartInScope] provides a separate type-space for a provider, thus
/// allowing more than one provider of the same type.
///
/// This should always be initialized as a static const and passed around.
/// The name is only used for descriptive purposes.
class DartInScope {
  final String _name;

  /// Constructor
  const DartInScope(this._name);

  @override
  String toString() {
    return "Scope ('$_name')";
  }
}

/// DartIns are the container to provide dependencies.
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

  /// Add dartin in different scopes from [Module]
  void provideFromModule(Module module) {
    final tempMap = module._providerIns;
    for (var scope in tempMap.keys) {
      for (var dartin in tempMap[scope]) {
        provide(dartin, scope: scope);
      }
    }
  }

  /// Syntactic sugar around adding a value based provider.
  ///
  ///  If no [scope] is passed in, the default one will be used.
  void provideValue<T>(T value, {DartInScope scope}) {
    provide(DartIn._value(value), scope: scope);
  }

  /// get DartIn from Type,maybe null
  DartIn<T> getFromType<T>({DartInScope scope}) {
    return _providersForScope(scope)[T];
  }

  /// find T from [_providers] , may be null
  T value<T>({DartInScope scope, List params}) {
    return getFromType<T>(scope: scope)?.get(params: params);
  }

  Map<Type, DartIn<dynamic>> _providersForScope(scope) => _providers[scope ?? defaultScope] ??= {};
}

/// A DartIn provides a value on request.
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
  T get({List params});

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
  T get({List params}) => _value;

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
  T get({List params}) {
    // Need to have a local copy for casting because
    // dart requires it.
    T value;
    if (_value == null) {
      value = _value ??= _initalizer(params: _ParameterList.parametersOf(params));
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
  T get({List params}) => providerFunction(params: _ParameterList.parametersOf(params));
}

/// Module Definition
class Module {
  /// Gather dependencies & properties definitions
  final Map<DartInScope, List<DartIn>> _providerIns = {};

  /// dependencies in defaultScope
  Module(List<DartIn> defaults) {
    _providerIns[DartIns.defaultScope] = defaults ??= [];
  }

  /// dependencies in otherScope
  void addOthers(DartInScope otherScope, List<DartIn> others) {
    assert(otherScope._name != DartIns.defaultScope._name);
    _providerIns[otherScope] = others ??= [];
  }
}

/// List of parameter
class _ParameterList {
  final List<Object> params;

  /**
   * get element at given index
   */
  get(int i) {
    if (params == null || i > params.length - 1 || i < 0) {
      return null;
    }
    return params[i];
  }

  _ParameterList.parametersOf(this.params);
}

/// Creates a provider that provides a new value using the [_DartInFunction] for each
/// requestor of the value.
DartIn<T> factory<T>(_DartInFunction<T> value, {String scope}) => DartIn<T>._withFactory(value);

/// Creates a provider with the value provided to it.
DartIn<T> single<T>(T value) => DartIn<T>._value(value);

/// Creates a provider which will initialize using the [_DartInFunction]
/// the first time the value is requested.
DartIn<T> lazy<T>(_DartInFunction<T> value) => DartIn<T>._lazy(value);

/// get T  from dartIns by T.runtimeType and params
T get<T>({String scopeName, List params}) {
  assert(_dartIns != null, "error: please use startDartIn method first ");
  final scope = scopeName == null ? DartIns.defaultScope : DartInScope(scopeName);
  final result = _dartIns.value<T>(scope: scope, params: params);
  assert(result != null, "error: not found $T in ${scope.toString()}");
  return result;
}

/// get T  from dartIns by T.runtimeType and params
T inject<T>({String scopeName, List params}) => get<T>(scopeName: scopeName, params: params);

/// global dependencies 's container in App
DartIns _dartIns;

/// init and load dependencies to [DartIns] from modules
startDartIn(List<Module> modules) {
  _dartIns = DartIns();
  for (var module in modules) {
    _dartIns.provideFromModule(module);
  }
}
