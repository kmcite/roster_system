import 'package:objectbox/objectbox.dart';
import 'package:roster_system/domain/models/roster_entry.dart';
import 'package:roster_system/domain/models/day.dart';
import 'package:roster_system/domain/models/shift.dart';
import 'package:roster_system/main.dart';

@Entity()
class Roster extends Model {
  @Id()
  int id = 0;
  String name = '';
  @Backlink('roster')
  final entries = ToMany<RosterEntry>();

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Roster: $name (ID: $id)');
    buffer.writeln('Entries:');
    for (final entry in entries) {
      buffer.writeln(
          '${entry.day.name}, ${entry.shift.name}, ${entry.staff.target?.name ?? 'X'}');
    }
    return buffer.toString();
  }
}

extension RosterX on Roster {
  Roster generateEntries() {
    final existingEntries = entries.toList();
    final newEntries = List<RosterEntry>.from(existingEntries);
    for (var day in Day.values) {
      for (var shift in Shift.values) {
        if (!existingEntries.any((e) => e.day == day && e.shift == shift)) {
          newEntries.add(
            RosterEntry()
              ..day = day
              ..shift = shift,
          );
        }
      }
    }
    entries.addAll(newEntries);
    return this;
  }

  RosterEntry? getEntry(Day day, Shift shift) {
    try {
      return entries.firstWhere((e) => e.day == day && e.shift == shift);
    } catch (e) {
      // throw Exception(
      //   'RosterEntry not found for $day and $shift in roster ${name}, id: $id.  Error: $e',
      // );
      return null;
    }
  }

  int getStaffHours(int staffId) {
    return entries.where(
      (e) {
        return e.staff.target?.id == staffId;
      },
    ).fold(
      0,
      (sum, e) {
        return sum + e.shift.hours;
      },
    );
  }

  void validateEntries() {
    if (entries.length != Day.values.length * Shift.values.length) {
      throw Exception(
        'Invalid number of entries (${entries.length}, expected ${Day.values.length * Shift.values.length}) for roster: ${name}, id: $id',
      );
    }
  }
}
