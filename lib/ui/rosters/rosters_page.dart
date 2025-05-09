import 'package:roster_system/domain/api/rosters_repository.dart';
import 'package:roster_system/ui/rosters/roster_page.dart';

import '../../main.dart';
import '../../domain/models/roster.dart';

mixin RostersBloc {
  Iterable<Roster> get rosters => rostersRepository.getAll();
  void put(Roster roster) {
    rostersRepository.put(roster);
  }

  void details(Roster roster) {
    // rostersRepository.item(roster);
    navigator.to(RosterPage());
  }
}

class RostersPage extends UI with RostersBloc {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: Text('Rosters'),
        actions: [
          FHeaderAction(
            icon: FIcon(FAssets.icons.plus),
            onPress: () {
              put(
                Roster()..generateEntries(),
              );
            },
          ),
        ],
      ),
      content: ListView.builder(
        itemCount: rosters.length,
        itemBuilder: (context, index) {
          final roster = rosters.elementAt(index);
          return FTile(
            title: Text(roster.name),
            subtitle: roster.entries.length.text(),
            onPress: () {
              details(roster);
              // navigator.to(DevRosterPage(roster));
            },
          );
        },
      ),
    );
  }
}

class DevRosterPage extends UI with DevRosterBloc {
  const DevRosterPage(this.roster);
  final Roster roster;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: roster.text(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigator.dialog(Devlog()),
      ),
    );
  }
}

mixin class DevRosterBloc {
  put(Roster roster) {
    rostersRepository.put(roster);
  }
}

class Devlog extends UI {
  @override
  Widget build(BuildContext context) {
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
