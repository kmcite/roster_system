import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:provider/provider.dart';
import 'package:roster_system/notifiers/shell_notifier.dart';
import 'package:roster_system/ui/glass/glass_nav.dart';
import 'package:roster_system/ui/rosters/rosters_page.dart';
import 'package:roster_system/ui/settings/settings_page.dart';
import 'package:roster_system/ui/staffs/staffs_page.dart';

class ApplicationShell extends StatelessWidget {
  const ApplicationShell({super.key});

  static const _destinations = [
    (icon: FLucideIcons.users, label: 'Team'),
    (icon: FLucideIcons.calendarDays, label: 'Schedule'),
    (icon: FLucideIcons.settings, label: 'Settings'),
  ];

  static const _pages = [
    StaffsPage(),
    RostersPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final index = context.watch<ShellNotifier>().index;
    final shell = context.read<ShellNotifier>();

    return GlassShell(
      selectedIndex: index,
      onSelected: shell.setIndex,
      dockItems: _destinations,
      pages: _pages,
    );
  }
}
