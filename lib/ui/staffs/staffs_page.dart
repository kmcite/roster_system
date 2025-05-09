import 'package:roster_system/domain/models/shift.dart';
import 'package:roster_system/domain/models/staff.dart';
import 'package:roster_system/ui/staffs/new_staff_dialog.dart';
import 'package:roster_system/ui/staffs/staff_page.dart';
import 'package:roster_system/domain/api/staffs_repository.dart';
import '../../main.dart';

mixin class StaffsBloc {
  Iterable<Staff> get staffs => staffsRepository.getAll();

  void put(Staff staff) {
    staffsRepository.put(staff);
  }

  void remove(int id) {
    staffsRepository.remove(id);
  }

  int getStaffHours(int id) {
    final staff = staffsRepository.get(id);
    if (staff == null) {
      return 0;
    }
    final hours = staff.entries.map((entry) => entry.shift.hours);
    return hours.fold(0, (initialValue, combine) => initialValue + combine);
  }

  void staffDetails(Staff staff) {
    // staffsRepository.item(staff);
    navigator.to(StaffPage());
  }
}

class StaffsPage extends UI with StaffsBloc {
  const StaffsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FHeader(
          title: 'Staffs'.text(),
          actions: [
            FButton.icon(
              onPress: () {
                navigator.dialog(NewStaffDialog());
              },
              child: FIcon(FAssets.icons.plus),
            ),
          ],
        ),
        FTileGroup.builder(
          divider: FTileDivider.full,
          count: staffs.length,
          tileBuilder: (context, index) {
            final staff = staffs.elementAt(index);
            return FTile(
              title: staff.name.text(),
              onPress: () {
                staffDetails(staff);
              },
            );
          },
        ).pad(),
      ],
    );
  }
}
