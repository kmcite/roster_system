import 'package:flutter/material.dart' show Widget, Colors, Icon, Color;
import 'package:forui_assets/forui_assets.dart';

enum Shift { morning, evening, night }

extension ShiftExtensions on Shift {
  String get displayName {
    return switch (this) {
      Shift.morning => 'Morning',
      Shift.evening => 'Evening',
      Shift.night => 'Night',
    };
  }

  String get code {
    return switch (this) {
      Shift.morning => 'MOR',
      Shift.evening => 'EVE',
      Shift.night => 'NIG',
    };
  }

  Widget get icon {
    return switch (this) {
      Shift.morning => Icon(FLucideIcons.sun, color: Colors.yellow),
      Shift.evening => Icon(FLucideIcons.cloudSun, color: Colors.deepOrange),
      Shift.night => Icon(FLucideIcons.moon, color: Colors.indigo),
    };
  }

  int get hours {
    return switch (this) {
      Shift.morning => 6,
      Shift.evening => 6,
      Shift.night => 12,
    };
  }

  Color get color {
    return switch (this) {
      Shift.morning => Colors.amber,
      Shift.evening => Colors.orange,
      Shift.night => Colors.indigo,
    };
  }
}
