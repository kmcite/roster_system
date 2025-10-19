import '../../main.dart';

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
      Shift.morning => Icon(FIcons.sun, color: Colors.yellow),
      Shift.evening => Icon(FIcons.cloudSun, color: Colors.deepOrange),
      Shift.night => Icon(FIcons.moon, color: Colors.indigo),
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
