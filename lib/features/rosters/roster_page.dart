import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:roster_system/api/day.dart';
import 'package:roster_system/api/navigation.dart';
import 'package:roster_system/api/roster_entry.dart';
import 'package:roster_system/api/shift.dart';
import 'package:roster_system/features/rosters/cell.dart';
import 'package:roster_system/features/rosters/duty_assignement_dialog.dart';
import 'package:roster_system/api/roster.dart';
import 'package:roster_system/api/database.dart';

class RosterPage extends StatefulWidget {
  const RosterPage(this.roster, {super.key});
  final Roster roster;

  @override
  State<RosterPage> createState() => _RosterPageState();
}

class _RosterPageState extends State<RosterPage> {
  StreamSubscription? _rosterSubscription;
  StreamSubscription? _entriesSubscription;
  late Roster roster;

  /// Calculate staff hours for this specific roster in real-time
  Map<String, int> get staffHours {
    final hours = <String, int>{};
    for (final entry in roster.entries) {
      final staff = entry.staff.target;
      if (staff != null) {
        hours[staff.name] = (hours[staff.name] ?? 0) + entry.shift.hours;
      }
    }
    return hours;
  }

  @override
  void initState() {
    super.initState();
    roster = widget.roster;
    _rosterSubscription = rosters.watchById(roster.id).listen((updatedRoster) {
      if (mounted) setState(() {});
    });
    _entriesSubscription = entries.watch().listen((event) {
      if (mounted) setState(() {});
    });
  }

  void onRosterNameChanged(String name) {
    roster.name = name;
    rosters.put(roster);
  }

  @override
  void dispose() {
    _rosterSubscription?.cancel();
    _entriesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roster.name),
        actions: [
          IconButton.outlined(
            onPressed: () {
              rosters.remove(roster.id);
              navigateBack();
            },
            icon: Icon(FIcons.delete),
            tooltip: 'Delete Roster',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: .all(16.0),
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Roster Name Editor
              // Card(
              //   child: Padding(
              //     padding: .all(12.0),
              //     child: TextFormField(
              //       decoration: InputDecoration(
              //         labelText: 'Roster Name',
              //         prefixIcon: Icon(FIcons.edit),
              //         border: OutlineInputBorder(),
              //       ),
              //       initialValue: roster.name,
              //       onChanged: onRosterNameChanged,
              //     ),
              //   ),
              // ),

              /// Roster Grid
              Card(
                child: Padding(
                  padding: .all(12.0),
                  child: Column(
                    spacing: 8,
                    children: [
                      /// Header row
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: CircleAvatar(
                                radius: 20,
                                child: Icon(FIcons.calendar, size: 20),
                              ),
                            ),
                          ),
                          for (final shift in Shift.values)
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Tooltip(
                                  message:
                                      '${shift.name.toUpperCase()} (${shift.hours}h)',
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: _getShiftColor(
                                      shift,
                                    ).withValues(alpha: 0.5),
                                    child: shift.icon,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      /// Day rows
                      for (final day in Day.values)
                        Row(
                          spacing: 8,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: Text(
                                    day.code,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w100,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            for (final shift in Shift.values)
                              Expanded(
                                flex: 3,
                                child: AspectRatio(
                                  aspectRatio: 1.5,
                                  child: Cell(
                                    roster
                                            .getEntry(day, shift)
                                            ?.staff
                                            .target
                                            ?.name ??
                                        '-',
                                    onPressed: () async {
                                      var entry = roster.getEntry(day, shift);
                                      if (entry == null) {
                                        entry = RosterEntry()
                                          ..day = day
                                          ..shift = shift
                                          ..roster.target = roster;
                                        entries.put(entry);
                                      }
                                      navigateToDialog(
                                        DutyAssignementDialog(entry),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              /// Staff Hours Summary
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: .all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Row(
                        children: [
                          Icon(FIcons.clock, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Staff Hours Summary',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Divider(),
                      if (staffHours.isEmpty)
                        Text(
                          'No staff assigned yet',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final staff in staffHours.entries)
                              Chip(
                                avatar: Icon(FIcons.user, size: 16),
                                label: Text('${staff.key}: ${staff.value}h'),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getShiftColor(Shift shift) {
    return switch (shift) {
      Shift.morning => Colors.amber,
      Shift.evening => Colors.orange,
      Shift.night => Colors.indigo,
    };
  }
}
