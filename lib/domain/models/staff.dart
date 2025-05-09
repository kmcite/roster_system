import 'package:manager/manager.dart';
import 'package:objectbox/objectbox.dart';
import 'package:roster_system/domain/models/roster_entry.dart';
import 'package:roster_system/domain/models/roster.dart';

@Entity()
class Staff extends Model {
  @Id()
  int id = 0;
  String name = '';
  @Backlink('staff')
  final entries = ToMany<RosterEntry>();
  final rosters = ToMany<Roster>(); // Added: Staff can be in multiple rosters
}
