import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'navigator.dart';

bool logging = true;

/// ----------------------
/// RM - listens to Repositories & notifies UI
/// ----------------------
class _RM<T> extends ChangeNotifier implements ValueListenable<T> {
  final T Function() initializer;
  T _value;
  final controller = StreamController<T>.broadcast();

  _RM(this.initializer) : _value = initializer() {
    controller.add(_value);
  }

  void refresh() {
    value = initializer();
  }

  @override
  T get value => _value;

  set value(T val) {
    if (shouldNotify(_value, val)) {
      _value = val;
      controller.add(_value);
      notifyListeners();
    }
  }

  bool shouldNotify(T oldValue, T newValue) => true;

  /// only non-nullable updates are supported
  T call([T? val]) {
    if (val != null) value = val;
    return value;
  }

  Stream<T> get stream => controller.stream;

  void set(T _value) => value = _value;

  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  String toString() {
    return 'RM<$T>($_value)';
  }

  /// should be handled where its used -> disposal
  StreamSubscription<T> listen(
    void Function(T data) notify,
  ) {
    return stream.listen(notify);
  }
}

/// ----------------------
/// Repository - holds state & notifies dependents
/// ----------------------
abstract class Repository<T> {
  final _controller = StreamController<int>.broadcast();

  final subscriptions = <StreamSubscription>{};

  _RM<U> inject<U>(U Function() initializer) {
    final created = _RM(initializer);
    final subscription = created.listen((_) => notify());
    subscriptions.add(subscription);
    return created;
  }

  int count = 0;

  void notify() {
    _controller.add(count++);
  }

  Stream<int> get stream => _controller.stream;

  void dispose() {
    for (var sub in subscriptions) {
      sub.cancel();
    }
    subscriptions.clear();
    _controller.close();
  }
}

/// ----------------------
/// Bloc - state holder for UI
/// ----------------------
abstract class Bloc extends Stream<int> {
  NavigationRepository get navigator => depend();
  int count = 0;
  final _controller = StreamController<int>.broadcast();
  final _subscriptions = <StreamSubscription>{};

  _RM<T> global<T>(_RM<T> value) {
    _subscriptions.add(value.listen(notify));
    return value;
  }

  _RM<T> local<T>(T Function() initializer) {
    final instance = _RM<T>(initializer);
    _subscriptions.add(instance.listen(notify));
    return instance;
  }

  void notify<T>(T data) {
    count++;
    _controller.add(count);
  }

  @mustCallSuper
  void initState() {
    if (logging) log('initState<$runtimeType>()');
  }

  @mustCallSuper
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _controller.close();
    if (logging) log('dispose<$runtimeType>()');
  }

  @override
  StreamSubscription<int> listen(
    void Function(int event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

/// ----------------------
/// Repositories - single sources of truth
/// ----------------------

final repositories = <Type, Repository>{};

/// ----------------------
/// Services - data providers or sources
/// ----------------------
final services = <Type, Object>{};

/// [serve] is used to inject or find services
T serve<T>([T? instance]) {
  if (instance != null) {
    services[T] = instance;
    return instance;
  } else {
    final found = services[T];
    if (found == null) log('$T not found');
    return found as T;
  }
}

/// [depend] is used to find and inject repositories
T depend<T extends Repository>([T? instance]) {
  if (instance == null) {
    final found = repositories[T];
    if (found == null) log('$T not found');
    return found as T;
  }

  repositories[T] = instance;
  if (logging) log('get<$T>()');
  return instance;
}

/// ----------------------
/// UI - StatefulWidget bound to a Bloc
/// ----------------------
///
/// [UI] is used as an imperative way of composing
/// application features
abstract class UI<T extends Bloc> extends StatefulWidget {
  NavigationRepository get navigator => depend();
  T create();
  Widget build(T controller);

  const UI({super.key});
  @override
  createState() => _UI<T>();
}

class _UI<T extends Bloc> extends State<UI<T>> {
  late final T controller;
  late StreamSubscription<int> _subscription;

  @override
  void initState() {
    super.initState();
    controller = widget.create();
    controller.initState();
    _subscription = controller.listen(_listener);
  }

  void _listener(_) {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _subscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.build(controller);
}

/// ----------------------
/// Feature - StatefulWidget bound to a Bloc
/// ----------------------
///
/// [Feature] is used as a declarative way of composing
/// application features
class Feature<T extends Bloc> extends StatefulWidget {
  final T Function() create;
  final Widget Function(T controller) build;

  const Feature({
    required this.create,
    required this.build,
  });

  @override
  FeatureState<T> createState() => FeatureState<T>();
}

class FeatureState<T extends Bloc> extends State<Feature<T>> {
  late final T controller;
  late StreamSubscription<int> _subscription;

  @override
  void initState() {
    super.initState();
    controller = widget.create();
    controller.initState();
    _subscription = controller.listen(_listener);
  }

  void _listener(_) {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _subscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.build(controller);
}

/// ----------------------
/// AppRunner - dependency bootstrapper
/// ----------------------
void AppRunner({
  required Future<void> Function() initialize,
  required Widget app,
}) async {
  await initialize().then(
    (_) => depend<NavigationRepository>(NavigationRepository()),
  );
  runApp(app);
}

/// ----------------------
/// Dispose all registry instances
/// ----------------------
void disposeAll() {
  for (final instance in repositories.values) {
    instance.dispose();
  }
  repositories.clear();
  services.clear();
  if (logging) log('Registry disposed');
}
