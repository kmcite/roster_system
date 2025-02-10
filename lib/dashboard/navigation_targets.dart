import 'package:forui/forui.dart';
import 'package:manager/manager.dart';
import 'package:roster_system/rosters/rosters_page.dart';
import 'package:roster_system/settings/settings_page.dart';
import 'package:roster_system/staffs/staffs_page.dart';

final navigationIndexRM = RM.inject(() => 0);

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
