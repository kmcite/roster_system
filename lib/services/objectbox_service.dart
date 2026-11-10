import 'package:objectbox/objectbox.dart';
import 'package:roster_system/api/roster.dart';
import 'package:roster_system/api/roster_entry.dart';
import 'package:roster_system/api/staff.dart';

class ObjectBoxService {
  ObjectBoxService(this._store);

  final Store _store;

  Box<Staff> get staffBox => _store.box<Staff>();
  Box<Roster> get rosterBox => _store.box<Roster>();
  Box<RosterEntry> get entryBox => _store.box<RosterEntry>();

  Future<int> putStaff(Staff staff) => staffBox.putAsync(staff);

  Future<bool> removeStaff(int id) => staffBox.removeAsync(id);

  Future<int> putRoster(Roster roster) {
    roster.generateEntries();
    return rosterBox.putAsync(roster);
  }

  Future<bool> removeRoster(int id) => rosterBox.removeAsync(id);

  Future<int> putEntry(RosterEntry entry) => entryBox.putAsync(entry);

  Staff? staffById(int id) => staffBox.get(id);

  Roster? rosterById(int id) => rosterBox.get(id);

  List<RosterEntry> allEntries() => entryBox.getAll();

  Stream<List<Staff>> watchStaff() => staffBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());

  Stream<List<Roster>> watchRosters() => rosterBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());

  Stream<List<RosterEntry>> watchEntries() => entryBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());
}
