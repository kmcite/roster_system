import 'package:roster_system/main.dart' show CRUD;
import 'package:roster_system/domain/models/roster_entry.dart' show RosterEntry;

class RosterEntriesRepository extends CRUD<RosterEntry> {}

final rosterEntriesRepository = RosterEntriesRepository();
