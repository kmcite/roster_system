import 'package:objectbox/objectbox.dart';
import 'package:roster_system/api/roster_entry.dart';
import 'package:roster_system/api/shift.dart';

@Entity()
class Staff {
  int id = 0;
  String name = '';

  @Backlink('staff')
  final entries = ToMany<RosterEntry>();

  int? dutyPlace;

  @override
  String toString() {
    return 'Staff($id, $name)';
  }

  /// Get total hours assigned to this staff across all rosters
  int get totalHours {
    return entries.fold<int>(
      0,
      (sum, entry) => sum + entry.shift.hours,
    );
  }
}
