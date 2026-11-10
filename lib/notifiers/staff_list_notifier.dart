import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:roster_system/api/staff.dart';
import 'package:roster_system/services/objectbox_service.dart';

class StaffListNotifier extends ChangeNotifier {
  StaffListNotifier(this._objectBox) {
  _subscription = _objectBox.watchStaff().listen((staff) {
      _staff = staff;
      notifyListeners();
    });
  }

  final ObjectBoxService _objectBox;
  late final StreamSubscription<List<Staff>> _subscription;

  List<Staff> _staff = const [];

  List<Staff> get staff => _staff;

  Staff? byId(int id) {
    for (final member in _staff) {
      if (member.id == id) return member;
    }
    return null;
  }

  Future<void> add(Staff staff) => _objectBox.putStaff(staff);

  Future<void> update(Staff staff) => _objectBox.putStaff(staff);

  Future<void> remove(int id) => _objectBox.removeStaff(id);

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
