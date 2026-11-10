import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:provider/provider.dart';
import 'package:roster_system/domain/roster_coverage.dart';
import 'package:roster_system/notifiers/roster_list_notifier.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';
import 'package:roster_system/ui/rosters/onduty_staff.dart';
import 'package:roster_system/ui/rosters/roster_duty_board.dart';
import 'package:roster_system/ui/rosters/roster_removal_dialog.dart';

class RosterPage extends StatelessWidget {
  const RosterPage({super.key, required this.rosterId});

  final int rosterId;

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final roster = context.watch<RosterListNotifier>().byId(rosterId);
    if (roster == null) {
      return const GlassRouteScaffold(
        title: 'Roster',
        body: Center(child: Text('Roster not found')),
      );
    }

    final staffHours = roster.hoursByStaffName();
    final accent = context.glassAccent;
    return GlassRouteScaffold(
      title: roster.name,
      actions: [
        GlassIconButton(
          icon: FLucideIcons.delete,
          tooltip: 'Delete roster',
          onPressed: () => showGlassDialog<void>(
            context,
            builder: RosterRemovalDialog(rosterId: roster.id),
          ),
        ),
        const SizedBox(width: 8),
      ],
      body: SingleChildScrollView(
        padding: AppGlassTheme.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 18,
          children: [
            GlassPanel(
              surface: GlassSurface.elevated,
              radius: AppGlassTheme.radiusLg,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Effective from',
                          style: AppGlassTheme.pageSubtitle(
                            context,
                            isDark: context.glassIsDark,
                          ),
                        ),
                        Text(
                          _formatDate(roster.startDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Effective till',
                          style: AppGlassTheme.pageSubtitle(
                            context,
                            isDark: context.glassIsDark,
                          ),
                        ),
                        Text(
                          roster.effectiveTill != null
                              ? _formatDate(roster.effectiveTill!)
                              : 'Open-ended',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            RosterDutyBoard(roster: roster),
            const GlassSectionHeader(title: 'Hours by staff'),
            GlassPanel(
              child: staffHours.isEmpty
                  ? Text(
                      'Assign duties above to see hours accumulate here.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: accent.withValues(alpha: 0.7),
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final staff in staffHours.entries)
                          GlassChip(
                            label: '${staff.key}: ${staff.value}h',
                            icon: Icon(FLucideIcons.user, size: 14, color: accent),
                          ),
                      ],
                    ),
            ),
            const GlassSectionHeader(title: 'Live duty status'),
            const WhoIsInNowFeatureView(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
