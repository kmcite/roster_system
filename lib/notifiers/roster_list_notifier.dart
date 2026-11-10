import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:roster_system/api/day.dart';
import 'package:roster_system/api/roster.dart';
import 'package:roster_system/api/roster_entry.dart';
import 'package:roster_system/api/shift.dart';
import 'package:roster_system/api/staff.dart';
import 'package:roster_system/services/objectbox_service.dart';

class RosterListNotifier extends ChangeNotifier {
  RosterListNotifier(this._objectBox) {
    _rosterSubscription = _objectBox.watchRosters().listen(_onRostersChanged);
    _entrySubscription = _objectBox.watchEntries().listen((_) => _reloadRosters());
  }

  final ObjectBoxService _objectBox;
  late final StreamSubscription<List<Roster>> _rosterSubscription;
  late final StreamSubscription<List<RosterEntry>> _entrySubscription;

  List<Roster> _rosters = const [];

  List<Roster> get rosters => _rosters;

  bool get isEmpty => _rosters.isEmpty;

  int get count => _rosters.length;

  Roster? byId(int id) {
    for (final roster in _rosters) {
      if (roster.id == id) return roster;
    }
    return _objectBox.rosterById(id);
  }

  Roster? at(int index) {
    if (index < 0 || index >= _rosters.length) return null;
    return _rosters[index];
  }

  Future<void> add(Roster roster) => _objectBox.putRoster(roster);

  Future<void> update(Roster roster) => _objectBox.putRoster(roster);

  Future<void> remove(int id) => _objectBox.removeRoster(id);

  Future<void> saveEntry(RosterEntry entry) => _objectBox.putEntry(entry);

  /// Ensures a persisted grid cell exists for [day] × [shift] on [roster].
  Future<RosterEntry> ensureSlot(Roster roster, Day day, Shift shift) async {
    final existing = roster.getEntry(day, shift);
    if (existing != null) return existing;

    final entry = RosterEntry()
      ..day = day
      ..shift = shift
      ..roster.target = roster;
    await saveEntry(entry);
    return entry;
  }

  Future<void> assignStaff(RosterEntry entry, Staff staff) async {
    entry.staff.target = staff;
    await saveEntry(entry);
  }

  Future<void> assignStaffId(RosterEntry entry, int staffId) async {
    entry.staff.targetId = staffId;
    await saveEntry(entry);
  }

  Future<void> clearAssignment(RosterEntry entry) async {
    entry.staff.target = null;
    await saveEntry(entry);
  }

  void _onRostersChanged(List<Roster> rosters) {
    _rosters = rosters;
    notifyListeners();
  }

  void _reloadRosters() {
    _rosters = _objectBox.rosterBox.getAll();
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_rosterSubscription.cancel());
    unawaited(_entrySubscription.cancel());
    super.dispose();
  }
}
