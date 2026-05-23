import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:roster_system/api/database.dart';
import 'package:roster_system/api/navigation.dart';
import 'package:roster_system/api/roster.dart';

class NewRosterDialog extends StatefulWidget {
  const NewRosterDialog({super.key});

  @override
  State<NewRosterDialog> createState() => _NewRosterDialogState();
}

class _NewRosterDialogState extends State<NewRosterDialog> {
  String rosterName = '';
  void onNameChanged(String name) {
    setState(() => rosterName = name);
  }

  void onRosterCreated() {
    final roster = Roster()..name = rosterName;
    roster.generateEntries();
    rosters.put(roster);
    navigateBack();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(FIcons.calendarPlus, size: 24),
          SizedBox(width: 8),
          Text('Create New Roster'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Roster Name',
                hintText: 'Enter roster name',
                // prefixIcon: Icon(FIcons.edit),
                border: OutlineInputBorder(),
              ),
              initialValue: rosterName,
              onChanged: onNameChanged,
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: navigateBack,
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: rosterName.isEmpty ? null : onRosterCreated,
          child: Text('Create Roster'),
        ),
      ],
    );
  }
}
