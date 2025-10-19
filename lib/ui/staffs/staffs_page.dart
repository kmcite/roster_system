import 'package:roster_system/domain/models/shift.dart';
import 'package:roster_system/domain/models/staff.dart';
import 'package:roster_system/ui/staffs/new_staff_dialog.dart';
import 'package:roster_system/ui/staffs/staff_page.dart';
import 'package:roster_system/domain/api/staffs_repository.dart';
import '../../main.dart';

class StaffsBloc extends Bloc {
  /// REPOSITORIES
  late StaffsRepository staffsRepository = depend();

  /// GLOBAL STATE
  Iterable<Staff> get staffs => staffsRepository.staffs;
  Staff? staff(int id) => staffsRepository.get(id);

  /// MUTATIONS
  void put(Staff staff) => staffsRepository.put(staff);

  void remove(int id) => staffsRepository.remove(id);

  int getStaffHours(int id) {
    final staff = staffsRepository.get(id);
    if (staff == null) {
      return 0;
    }
    final hours = staff.entries.map((entry) => entry.shift.hours);
    return hours.fold(0, (initialValue, combine) => initialValue + combine);
  }
}

class StaffsPage extends UI<StaffsBloc> {
  const StaffsPage({super.key});

  @override
  StaffsBloc create() => StaffsBloc();

  @override
  Widget build(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FHeader(
          title: 'Staffs'.text(),
          suffixes: [
            FButton.icon(
              onPress: () => navigator.dialog(NewStaffDialog()),
              child: Icon(FIcons.plus),
            ),
          ],
        ),
        context.staffs.isEmpty
            ? Text(
                'No staffs',
                // description: 'Add a staff to get started',
              )
            : FTileGroup.builder(
                divider: FItemDivider.full,
                count: context.staffs.length,
                tileBuilder: (_, index) {
                  final staff = context.staffs.elementAt(index);
                  return FTile(
                    title: staff.name.text(),
                    onPress: () {
                      navigator.to(StaffPage(staff: staff));
                    },
                  );
                },
              ).pad(),
      ],
    );
  }
}
