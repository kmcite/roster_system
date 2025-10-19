import 'package:roster_system/domain/models/roster_entry.dart';
import 'package:roster_system/domain/models/staff.dart';
import 'package:roster_system/main.dart';

import '../../domain/api/staffs_repository.dart';

class DutyAssignementBloc extends Bloc {
  StaffsRepository staffsRepository = depend();
  Iterable<Staff> get staffs => staffsRepository.staffs;
}

class DutyAssignementDialog extends UI<DutyAssignementBloc> {
  const DutyAssignementDialog(this.entry);
  @override
  DutyAssignementBloc create() => DutyAssignementBloc();

  final RosterEntry entry;

  @override
  Widget build(context) {
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
        if (context.staffs.isEmpty)
          FButton(
            onPress: null,
            child: const Text('No staffs available'),
          )
        else
          ...context.staffs.map(
            (staff) {
              return FButton(
                style: staff.id == entry.staff.target?.id
                    ? FButtonStyle.destructive()
                    : FButtonStyle.primary(),
                onPress: () {
                  navigator.back(staff);
                },
                child: Text(staff.name),
              );
            },
          ),
      ],
    );
  }
}
