import 'package:roster_system/domain/models/staff.dart';

import '../../main.dart';

final staffsRepository = StaffsRepository();

class StaffsRepository extends CRUD<Staff> {
  // final staffRM = RM.inject(() => Staff());
  // Staff staff([Staff? _staff]) {
  //   if (_staff != null) {
  //     staffRM
  //       ..state = _staff
  //       ..notify();
  //   }
  //   return staffRM.state;
  // }

  final editingRM = RM.inject(() => false);
  bool editing([bool? _editing]) {
    if (_editing != null) {
      editingRM
        ..state = _editing
        ..notify();
    }
    return editingRM.state;
  }
}
