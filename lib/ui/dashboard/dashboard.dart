import 'package:roster_system/main.dart';

import '../rosters/rosters_page.dart';
import '../settings/settings_page.dart';
import '../staffs/staffs_page.dart';

enum NavigationTargets {
  staffs,
  rosters,
  settings;

  SvgAsset get icon {
    return switch (this) {
      NavigationTargets.staffs => FAssets.icons.dock,
      NavigationTargets.rosters => FAssets.icons.hardDrive,
      NavigationTargets.settings => FAssets.icons.settings,
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

mixin DashboardPageBloc {
  final indexRM = RM.inject<int>(
    () => 0,
    persist: () => PersistState(key: 'index'),
  );
  int index([int? value]) {
    if (value != null) {
      indexRM.state = value;
    }
    return indexRM.state;
  }
}

class DashboardPage extends UI with DashboardPageBloc {
  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      contentPad: false,
      content: NavigationTargets.values.elementAt(index()).page,
      footer: FBottomNavigationBar(
        index: index(),
        onChange: index,
        children: [
          ...NavigationTargets.values.map(
            (target) {
              return FBottomNavigationBarItem(
                icon: FIcon(target.icon),
                label: target.name.text(),
              );
            },
          ),
        ],
      ),
    );
  }
}
