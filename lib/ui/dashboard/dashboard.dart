import 'package:roster_system/main.dart';

import '../rosters/rosters_page.dart';
import '../settings/settings_page.dart';
import '../staffs/staffs_page.dart';

enum NavigationTargets {
  staffs,
  rosters,
  settings;

  IconData get icon {
    return switch (this) {
      NavigationTargets.staffs => FIcons.dock,
      NavigationTargets.rosters => FIcons.hardDrive,
      NavigationTargets.settings => FIcons.settings,
    };
  }

  Widget get page {
    return switch (this) {
      NavigationTargets.staffs => StaffsPage(),
      NavigationTargets.rosters => RostersPage(),
      NavigationTargets.settings => SettingsPage(),
    };
  }
}

class DashboardPageBloc extends Bloc {
  late final index = local(() => 0);

  void onIndexChanged(int index) {
    this.index(index);
  }
}

class DashboardPage extends UI<DashboardPageBloc> {
  DashboardPage({super.key});
  @override
  DashboardPageBloc create() => DashboardPageBloc();

  @override
  Widget build(context) {
    return FScaffold(
      childPad: false,
      child: NavigationTargets.values.elementAt(context.index()).page,
      footer: FBottomNavigationBar(
        index: context.index(),
        onChange: context.onIndexChanged,
        children: [
          ...NavigationTargets.values.map(
            (target) {
              return FBottomNavigationBarItem(
                icon: Icon(target.icon),
                label: target.name.text(),
              );
            },
          ),
        ],
      ),
    );
  }
}
