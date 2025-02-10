import 'package:objectbox/objectbox.dart';
import '../main.dart';
import '../rosters/enums.dart';

@Entity()
class Roster {
  @Id()
  int id = 0;

  String name = '';

  @Backlink()
  final entries = ToMany<RosterEntry>();

  @Backlink()
  final staffs = ToMany<Staff>();

  Roster();

  // Factory method for creating a new roster
  factory Roster.createNew(String name) {
    final roster = Roster()..name = name;
    roster.generateEntries();
    return roster;
  }

  // Generate entries for all days and shifts
  void generateEntries() {
    final existingEntries = entries.toList();
    for (var day in Day.values) {
      for (var shift in Shift.values) {
        if (existingEntries.any((e) => e.day == day && e.shift == shift))
          continue;
        entries.add(RosterEntry()
          ..day = day
          ..shift = shift);
      }
    }
  }

  // Get a specific entry by day and shift
  RosterEntry getEntry(Day day, Shift shift) => entries.singleWhere(
        (e) => e.day == day && e.shift == shift,
        orElse: () => throw Exception('Entry not found'),
      );

  // Calculate total hours worked by a staff member
  int getStaffHours(int staffId) {
    return entries
        .where((e) => e.staff.targetId == staffId)
        .fold(0, (sum, e) => sum + e.shift.hours);
  }

  // Validate the number of entries
  void validateEntries() {
    if (entries.length != Day.values.length * Shift.values.length) {
      throw Exception('Invalid number of entries');
    }
  }
}

@Entity()
class RosterEntry {
  @Id()
  int id = 0;

  int dayIndex = 0;
  int shiftIndex = 0;

  final roster = ToOne<Roster>();
  final staff = ToOne<Staff>();

  // Getters and setters for enums
  @Transient()
  Day get day => Day.values[dayIndex];
  set day(Day value) => dayIndex = value.index;

  @Transient()
  Shift get shift => Shift.values[shiftIndex];
  set shift(Shift value) => shiftIndex = value.index;

  RosterEntry();
}

@Entity()
class Staff {
  @Id()
  int id = 0;

  String name = '';
  final roster = ToOne<Roster>();

  @Backlink()
  final assignments = ToMany<RosterEntry>();

  Staff();
}
