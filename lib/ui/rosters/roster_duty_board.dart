import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:provider/provider.dart';
import 'package:roster_system/api/day.dart';
import 'package:roster_system/api/roster.dart';
import 'package:roster_system/api/roster_entry.dart';
import 'package:roster_system/api/shift.dart';
import 'package:roster_system/domain/roster_coverage.dart';
import 'package:roster_system/domain/schedule_grid.dart';
import 'package:roster_system/notifiers/roster_list_notifier.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';
import 'package:roster_system/ui/rosters/cell.dart';
import 'package:roster_system/ui/rosters/duty_assignment_sheet.dart';

class RosterDutyBoard extends StatefulWidget {
  const RosterDutyBoard({super.key, required this.roster});

  final Roster roster;

  @override
  State<RosterDutyBoard> createState() => _RosterDutyBoardState();
}

class _RosterDutyBoardState extends State<RosterDutyBoard> {
  late Day _selectedDay;
  var _weekView = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = ScheduleGrid.dayFromDateTime(DateTime.now());
  }

  Future<void> _openSlot(Day day, Shift shift) async {
    final rosterNotifier = context.read<RosterListNotifier>();
    final entry = await rosterNotifier.ensureSlot(widget.roster, day, shift);
    if (!mounted) return;
    openDutyAssignmentSheet(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final coverage = widget.roster.coverage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        GlassCoverageBar(
          filled: coverage.filled,
          total: coverage.total,
          label: 'Roster coverage · ${coverage.percentRounded}%',
        ),
        const GlassSectionHeader(title: 'Pick a day'),
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: Day.values.length,
            itemBuilder: (_, i) {
              final day = Day.values[i];
              return GlassDayChip(
                label: day.shortLabel,
                filledCount: widget.roster.filledSlotsFor(day),
                slotTotal: ScheduleGrid.shiftsPerDay,
                selected: _selectedDay == day,
                onTap: () => setState(() => _selectedDay = day),
              );
            },
          ),
        ),
        GlassSectionHeader(
          title: _weekView ? 'Week overview' : 'Duty slots — ${_selectedDay.shortLabel}',
          trailing: GlassButton(
            label: _weekView ? 'Day view' : 'Week grid',
            onPressed: () => setState(() => _weekView = !_weekView),
          ),
        ),
        if (_weekView)
          _WeekGrid(roster: widget.roster, onCell: _openSlot)
        else
          Column(
            spacing: 10,
            children: [
              for (final shift in Shift.values)
                _ShiftDutyCard(
                  shift: shift,
                  entry: widget.roster.slot(_selectedDay, shift),
                  onTap: () => _openSlot(_selectedDay, shift),
                ),
            ],
          ),
      ],
    );
  }
}

class _ShiftDutyCard extends StatelessWidget {
  const _ShiftDutyCard({
    required this.shift,
    required this.entry,
    required this.onTap,
  });

  final Shift shift;
  final RosterEntry? entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.glassAccent;
    final staff = entry?.staff.target;
    final assigned = staff != null;

    return GlassTappableCard(
      onTap: onTap,
      tint: assigned ? shift.color.withValues(alpha: 0.18) : null,
      child: Row(
        children: [
          GlassCircle(size: 52, child: shift.icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  staff?.name ?? 'Tap to assign duty',
                  style: TextStyle(
                    fontSize: 14,
                    color: assigned ? accent : accent.withValues(alpha: 0.55),
                    fontWeight: assigned ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GlassChip(
                label: '${shift.hours}h',
                icon: Icon(FLucideIcons.clock, size: 12, color: accent),
              ),
              const SizedBox(height: 6),
              Icon(
                assigned ? FLucideIcons.checkCircle : FLucideIcons.plusCircle,
                color: assigned ? context.glassSecondary : accent.withValues(alpha: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.roster, required this.onCell});

  final Roster roster;
  final void Function(Day day, Shift shift) onCell;

  @override
  Widget build(BuildContext context) {
    final accent = context.glassAccent;
    return GlassPanel(
      child: Column(
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              const Expanded(flex: 2, child: SizedBox()),
              for (final shift in Shift.values)
                Expanded(
                  flex: 3,
                  child: Center(child: Tooltip(message: shift.code, child: shift.icon)),
                ),
            ],
          ),
          for (final day in Day.values)
            Row(
              spacing: 8,
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      day.code,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: accent,
                      ),
                    ),
                  ),
                ),
                for (final shift in Shift.values)
                  Expanded(
                    flex: 3,
                    child: AspectRatio(
                      aspectRatio: 1.4,
                      child: Cell(
                        roster.slot(day, shift)?.staff.target?.name ?? '—',
                        onPressed: () => onCell(day, shift),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
