import 'package:roster_system/api/day.dart';
import 'package:roster_system/api/roster_entry.dart';
import 'package:roster_system/api/shift.dart';
import 'package:roster_system/api/staff.dart';
import 'package:roster_system/domain/current_duty.dart';
import 'package:roster_system/domain/schedule_grid.dart';
import 'package:roster_system/services/objectbox_service.dart';

class DutyStatusService {
  DutyStatusService(this._objectBox);

  final ObjectBoxService _objectBox;

  CurrentDutySnapshot snapshot([DateTime? when]) {
    final observedAt = when ?? DateTime.now();
    final day = ScheduleGrid.dayFromDateTime(observedAt);
    final shift = ScheduleGrid.shiftFromClockHour(observedAt.hour);
    final staff = _staffForSlot(day, shift);
    return CurrentDutySnapshot(
      observedAt: observedAt,
      day: day,
      shift: shift,
      staff: staff,
    );
  }

  Staff? _staffForSlot(Day day, Shift shift) {
    for (final RosterEntry entry in _objectBox.allEntries()) {
      if (!entry.isAssigned) continue;
      if (entry.day == day && entry.shift == shift) {
        return entry.staff.target;
      }
    }
    return null;
  }
}
