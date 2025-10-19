import 'package:roster_system/domain/models/staff.dart';

import '../../main.dart';

class StaffsRepository extends Repository<Staff> {
  late final editing = inject(() => false);
  late final cache = inject(
    () => <int, Staff>{
      for (final staff in box.getAll()) staff.id: staff,
    },
  );
  Iterable<Staff> get staffs => cache().values;
  void put(Staff staff) {
    box.put(staff);
    cache.refresh();
  }
}
