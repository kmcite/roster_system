import 'package:roster_system/domain/api/roster_entries_repository.dart';
import 'package:roster_system/domain/models/roster_entry.dart';
import 'package:roster_system/domain/api/rosters_repository.dart';
import 'package:roster_system/domain/models/day.dart';
import 'package:roster_system/domain/models/staff.dart';
import 'package:roster_system/domain/models/shift.dart';
import 'package:roster_system/main.dart';
import 'package:roster_system/ui/rosters/cell.dart';
import 'package:roster_system/ui/rosters/duty_assignement_dialog.dart';
import '../../domain/models/roster.dart';

mixin class RosterBloc {
  final hasChangesRM = RM.inject(() => false);
  // Iterable<Staff> get staffs => staffsRepository.getAll();
  Roster roster([a]) => throw '';
  void deleteRoster() {
    rostersRepository.remove(roster().id);
    navigator.back();
  }

  bool get hasChanges => hasChangesRM.state;

  String name([String? value]) {
    if (value != null) {
      roster(roster()..name = value);
      hasChangesRM.state = true;
    }
    return roster().name;
  }

  void saveRoster() {
    rostersRepository.put(roster());
    hasChangesRM.state = false;
  }

  void assignStaffToRosterEntry(RosterEntry entry, Staff? staff) {
    entry.staff.target = staff;
    rosterEntriesRepository.put(entry);
    hasChangesRM.state = false;
  }

  String cell(Day day, Shift shift) {
    final entry = roster().getEntry(day, shift);
    return entry?.staff.target?.name ?? '';
  }
}

class RosterPage extends UI with RosterBloc {
  RosterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: roster().name.text(),
        prefixActions: [
          FButton.icon(
            onPress: navigator.back,
            child: FIcon(FAssets.icons.arrowLeft),
          ),
        ],
        suffixActions: [
          FButton.icon(
            child: FIcon(FAssets.icons.save),
            style: FButtonStyle.primary,
            onPress: hasChanges ? saveRoster : null,
          ),
          FButton.icon(
            child: FIcon(FAssets.icons.delete),
            style: FButtonStyle.destructive,
            onPress: deleteRoster,
          ),
        ],
      ),
      content: Column(
        children: [
          FTextField(
            key: Key(roster().id.toString()),
            initialValue: name(),
            onChange: name,
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
                      cell(day, shift),
                      onPressed: () async {
                        RosterEntry? entryFrom(Day day, Shift shift) {
                          return roster().entries.where(
                            (entry) {
                              return entry.day == day && entry.shift == shift;
                            },
                          ).firstOrNull;
                        }

                        final entry = entryFrom(day, shift);
                        if (entry != null) {
                          final staff = await navigator.dialog<Staff>(
                            DutyAssignementDialog(entry),
                          );
                          if (staff?.id == entry.staff.targetId) {
                            assignStaffToRosterEntry(entry, null);
                          } else {
                            assignStaffToRosterEntry(entry, staff);
                          }
                        }
                        hasChangesRM.state = true;
                        hasChangesRM.state = false;
                      },
                    ),
                  ),
              ],
            ),
          // Wrap(
          //   children: staffs.where(
          //     (staff) {
          //       return getStaffHours(staff.id) > 0;
          //     },
          //   ).map(
          //     (staff) {
          //       return FBadge(
          //         label: Text(
          //           '${staff.name} ${getStaffHours(staff.id)}',
          //         ),
          //       ).pad();
          //     },
          //   ).toList(),
          // ),
        ],
      ),
    );
  }
}
