import 'package:roster_system/api/day.dart';
import 'package:roster_system/api/shift.dart';
import 'package:roster_system/api/staff.dart';
import 'package:roster_system/domain/schedule_grid.dart';

/// Snapshot of who should be on duty at a point in time (across all rosters).
class CurrentDutySnapshot {
  const CurrentDutySnapshot({
    required this.observedAt,
    required this.day,
    required this.shift,
    this.staff,
  });

  final DateTime observedAt;
  final Day day;
  final Shift shift;
  final Staff? staff;

  bool get isCovered => staff != null;

  factory CurrentDutySnapshot.at(DateTime when, {Staff? staff}) {
    return CurrentDutySnapshot(
      observedAt: when,
      day: ScheduleGrid.dayFromDateTime(when),
      shift: ScheduleGrid.shiftFromClockHour(when.hour),
      staff: staff,
    );
  }
}
