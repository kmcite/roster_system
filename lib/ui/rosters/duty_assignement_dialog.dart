import 'package:roster_system/domain/models/roster_entry.dart';
import 'package:roster_system/domain/models/staff.dart';
import 'package:roster_system/main.dart';

import '../../domain/api/staffs_repository.dart';

mixin DutyAssignementBloc {
  Iterable<Staff> get staffs => staffsRepository.getAll();
}

class DutyAssignementDialog extends UI with DutyAssignementBloc {
  const DutyAssignementDialog(this.entry);
  final RosterEntry entry;

  @override
  Widget build(BuildContext context) {
    return FDialog(
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            entry.day.name.toUpperCase().text().pad(),
            '|'.text(),
            entry.shift.name.toUpperCase().text().pad(),
          ],
        ),
      ),
      body: const Text('Select a staff to assign.'),
      actions: [
        if (staffs.isEmpty)
          FButton(
            onPress: null,
            label: const Text('No staffs available'),
          )
        else
          ...staffs.map(
            (staff) {
              return FButton(
                style: staff.id == entry.staff.targetId
                    ? FButtonStyle.destructive
                    : FButtonStyle.primary,
                onPress: () {
                  navigator.back(staff);
                },
                label: Text(staff.name),
              );
            },
          ),
      ],
    );
  }
}
