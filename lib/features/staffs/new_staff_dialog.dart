import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:roster_system/api/database.dart';
import 'package:roster_system/api/staff.dart';
import 'package:roster_system/api/navigation.dart';

class NewStaffDialog extends StatefulWidget {
  const NewStaffDialog({super.key});

  @override
  State<NewStaffDialog> createState() => _NewStaffDialogState();
}

class _NewStaffDialogState extends State<NewStaffDialog> {
  Staff? _staff;
  Staff get staff => _staff!;
  @override
  void initState() {
    super.initState();
    _staff = Staff();
  }

  void onNameChanged(String name) {
    setState(() => _staff!.name = name);
  }

  VoidCallback? get onAddStaffTapped {
    return staff.name.isEmpty
        ? null
        : () {
            if (_staff != null) staffs.put(staff);
            _staff = null;
            navigateBack();
          };
  }

  @override
  dispose() {
    _staff = null;
    super.dispose();
  }

  @override
  Widget build(context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(FIcons.userPlus, size: 24),
          SizedBox(width: 8),
          Text('Add New Staff'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Staff Name',
                hintText: 'Enter staff name',
                prefixIcon: Icon(FIcons.user),
                border: OutlineInputBorder(),
              ),
              initialValue: staff.name,
              onChanged: onNameChanged,
            ),
          ],
        ),
      ),
      actions: [
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => navigateBack(),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: onAddStaffTapped,
              child: Text('Add Staff'),
            ),
          ],
        ),
      ],
    );
  }
}
