enum Day {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday
  ;

  String get code => switch (this) {
    .monday => 'MON',
    .tuesday => 'TUE',
    .wednesday => 'WED',
    .thursday => 'THU',
    .friday => 'FRI',
    .saturday => 'SAT',
    .sunday => 'SUN',
  };

  String get shortLabel => switch (this) {
    .monday => 'Mon',
    .tuesday => 'Tue',
    .wednesday => 'Wed',
    .thursday => 'Thu',
    .friday => 'Fri',
    .saturday => 'Sat',
    .sunday => 'Sun',
  };
}
