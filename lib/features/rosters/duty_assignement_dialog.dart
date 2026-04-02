import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:roster_system/api/database.dart';
import 'package:roster_system/api/navigation.dart';
import 'package:roster_system/api/roster_entry.dart';
import 'package:roster_system/api/shift.dart';

class DutyAssignementDialog extends StatelessWidget {
  const DutyAssignementDialog(this.entry, {super.key});
  final RosterEntry entry;

  @override
  Widget build(context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FIcons.calendar, size: 20),
          SizedBox(width: 8),
          Text('${entry.day.code} | ${entry.shift.code}'),
          SizedBox(width: 8),
          Chip(
            label: Text(
              '${entry.shift.hours}h',
              style: TextStyle(fontSize: 12),
            ),
            padding: .zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            'Select staff to assign:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (staffs.isEmpty)
            Container(
              width: double.infinity,
              padding: .all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    FIcons.info,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No staff available. Please create staff first.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: .stretch,
              children: [
                for (final staff in staffs.getAll())
                  () {
                    final isAssigned = entry.staff.targetId == staff.id;
                    return Padding(
                      padding: .only(bottom: 4),
                      child: OutlinedButton.icon(
                        onPressed: isAssigned
                            ? null
                            : () {
                                entry.staff.target = staff;
                                entries.put(entry);
                                navigateBack();
                              },
                        icon: Icon(
                          isAssigned ? FIcons.checkCircle : FIcons.user,
                          size: 18,
                        ),
                        label: Text(staff.name),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          backgroundColor: isAssigned
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                        ),
                      ),
                    );
                  }(),
              ],
            ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            if (entry.staff.target != null) {
              entry.staff.target = null;
              entries.put(entry);
            }
            navigateBack();
          },
          icon: Icon(FIcons.x),
          label: Text(entry.staff.target != null ? 'Unassign' : 'Cancel'),
        ),
      ],
    );
  }
}
