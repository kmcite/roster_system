import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:roster_system/api/database.dart';
import 'package:roster_system/api/navigation.dart';
import 'package:roster_system/features/rosters/new_roster_dialog.dart';
import 'package:roster_system/features/rosters/roster_page.dart';

class RostersPage extends StatefulWidget {
  const RostersPage({super.key});

  @override
  State<RostersPage> createState() => _RostersPageState();
}

class _RostersPageState extends State<RostersPage> {
  StreamSubscription? _rostersSubscription;
  @override
  void initState() {
    super.initState();
    _rostersSubscription = rosters.watch().listen((rosters) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _rostersSubscription?.cancel();
    _rostersSubscription = null;
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rosters'),
        actions: [
          IconButton(
            onPressed: () => navigateToDialog(NewRosterDialog()),
            icon: Icon(FIcons.plusCircle),
            tooltip: 'Add Roster',
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
                    Icon(FIcons.calendar1, size: 28),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            'Total Rosters',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                          Text(
                            '${rosters.length ?? 0}',
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

            /// Roster List
            if (rosters.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      Icon(
                        FIcons.calendarX,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      Text(
                        'No rosters yet',
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
                  itemCount: rosters.length,
                  itemBuilder: (_, index) {
                    final roster = rosters.at(index);
                    return ListTile(
                      shape: RoundedRectangleBorder(borderRadius: .circular(8)),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        child: Icon(
                          FIcons.calendar,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                      title: Text(
                        roster.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      trailing: Icon(FIcons.chevronRight),
                      onTap: () {
                        navigateTo(RosterPage(roster));
                      },
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
