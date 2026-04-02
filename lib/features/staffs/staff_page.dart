import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:roster_system/api/database.dart';
import 'package:roster_system/api/navigation.dart';
import 'package:roster_system/api/staff.dart';

class StaffPage extends StatelessWidget {
  final Staff staff;

  const StaffPage({super.key, required this.staff});

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(staff.name),
        actions: [
          IconButton.outlined(
            onPressed: () {
              staffs.remove(staff.id);
            },
            icon: Icon(FIcons.delete),
            tooltip: 'Delete Staff',
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
              /// Profile Card
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: .all(24.0),
                  child: Column(
                    spacing: 16,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                        child: Icon(
                          FIcons.user,
                          size: 56,
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                      Column(
                        spacing: 4,
                        children: [
                          Text(
                            staff.name,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                          if (staff.dutyPlace != null)
                            Chip(
                              label: Text(
                                'Duty: ${staff.dutyPlace}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer.withValues(
                                    alpha: 0.3,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              /// Quick Actions Card
              Card(
                child: Padding(
                  padding: .all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Row(
                        children: [
                          Icon(FIcons.edit, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Actions',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Divider(),
                      FilledButton.icon(
                        onPressed: () {
                          navigateToDialog(StaffEditDialog(staff));
                        },
                        icon: Icon(FIcons.pen),
                        label: Text('Edit Profile'),
                      ),
                    ],
                  ),
                ),
              ),

              /// Statistics Card
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
                            'Work Summary',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text(
                                  'Total Hours',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '${staff.totalHours}h',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text(
                                  'Assignments',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '${staff.entries.length}',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
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
}

class StaffEditDialog extends StatefulWidget {
  final Staff staff;
  const StaffEditDialog(this.staff, {super.key});

  @override
  State<StaffEditDialog> createState() => _StaffEditDialogState();
}

class _StaffEditDialogState extends State<StaffEditDialog> {
  final nameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    nameController.text = widget.staff.name;
  }

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
          Icon(FIcons.edit, size: 24),
          SizedBox(width: 8),
          Text('Edit Staff Profile'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            /// Name Field
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Staff Name',
                hintText: 'Enter staff name',
                prefixIcon: Icon(FIcons.user),
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
          onPressed: () {
            staffs.put(widget.staff..name = nameController.text);
            navigateBack();
          },
          icon: Icon(FIcons.check),
          label: Text('Save Changes'),
        ),
      ],
    );
  }
}
