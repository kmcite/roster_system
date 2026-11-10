import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:provider/provider.dart';
import 'package:roster_system/domain/roster_coverage.dart';
import 'package:roster_system/notifiers/roster_list_notifier.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';
import 'package:roster_system/ui/rosters/new_roster_dialog.dart';
import 'package:roster_system/ui/rosters/roster_page.dart';

class RostersPage extends StatelessWidget {
  const RostersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rosters = context.watch<RosterListNotifier>();
    final accent = context.glassAccent;

    return GlassTabPage(
      eyebrow: 'PLANNING',
      title: 'Schedule',
      subtitle: 'Open a roster to assign duties by day and shift.',
      actions: [
        GlassIconButton(
          icon: FLucideIcons.plusCircle,
          tooltip: 'New roster',
          onPressed: () => showGlassDialog<void>(
            context,
            builder: const NewRosterDialog(),
          ),
        ),
      ],
      body: Padding(
        padding: AppGlassTheme.pagePadding.copyWith(top: 0),
        child: Column(
          spacing: 14,
          children: [
            GlassStatBanner(
              title: 'Rosters',
              value: '${rosters.count}',
              leading: Icon(FLucideIcons.calendar1, size: 28, color: accent),
            ),
            if (rosters.isEmpty)
              const Expanded(
                child: GlassEmptyState(
                  icon: FLucideIcons.calendarX,
                  message: 'Create your first roster to start scheduling duties.',
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: rosters.count,
                  itemBuilder: (_, index) {
                    final roster = rosters.at(index)!;
                    final cov = roster.coverage;
                    return GlassListTile(
                      title: roster.name,
                      subtitle: '${cov.label} duties filled',
                      leading: GlassCircle(
                        size: 44,
                        child: Icon(FLucideIcons.calendar, color: accent),
                      ),
                      trailing: GlassChip(
                        label: '${cov.percentRounded}%',
                        icon: Icon(FLucideIcons.pieChart, size: 12, color: accent),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => RosterPage(rosterId: roster.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
