import 'package:roster_system/api/day.dart';
import 'package:roster_system/api/shift.dart';

/// Week grid shape and clock rules — no persistence or UI.
abstract final class ScheduleGrid {
  static const int daysPerWeek = 7;
  static int get shiftsPerDay => Shift.values.length;
  static int get totalSlots => Day.values.length * shiftsPerDay;

  static Day dayFromDateTime(DateTime dateTime) {
    return Day.values[dateTime.weekday - 1];
  }

  /// Local wall-clock mapping for “who is on duty now”.
  static Shift shiftFromClockHour(int hour) {
    if (hour >= 8 && hour < 14) return Shift.morning;
    if (hour >= 14 && hour < 20) return Shift.evening;
    return Shift.night;
  }

  static Iterable<({Day day, Shift shift})> get allSlots sync* {
    for (final day in Day.values) {
      for (final shift in Shift.values) {
        yield (day: day, shift: shift);
      }
    }
  }
}
