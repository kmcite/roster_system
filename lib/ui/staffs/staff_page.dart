import 'package:roster_system/domain/models/staff.dart';
import 'package:roster_system/main.dart';
import 'package:roster_system/domain/api/staffs_repository.dart';

mixin class StaffBloc {
  Staff staff([a]) {
    throw '';
  }

  final editing = staffsRepository.editing;
  void toggleEditing() => editing(!editing());

  void delete() {
    staffsRepository.remove(staff().id);
    navigator.back();
  }

  void save() {
    staff(staff());
    staffsRepository.put(staff());
  }

  String getStaffHours(int id) => '';
  bool get hasChanges {
    final actual = staffsRepository.get(staff().id);
    final current = staff();
    return actual?.name != current.name;
  }
}

class StaffPage extends UI with StaffBloc {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        prefixActions: [
          FButton.icon(
            onPress: navigator.back,
            child: FIcon(FAssets.icons.arrowLeft),
          ),
        ],
        suffixActions: [
          FButton.icon(
            onPress: toggleEditing,
            style: FButtonStyle.primary,
            child: FIcon(
              editing() ? FAssets.icons.penOff : FAssets.icons.pen,
            ),
          ),
          FButton.icon(
            onPress: delete,
            style: FButtonStyle.destructive,
            child: FIcon(FAssets.icons.delete),
          ),
        ],
        title: staff().name.text(),
      ),
      content: Column(
        children: [
          editing()
              ? FHeader(
                  title: FTextField(
                    initialValue: staff().name,
                    onChange: (value) {
                      staff(staff()..name = value);
                    },
                  ).pad(),
                  actions: [
                    FButton.icon(
                      onPress: hasChanges ? save : null,
                      child: FIcon(FAssets.icons.save),
                    ),
                  ],
                )
              : staff().name.text(textScaleFactor: 2),
        ],
      ),
    );
  }
}
