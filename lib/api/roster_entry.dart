import 'package:objectbox/objectbox.dart';
import 'package:roster_system/api/day.dart';
import 'package:roster_system/api/shift.dart';
import 'package:roster_system/api/staff.dart';
import 'package:roster_system/api/roster.dart';

@Entity()
class RosterEntry {
  int id = 0;

  ToOne<Staff> staff = ToOne<Staff>();
  ToOne<Roster> roster = ToOne<Roster>();

  int dayIndex = 0;
  Day get day => Day.values[dayIndex];
  set day(Day value) => dayIndex = value.index;

  int shiftIndex = 0;
  Shift get shift => Shift.values[shiftIndex];
  set shift(Shift value) => shiftIndex = value.index;
}

extension RosterEntryExtension on RosterEntry {
  bool get isAssigned => staff.target != null;
}
