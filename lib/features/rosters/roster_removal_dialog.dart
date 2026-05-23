import 'package:flutter/material.dart';
import 'package:roster_system/api/database.dart';
import 'package:roster_system/api/navigation.dart';
import 'package:roster_system/api/roster.dart';

class RosterRemovalDialog extends StatefulWidget {
  final Roster roster;
  const RosterRemovalDialog(this.roster, {super.key});

  @override
  State<RosterRemovalDialog> createState() => _RosterRemovalDialogState();
}

class _RosterRemovalDialogState extends State<RosterRemovalDialog> {
  late Roster roster;
  @override
  void initState() {
    super.initState();
    roster = widget.roster;
  }

  void onRemoveRoster() {
    final result = rosters.remove(roster.id);
    navigateBack(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Remove Roster'),
      content: Text('Are you sure you want to remove this roster?'),
      actions: [
        FilledButton(
          onPressed: onRemoveRoster,
          child: Icon(Icons.done_outline),
        ),
        FilledButton(
          onPressed: navigateBack,
          child: Icon(Icons.cancel_outlined),
        ),
      ],
    );
  }
}
