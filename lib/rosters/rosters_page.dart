import 'package:forui/forui.dart';
import 'package:roster_system/experimental/blocs.dart';

import '../experimental/models.dart';
import '../main.dart';
import 'enums.dart';

class RostersPage extends UI {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: Text('Rosters'),
        actions: [
          FHeaderAction(
            icon: FIcon(FAssets.icons.plus),
            onPress: () => rostersBloc.put(
              Roster()..generateEntries(),
            ),
          ),
        ],
      ),
      content: ListView.builder(
        itemCount: rostersBloc.rosters.length,
        itemBuilder: (context, index) {
          final roster = rostersBloc.rosters.elementAt(index);
          return rosterRM.inherited(
            stateOverride: () => roster,
            builder: (context) => FTile(
              title: Text(roster.name),
              subtitle: roster.entries.length.text(),
              onPress: () => navigator.to(
                rosterRM.inherited(
                  stateOverride: () => roster,
                  builder: (context) => RosterPage(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RosterPage extends UI {
  RosterPage({super.key});
  @override
  Widget build(BuildContext context) {
    final roster = rosterRM.of(context);
    return FScaffold(
      header: FHeader(
        title: roster.name.text(),
        actions: [
          FHeaderAction.back(onPress: navigator.back),
          FHeaderAction(
            icon: FIcon(FAssets.icons.delete),
            onPress: () {
              rostersBloc.remove(roster.id);
              navigator.back();
            },
          ),
        ],
      ),
      content: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FTextField(
            key: Key(roster.id.toString()),
            initialValue: roster.name,
            onChange: (name) => rostersBloc.put(roster..name = name),
          ).pad(),

          /// header row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FAvatar.raw(child: FIcon(FAssets.icons.clock)),
              ),
              for (final shift in Shift.values)
                Expanded(
                  flex: 3,
                  child: FAvatar.raw(child: shift.icon),
                ),
            ],
          ),

          /// remaining rows
          for (final day in Day.values)
            Row(
              children: [
                /// first column
                Expanded(
                  flex: 2,
                  child: FAvatar.raw(child: Cell(day.code)).pad(all: 4),
                ),
                for (final shift in Shift.values)
                  Expanded(
                    flex: 3,
                    child: Cell(
                      roster.getEntry(day, shift).staff.target?.name ?? '',
                      onPressed: () async {
                        final entry = roster.getEntry(day, shift);
                        final staff = await navigator.toDialog<Staff>(
                          rosterRM.inherited(
                            stateOverride: () => roster,
                            builder: (context) => DutyAssignementDialog(entry),
                          ),
                        );
                        if (staff != null) {
                          entry.staff.target = staff;
                          staffsBloc.put(entry.staff.target!);
                          rosterEntriesBloc.put(entry);
                        } else {
                          entry.staff.target = null;
                          rosterEntriesBloc.put(entry);
                        }
                      },
                    ),
                  ),
              ],
            ),
          Wrap(
            children: staffsBloc.staffs.where(
              (staff) {
                return roster.getStaffHours(staff.id) > 0;
              },
            ).map(
              (staff) {
                return FBadge(
                  label: Text(
                    '${staff.name} ${roster.getStaffHours(staff.id)}',
                  ),
                ).pad();
              },
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class Cell extends UI {
  final String data;

  final VoidCallback? onPressed;
  const Cell(
    this.data, {
    this.onPressed,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return FTooltip(
      tipBuilder: (_, __, ___) => data.text(),
      child: FTappable(
        child: data.text(
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        onPress: onPressed,
      ),
    );
  }
}

class DutyAssignementDialog extends UI {
  const DutyAssignementDialog(this.entry);
  final RosterEntry entry;

  @override
  Widget build(BuildContext context) {
    return FDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          entry.day.name.toUpperCase().text().pad(),
          '|'.text(),
          entry.shift.name.toUpperCase().text().pad(),
        ],
      ),
      body: const Text('Select a staff to assign.'),
      actions: [
        if (staffsBloc.staffs.isEmpty)
          FButton(
            onPress: null,
            label: const Text('No staffs available'),
          )
        else
          ...staffsBloc.staffs.where(
            (staff) {
              return rosterRM.of(context).getStaffHours(staff.id) < 36;
            },
          ).map(
            (staff) {
              return FButton(
                style: staff.id == entry.staff.targetId
                    ? FButtonStyle.destructive
                    : FButtonStyle.primary,
                onPress: () {
                  navigator.back(staff);
                },
                label: Text(staff.name),
              );
            },
          ),
      ],
    );
  }
}
