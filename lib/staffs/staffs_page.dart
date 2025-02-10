import 'package:forui/forui.dart';
import 'package:manager/manager.dart';
import 'package:roster_system/experimental/blocs.dart';
import 'package:roster_system/experimental/models.dart';

class StaffsPage extends UI {
  const StaffsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FHeader(
          title: 'staffs'.text(),
          actions: [
            FHeaderAction(
              onPress: () {
                staffsBloc.put(Staff()..name = 'adn');
              },
              icon: FIcon(FAssets.icons.plus),
            ),
            FSwitch(
              value: staffsBloc.editing,
              onChange: (_) => staffsBloc.toggleEditing(),
            ),
          ],
        ),
        ...staffsBloc.staffs.map(
          (staff) {
            return Column(
              children: [
                FHeader(
                  title: staffsBloc.editing
                      ? FTextField(
                          initialValue: staff.name,
                          onChange: (value) {
                            staffsBloc.put(staff..name = value);
                          },
                        ).pad()
                      : staff.name.text(),
                  actions: [
                    FBadge(
                      label: rostersBloc.getStaffHours(staff.id).text(),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
