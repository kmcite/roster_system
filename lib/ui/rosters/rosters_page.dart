import 'package:roster_system/domain/api/rosters_repository.dart';
import 'package:roster_system/ui/rosters/roster_page.dart';

import '../../main.dart';
import '../../domain/models/roster.dart';

class RostersBloc extends Bloc {
  late RostersRepository rostersRepository = depend();

  Iterable<Roster> get rosters => rostersRepository.getAll();
  void putRoster(Roster roster) {
    rostersRepository.put(roster);
  }

  void details(Roster roster) {
    // rostersRepository.item(roster);
    navigator.to(RosterPage());
  }
}

class RostersPage extends UI<RostersBloc> {
  RostersBloc create() => RostersBloc();
  @override
  Widget build(context) {
    return FScaffold(
      header: FHeader(
        title: Text('Rosters'),
        suffixes: [
          FHeaderAction(
            icon: Icon(FIcons.plus),
            onPress: () {
              context.putRoster(
                Roster()..generateEntries(),
              );
            },
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: context.rosters.length,
        itemBuilder: (_, index) {
          final roster = context.rosters.elementAt(index);
          return FTile(
            title: Text(roster.name),
            subtitle: roster.entries.length.text(),
            onPress: () {
              context.details(roster);
              // navigator.to(DevRosterPage(roster));
            },
          );
        },
      ),
    );
  }
}

class DevRosterPage extends UI<DevRosterBloc> {
  DevRosterBloc create() => DevRosterBloc();
  const DevRosterPage(this.roster);
  final Roster roster;
  @override
  Widget build(context) {
    return Scaffold(
      body: roster.text(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigator.dialog(Devlog()),
      ),
    );
  }
}

class DevRosterBloc extends Bloc {
  late RostersRepository rostersRepository = depend();

  void putRoster(Roster roster) {
    rostersRepository.put(roster);
  }
}

class Devlog extends UI<DevRosterBloc> {
  @override
  DevRosterBloc create() => DevRosterBloc();
  @override
  Widget build(context) {
    return Dialog(
      child: ElevatedButton(
        onPressed: () {
          navigator.back();
        },
        child: 'HELLO WORKD'.text(),
      ),
    );
  }
}
