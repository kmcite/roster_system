import 'package:roster_system/api/staff.dart';

extension StaffWorkload on Staff {
  /// Duty slots currently assigned to this person (ObjectBox backlink).
  int get assignmentCount => entries.length;
}
