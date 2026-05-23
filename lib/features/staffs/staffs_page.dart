import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:roster_system/api/database.dart';
import 'package:roster_system/api/navigation.dart';
import 'package:roster_system/api/roster.dart';
import 'package:roster_system/api/staff.dart';
import 'package:roster_system/features/staffs/new_staff_dialog.dart';
import 'package:roster_system/features/staffs/staff_page.dart';

class StaffsPage extends StatefulWidget {
  const StaffsPage({super.key});

  @override
  State<StaffsPage> createState() => _StaffsPageState();
}

class _StaffsPageState extends State<StaffsPage> {
  StreamSubscription<List<Staff>>? _staffs;
  StreamSubscription<List<Roster>>? _rosters;
  @override
  void initState() {
    super.initState();
    _staffs = staffs.watch().listen((_) {
      if (mounted) setState(() {});
    });
    _rosters = rosters.watch().listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _rosters?.cancel();
    _staffs?.cancel();
    _rosters = null;
    _staffs = null;
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Members'),
        actions: [
          IconButton(
            onPressed: () => dark.toggle(),
            icon: Icon(
              dark() ? FIcons.moon : FIcons.sun,
              size: 24,
            ),
            tooltip: dark() ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
          IconButton(
            onPressed: () {
              navigateToDialog(NewStaffDialog());
            },
            icon: Icon(FIcons.plusCircle),
            tooltip: 'Add Staff',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: .all(16.0),
        child: Column(
          spacing: 16,
          children: [
            /// Summary Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: .all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.onPrimary,
                      child: Icon(FIcons.users, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            'Total Staff',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                          Text(
                            '${staffs.length ?? 0}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Staff List
            if (staffs.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      Icon(
                        FIcons.userX,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      Text(
                        'No staff members yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: staffs.length,
                  itemBuilder: (_, index) {
                    final staff = staffs.at(index);
                    return Card(
                      margin: .only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          child: Icon(
                            FIcons.user,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                        title: Text(
                          staff.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: staff.dutyPlace != null
                            ? Text(
                                'Duty Place: ${staff.dutyPlace}',
                                style: Theme.of(context).textTheme.bodySmall,
                              )
                            : null,
                        trailing: Icon(FIcons.chevronRight),
                        onTap: () {
                          navigateTo(StaffPage(staff: staff));
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
