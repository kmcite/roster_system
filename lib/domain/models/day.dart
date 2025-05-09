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
