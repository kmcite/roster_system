import 'package:manager/manager.dart';
import 'package:roster_system/experimental/repositories.dart';

import 'models.dart';

final rostersBloc = RostersBloc();
final staffsBloc = StaffsBloc();
final rosterEntriesBloc = RosterEntriesBloc();

/// placeholder for the roster in UI
final rosterRM = RM.inject<Roster>(
  () => throw UnimplementedError(),
  sideEffects: SideEffects.onData(rostersBloc.put),
);

class RostersBloc {
  final rostersRM = RM.injectStream(
    () => rostersRepository.watch(),
    initialState: rostersRepository.getAll(),
  );

  List<Roster> get rosters => rostersRM.state;
  void put(Roster roster) {
    rostersRepository.put(roster);
  }

  void remove(int rosterId) {
    rostersRepository.remove(rosterId);
  }

  int getStaffHours(int staffId) {
    int totalHours = 0;
    for (final roster in rosters) {
      totalHours += roster.getStaffHours(staffId);
    }
    return totalHours;
  }
}

class StaffsBloc {
  final staffsRM = RM.injectStream(
    () => staffsRepository.watch(),
    initialState: staffsRepository.getAll(),
  );

  List<Staff> get staffs => staffsRM.state;
  void put(Staff staff) {
    staffsRepository.put(staff);
  }

  bool get editing => editingRM.state;
  final editingRM = RM.inject<bool>(() => false);
  void toggleEditing() => editingRM.toggle();
}

class RosterEntriesBloc {
  final rosterEntriesRM = RM.injectStream(
    () => rosterEntriesRepository.watch(),
    initialState: rosterEntriesRepository.getAll(),
  );

  List<RosterEntry> get rosterEntries => rosterEntriesRM.state;
  void put(RosterEntry rosterEntry) {
    rosterEntriesRepository.put(rosterEntry);
  }
}
