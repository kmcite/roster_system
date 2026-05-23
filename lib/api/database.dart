import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart' show Box;
import 'package:objectbox/objectbox.dart' show Store;
import 'package:roster_system/api/roster.dart';
import 'package:roster_system/api/roster_entry.dart';
import 'package:roster_system/api/staff.dart';

late Box hive;

void write(String key, String value) async {
  await hive.put(key, value);
}

String? read(String key) {
  return hive.get(key);
}

late Store objects;

class Crud<T> with ChangeNotifier {
  final box = objects.box<T>();
  StreamSubscription<dynamic>? _subscription;
  Crud() {
    _subscription = watch().listen((_) => notifyListeners());
  }

  /// MUTATIONS
  void put(T any) => objects.box<T>().put(any);
  bool remove(int id) => objects.box<T>().remove(id);
  void removeAll() => objects.box<T>().removeAll();

  /// ONE-TIME READS
  T? get(int id) => box.get(id);
  T at(int index) => box.getAll()[index];
  List<T> getAll() => box.getAll();
  bool get isEmpty => box.isEmpty();
  int? get length => box.count();

  /// REACTIVE APIs
  Stream<List<T>> watch() =>
      box.query().watch(triggerImmediately: true).map((event) => event.find());
  Stream<T?> watchById(int id) => watch().map(
    (event) => event.where((dynamic test) => test.id == id).firstOrNull,
  );

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}

final rosters = Crud<Roster>();
final staffs = Crud<Staff>();
final entries = Crud<RosterEntry>();

class Dark {
  static const key = 'dark';
  static const trueValue = 'true';
  bool _dark = false;
  bool get dark {
    _dark = read(key) == trueValue;
    return _dark;
  }

  bool call() => dark;

  set dark(bool value) {
    write(key, value.toString());
    _dark = value;
  }

  void toggle() {
    dark = !dark;
  }

  /// REACTIVE APIs
  Stream<bool> watch() {
    return hive.watch(key: key).map((event) => event.value == trueValue);
  }
}

final dark = Dark();
