import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:provider/provider.dart';
import 'package:roster_system/api/roster_entry.dart';
import 'package:roster_system/api/shift.dart';
import 'package:roster_system/notifiers/roster_list_notifier.dart';
import 'package:roster_system/notifiers/staff_list_notifier.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';

class DutyAssignmentSheet extends StatefulWidget {
  const DutyAssignmentSheet({super.key, required this.entry});

  final RosterEntry entry;

  @override
  State<DutyAssignmentSheet> createState() => _DutyAssignmentSheetState();
}

class _DutyAssignmentSheetState extends State<DutyAssignmentSheet> {
  String _query = '';

  Future<void> _assign(int staffId) async {
    await context.read<RosterListNotifier>().assignStaffId(widget.entry, staffId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _unassign() async {
    await context.read<RosterListNotifier>().clearAssignment(widget.entry);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final staffs = context
        .watch<StaffListNotifier>()
        .staff
        .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final accent = context.glassAccent;
    final shift = widget.entry.shift;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            children: [
              GlassCircle(size: 48, child: shift.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.entry.day.shortLabel} · ${shift.displayName}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: accent,
                      ),
                    ),
                    Text(
                      '${shift.hours}h duty block',
                      style: TextStyle(fontSize: 12, color: accent.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GlassSearchField(
            hint: 'Search staff…',
            onChanged: (q) => setState(() => _query = q),
          ),
          if (staffs.isEmpty)
            GlassEmptyState(
              icon: FLucideIcons.userX,
              message: _query.isEmpty
                  ? 'Add team members first, then assign duties here.'
                  : 'No match for "$_query".',
            )
          else
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.92,
                ),
                itemCount: staffs.length,
                itemBuilder: (_, i) {
                  final staff = staffs[i];
                  final selected = widget.entry.staff.targetId == staff.id;
                  return GlassTappableCard(
                    onTap: selected ? null : () => _assign(staff.id),
                    tint: selected ? accent.withValues(alpha: 0.25) : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassAvatar(label: staff.name, size: 40),
                        const SizedBox(height: 6),
                        Text(
                          staff.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          Row(
            children: [
              if (widget.entry.staff.target != null)
                Expanded(
                  child: GlassButton(
                    label: 'Unassign',
                    icon: FLucideIcons.x,
                    onPressed: _unassign,
                  ),
                ),
              if (widget.entry.staff.target != null) const SizedBox(width: 8),
              Expanded(
                child: GlassButton(
                  label: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void openDutyAssignmentSheet(BuildContext context, RosterEntry entry) {
  showGlassSheet<void>(
    context,
    child: DutyAssignmentSheet(entry: entry),
  );
}
