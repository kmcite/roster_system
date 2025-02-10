import 'package:forui/forui.dart';

import '../main.dart';

enum Day {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;
}

extension DayExtensions on Day {
  String get code {
    return switch (this) {
      Day.monday => 'M',
      Day.tuesday => 'T',
      Day.wednesday => 'W',
      Day.thursday => 'T',
      Day.friday => 'F',
      Day.saturday => 'S',
      Day.sunday => 'S',
    };
  }
}

enum Shift {
  morning,
  evening,
  night;
}

extension ShiftExtensions on Shift {
  String get code {
    return switch (this) {
      Shift.morning => 'M',
      Shift.evening => 'E',
      Shift.night => 'N',
    };
  }

  Widget get icon {
    return switch (this) {
      Shift.morning => FIcon(FAssets.icons.sun, color: Colors.yellow),
      Shift.evening => FIcon(FAssets.icons.cloudSun, color: Colors.deepOrange),
      Shift.night => FIcon(FAssets.icons.moon, color: Colors.indigo),
    };
  }

  int get hours {
    return switch (this) {
      Shift.morning => 6,
      Shift.evening => 6,
      Shift.night => 12,
    };
  }
}
