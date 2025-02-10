import 'package:manager/manager.dart';
import 'models.dart';

class RosterEntriesRepository with CRUD<RosterEntry> {}

final rosterEntriesRepository = RosterEntriesRepository();

class StaffsRepository with CRUD<Staff> {}

final staffsRepository = StaffsRepository();

class RostersRepository with CRUD<Roster> {}

final rostersRepository = RostersRepository();
