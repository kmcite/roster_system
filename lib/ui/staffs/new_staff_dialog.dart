import 'package:roster_system/domain/api/staffs_repository.dart';
import 'package:roster_system/domain/models/staff.dart';
import 'package:roster_system/main.dart';

class NewStaffBloc extends Bloc {
  /// DEPENDENCIES
  StaffsRepository staffsRepository = depend();

  /// LOCAL STATE
  late final staff = local<Staff?>(() => null);
  String get staffName => staff()?.name ?? '';
  bool get isStaffNotCreated => staff() == null;

  /// INITIALIZER
  @override
  void initState() {
    super.initState();
    create();
  }

  /// MUTATIONS
  void onNameChanged(String? value) {
    staff.set(staff()?..name = value ?? '');
  }

  /// initState -> hooker
  void create() {
    staff.set(Staff());
  }

  /// BUTTON ACTIONS
  void cancel() {
    staff.set(null);
    navigator.back();
  }

  void save() {
    if (staff() != null) {
      staffsRepository.put(staff()!);
    }
    cancel();
  }
}

class NewStaffDialog extends UI<NewStaffBloc> {
  @override
  NewStaffBloc create() => NewStaffBloc();

  @override
  Widget build(context) {
    return FDialog(
      title: 'New Staff'.text(),
      body: Column(
        children: [
          context.isStaffNotCreated
              ? FButton.icon(
                  onPress: context.create,
                  child: Icon(FIcons.plus),
                )
              : FTextField(
                  label: 'Name'.text(),
                  initialText: context.staffName,
                  onChange: context.onNameChanged,
                ),
        ],
      ),
      direction: Axis.horizontal,
      actions: [
        FButton(
          onPress: context.staffName.isEmpty ? null : context.save,
          child: 'Save'.text(),
        ),
        FButton(
          onPress: context.cancel,
          child: 'Cancel'.text(),
        ),
      ],
    );
  }
}
