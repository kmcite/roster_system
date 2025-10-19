import 'package:objectbox/objectbox.dart' as ob;
import 'package:roster_system/main.dart';

import 'package:hive_flutter/hive_flutter.dart' as hive_flutter;

extension X on dynamic {
  Widget text() => Text(toString());
}

extension Y on Widget {
  Padding pad() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: this,
    );
  }
}

extension CRUD<T> on Repository<T> {
  /// OBJECT-BOX SETUP
  ob.Store get store => serve<ob.Store>();
  ob.Box<T> get box => store.box<T>();

  void remove(int id) {
    box.remove(id);
  }

  void put(T item) {
    box.put(item);
  }

  void removeAll() {
    box.removeAll();
  }

  T? get(int id) => box.get(id);
  Iterable<T> getAll() => box.getAll();
  int count() => box.count();
  bool contains(int id) => box.contains(id);
  bool isEmpty() => box.isEmpty();
  ob.QueryBuilder<T> query([ob.Condition<T>? qc]) => box.query(qc);

  /// HIVE SETUP
  hive_flutter.Box get hive => serve<hive_flutter.Box>();
}
