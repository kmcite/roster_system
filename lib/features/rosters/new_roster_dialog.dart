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
  final nameController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
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
                prefixIcon: Icon(FIcons.edit),
                border: OutlineInputBorder(),
              ),
              controller: nameController,
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            navigateBack();
          },
          icon: Icon(FIcons.x),
          label: Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: nameController.text.isEmpty
              ? null
              : () {
                  final roster = Roster()..name = nameController.text;
                  roster.generateEntries();
                  rosters.put(roster);
                  navigateBack();
                },
          icon: Icon(FIcons.check),
          label: Text('Create Roster'),
        ),
      ],
    );
  }
}
