import 'package:objectbox/objectbox.dart';
import 'package:roster_system/domain/models/day.dart';
import 'package:roster_system/domain/models/roster.dart';
import 'package:roster_system/domain/models/shift.dart';
import 'package:roster_system/domain/models/staff.dart';
import 'package:roster_system/main.dart';

@Entity()
class RosterEntry extends Model {
  @Id()
  int id = 0;
  final staff = ToOne<Staff>(); // one staff per entry
  final roster = ToOne<Roster>(); //

  int dayIndex = 0;
  @Transient()
  Day get day => Day.values[dayIndex];
  set day(Day value) => dayIndex = value.index;

  int shiftIndex = 0;
  @Transient()
  Shift get shift => Shift.values[shiftIndex];
  set shift(Shift value) => shiftIndex = value.index;
}
