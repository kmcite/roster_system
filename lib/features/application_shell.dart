import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:roster_system/features/rosters/rosters_page.dart';
import 'package:roster_system/features/staffs/staffs_page.dart';

class ApplicationShell extends StatefulWidget {
  const ApplicationShell({super.key});

  @override
  State<ApplicationShell> createState() => _ApplicationShellState();
}

class _ApplicationShellState extends State<ApplicationShell> {
  int index = 0;
  void onDestinationSelected(int index) {
    setState(() => this.index = index);
  }

  @override
  Widget build(context) {
    return Scaffold(
      body: [
        StaffsPage(),
        RostersPage(),
      ][index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: Icon(FIcons.dock),
            label: 'Staffs',
          ),
          NavigationDestination(
            icon: Icon(FIcons.hardDrive),
            label: 'Rosters',
          ),
        ],
      ),
    );
  }
}
