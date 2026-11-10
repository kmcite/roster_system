import 'package:roster_system/api/day.dart';
import 'package:roster_system/api/roster.dart';
import 'package:roster_system/api/roster_entry.dart';
import 'package:roster_system/api/shift.dart';
import 'package:roster_system/domain/schedule_grid.dart';

class RosterCoverage {
  const RosterCoverage({required this.filled, required this.total});

  final int filled;
  final int total;

  double get ratio => total == 0 ? 0 : filled / total;

  int get percentRounded => (ratio * 100).round();

  String get label => '$filled / $total';
}

/// Scheduling queries and aggregates for a single [Roster].
extension RosterSchedule on Roster {
  RosterCoverage get coverage {
    var filled = 0;
    for (final entry in entries) {
      if (entry.isAssigned) filled++;
    }
    return RosterCoverage(filled: filled, total: ScheduleGrid.totalSlots);
  }

  int filledSlotsFor(Day day) {
    var filled = 0;
    for (final shift in Shift.values) {
      if (getEntry(day, shift)?.isAssigned == true) filled++;
    }
    return filled;
  }

  Map<String, int> hoursByStaffName() {
    final hours = <String, int>{};
    for (final entry in entries) {
      final person = entry.staff.target;
      if (person == null) continue;
      hours[person.name] = (hours[person.name] ?? 0) + entry.shift.hours;
    }
    hours.removeWhere((_, v) => v == 0);
    return hours;
  }

  RosterEntry? slot(Day day, Shift shift) => getEntry(day, shift);
}
