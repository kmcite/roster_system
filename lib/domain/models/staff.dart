import 'package:objectbox/objectbox.dart';
import 'package:roster_system/domain/models/roster_entry.dart';
import 'package:roster_system/domain/models/roster.dart';

@Entity()
class Staff {
  int id = 0;
  String name = '';
  final entries = ToMany<RosterEntry>();
  final rosters = ToMany<Roster>();

  @override
  String toString() {
    return 'Staff($id, $name)';
  }
}
