import 'package:roster_system/domain/api/staffs_repository.dart';
import 'package:roster_system/domain/models/staff.dart';
import 'package:roster_system/main.dart';

mixin NewStaffBloc {
  final staffRM = RM.inject<Staff?>(() => null);

  Staff? staff([Staff? value, bool notify = false]) {
    if (value != null || notify) {
      staffRM
        ..state = value
        ..notify();
    }
    return staffRM.state;
  }

  String name([String? value]) {
    if (value != null) {
      staff(staff()?..name = value);
    }
    return staff()?.name ?? '';
  }

  void cancel() {
    staff(null, true);
    navigator.back();
  }

  void save() {
    if (staff() != null) {
      staffsRepository.put(staff()!);
    }
    cancel();
  }

  void create() => staff(Staff());
}

class NewStaffDialog extends UI with NewStaffBloc {
  @override
  Widget build(BuildContext context) {
    return FDialog(
      title: 'New Staff'.text(),
      body: Column(
        children: [
          staff() == null
              ? FButton.icon(
                  onPress: create,
                  child: FIcon(FAssets.icons.plus),
                )
              : FTextField(
                  label: 'Name'.text(),
                  initialValue: staff()?.name,
                  onChange: (value) {
                    staff(staff()!..name = value);
                  },
                ),
        ],
      ),
      direction: Axis.horizontal,
      actions: [
        FButton(
          onPress: staff()?.name.isEmpty ?? true ? null : save,
          label: 'Save'.text(),
        ),
        FButton(
          onPress: cancel,
          label: 'Cancel'.text(),
        ),
      ],
    );
  }
}
