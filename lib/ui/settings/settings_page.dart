import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:provider/provider.dart';
import 'package:roster_system/api/shift.dart';
import 'package:roster_system/notifiers/theme_notifier.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeNotifier>().isDark;
    final accent = context.glassAccent;

    return GlassTabPage(
      eyebrow: 'PREFERENCES',
      title: 'Settings',
      subtitle: 'Appearance & shift rules',
      body: ListView(
        padding: AppGlassTheme.pagePadding,
        children: [
          const GlassSectionHeader(title: 'Appearance'),
          GlassPanel(
            child: Row(
              children: [
                GlassCircle(
                  size: 44,
                  child: Icon(
                    isDark ? FLucideIcons.moon : FLucideIcons.sun,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        isDark ? 'On — easier on the eyes at night' : 'Off — soft daylight palette',
                        style: TextStyle(fontSize: 12, color: accent.withValues(alpha: 0.65)),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: isDark,
                  activeTrackColor: accent,
                  onChanged: (_) => context.read<ThemeNotifier>().toggle(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const GlassSectionHeader(title: 'Shift schedule'),
          GlassPanel(
            child: Column(
              spacing: 10,
              children: [
                for (final shift in Shift.values)
                  GlassPanel(
                    radius: AppGlassTheme.radiusSm,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        shift.icon,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            shift.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        GlassChip(label: '${shift.hours}h', icon: Icon(FLucideIcons.clock, size: 14)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const GlassSectionHeader(title: 'About'),
          GlassPanel(
            child: Text(
              'Roster System helps you assign duties across the week with a clean, layered interface.',
              style: TextStyle(height: 1.4, color: accent.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }
}
