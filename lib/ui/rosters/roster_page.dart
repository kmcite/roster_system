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

class RosterBloc extends Bloc {
  late RostersRepository rostersRepository = depend();
  late RosterEntriesRepository rosterEntriesRepository = depend();

  late final hasChangesRM = local(() => false);
  // Iterable<Staff> get staffs => staffsRepository.getAll();
  Roster roster([a]) => Roster();
  void deleteRoster() {
    rostersRepository.remove(roster().id);
    navigator.back();
  }

  bool get hasChanges => hasChangesRM();

  String name([String? value]) {
    if (value != null) {
      roster(roster()..name = value);
      hasChangesRM(true);
    }
    return roster().name;
  }

  void saveRoster() {
    rostersRepository.put(roster());
    hasChangesRM(false);
  }

  void assignStaffToRosterEntry(RosterEntry entry, Staff? staff) {
    entry.staff.target = staff;
    rosterEntriesRepository.put(entry);
    hasChangesRM(false);
  }

  String cell(Day day, Shift shift) {
    final entry = roster().getEntry(day, shift);
    return entry?.staff.target?.name ?? '';
  }
}

class RosterPage extends UI<RosterBloc> {
  @override
  RosterBloc create() => RosterBloc();

  RosterPage({super.key});
  @override
  Widget build(context) {
    return FScaffold(
      header: FHeader.nested(
        title: context.roster().name.text(),
        prefixes: [
          FButton.icon(
            onPress: navigator.back,
            child: Icon(FIcons.arrowLeft),
          ),
        ],
        suffixes: [
          FButton.icon(
            child: Icon(FIcons.save),
            style: FButtonStyle.primary(),
            onPress: context.hasChanges ? context.saveRoster : null,
          ),
          FButton.icon(
            child: Icon(FIcons.delete),
            style: FButtonStyle.destructive(),
            onPress: context.deleteRoster,
          ),
        ],
      ),
      child: Column(
        children: [
          FTextField(
            key: Key(context.roster().id.toString()),
            initialText: context.name(),
            onChange: context.name,
          ).pad(),

          /// header row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FAvatar.raw(child: Icon(FIcons.clock)),
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
                  child: FAvatar.raw(child: Cell(day.code)).pad(),
                ),
                for (final shift in Shift.values)
                  Expanded(
                    flex: 3,
                    child: Cell(
                      context.cell(day, shift),
                      onPressed: () async {
                        RosterEntry? entryFrom(Day day, Shift shift) {
                          return context.roster().entries.where(
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
                          if (staff?.id == entry.staff.target?.id) {
                            context.assignStaffToRosterEntry(entry, null);
                          } else {
                            context.assignStaffToRosterEntry(entry, staff);
                          }
                        }
                        context.hasChangesRM(true);
                        context.hasChangesRM(false);
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
