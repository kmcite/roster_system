import 'package:objectbox/objectbox.dart';
import 'package:roster_system/api/day.dart';
import 'package:roster_system/api/roster_entry.dart';
import 'package:roster_system/api/shift.dart';
import 'package:roster_system/domain/schedule_grid.dart';

@Entity()
class Roster {
  int id = 0;
  String name = '';

  DateTime startDate = DateTime.now();
  DateTime? effectiveTill;

  @Backlink('roster')
  final entries = ToMany<RosterEntry>();
}

extension RosterX on Roster {
  Roster generateEntries() {
    final existingCount = entries.length;
    final expectedCount = ScheduleGrid.totalSlots;

    if (existingCount < expectedCount) {
      for (var day in Day.values) {
        for (var shift in Shift.values) {
          final exists = entries.any((e) => e.day == day && e.shift == shift);
          if (!exists) {
            final newEntry = RosterEntry()
              ..day = day
              ..shift = shift;
            entries.add(newEntry);
          }
        }
      }
    }
    return this;
  }

  RosterEntry? getEntry(Day day, Shift shift) {
    return entries
        .where((entry) => entry.day == day && entry.shift == shift)
        .firstOrNull;
  }

  int getStaffHours(int staffId) {
    return entries
        .where(
          (e) {
            return e.staff.targetId == staffId;
          },
        )
        .fold(
          0,
          (sum, e) {
            return sum + e.shift.hours;
          },
        );
  }

  void validateEntries() {
    final expectedCount = ScheduleGrid.totalSlots;
    if (entries.length != expectedCount) {
      throw Exception(
        'Invalid number of entries (${entries.length}, expected $expectedCount) for roster: $name, id: $id',
      );
    }
  }
}
