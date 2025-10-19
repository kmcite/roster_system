import 'package:roster_system/domain/models/staff.dart';
import 'package:roster_system/main.dart';
import 'package:roster_system/domain/api/staffs_repository.dart';

class StaffBloc extends Bloc {
  late StaffsRepository staffsRepository = depend();

  /// dependent state
  final Staff _staff;
  StaffBloc(this._staff);

  late final editing = global(staffsRepository.editing);
  Iterable<Staff> get staffs => (staffsRepository.staffs);

  /// current staff being shown in ui
  late final staff = local(() => _staff);
  String get staffName => staff().name;

  /// actualy store in db
  Staff? get() => staffs.where((staff) => staff.id == _staff.id).firstOrNull;

  @override
  void initState() {
    super.initState();
    print(get());
    print(staff());
  }

  @override
  void dispose() {
    staff.dispose();
    super.dispose();
  }

  void toggleEditing() => editing(!editing());

  void remove(int id) {
    staffsRepository.remove(id);
    navigator.back();
  }

  void save() {
    staffsRepository.put(staff());
  }

  bool get hasChanges {
    return get()?.name != staff().name;
  }

  void onNameChanged(String value) {
    staff(staff()..name = value);
  }
}

class StaffPage extends UI<StaffBloc> {
  @override
  StaffBloc create() => StaffBloc(staff);

  final Staff staff;

  const StaffPage({
    super.key,
    required this.staff,
  });

  @override
  Widget build(context) {
    return FScaffold(
      header: FHeader(
        title: context.staffName.text(),
        suffixes: [
          FButton.icon(
            onPress: context.toggleEditing,
            style: FButtonStyle.primary(),
            child: Icon(
              context.editing() ? FIcons.penOff : FIcons.pen,
            ),
          ),
          FButton.icon(
            onPress: () => context.remove(staff.id),
            style: FButtonStyle.destructive(),
            child: Icon(FIcons.delete),
          ),
          FButton.icon(
            onPress: navigator.back,
            child: Icon(FIcons.arrowLeft),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          FTextField(
            initialText: context.staffName,
            onChange: context.onNameChanged,
          ),
          FButton.icon(
            onPress: context.hasChanges ? context.save : null,
            child: Icon(FIcons.save),
          ),
          Text(
            staff.name,
            style: TextStyle(fontSize: 32),
          ),
          Text('entries'),
          Text('rosters'),
        ],
      ),
    );
  }
}
