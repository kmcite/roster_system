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
}

// sealed class Day {
//   String get code;
// }

// class Monday extends Day {
//   @override
//   String get code => 'M';
// }

// class Tuesday extends Day {
//   @override
//   String get code => 'W';
// }

// class Friday extends Day {
//   @override
//   String get code => 'F';
// }

// class Thursday extends Day {
//   @override
//   String get code => 'T';
// }

// class Saturday extends Day {
//   @override
//   String get code => 'S';
// }

// class Sunday extends Day {
//   @override
//   String get code => 'S';
// }
