import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roster_system/api/shift.dart';
import 'package:roster_system/domain/current_duty.dart';
import 'package:roster_system/services/duty_status_service.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';

class LiveDutyController extends ChangeNotifier {
  LiveDutyController(this._dutyStatus) : snapshot = _dutyStatus.snapshot() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _tick());
  }

  final DutyStatusService _dutyStatus;
  Timer? _refreshTimer;

  CurrentDutySnapshot snapshot;

  void _tick() {
    final next = _dutyStatus.snapshot();
    if (next.day != snapshot.day ||
        next.shift != snapshot.shift ||
        next.staff?.id != snapshot.staff?.id) {
      snapshot = next;
      notifyListeners();
      return;
    }
    snapshot = next;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

class DutyStatusCard extends StatelessWidget {
  const DutyStatusCard({
    super.key,
    required this.snapshot,
    required this.onTap,
  });

  final CurrentDutySnapshot snapshot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasStaff = snapshot.isCovered;
    final accent = context.glassAccent;

    return GlassTappableCard(
      onTap: onTap,
      surface: GlassSurface.elevated,
      child: Row(
        children: [
          GlassCircle(
            size: 52,
            child: Icon(
              hasStaff ? Icons.health_and_safety : Icons.notification_important_rounded,
              color: context.glassSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasStaff ? snapshot.staff!.name : 'No one on duty',
                  style: TextStyle(fontWeight: FontWeight.bold, color: accent),
                ),
                const SizedBox(height: 4),
                Text(
                  '${snapshot.day.shortLabel} · ${snapshot.shift.displayName}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accent.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 22, color: accent),
        ],
      ),
    );
  }
}

class LiveDutyDialog extends StatelessWidget {
  const LiveDutyDialog({super.key, required this.snapshot});

  final CurrentDutySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final empty = !snapshot.isCovered;
    final accent = context.glassAccent;
    return GlassDialogFrame(
      title: Row(
        children: [
          Icon(
            empty ? Icons.info_outline_rounded : Icons.check_circle_outline_rounded,
            color: accent,
          ),
          const SizedBox(width: 10),
          Text(empty ? 'Shift uncovered' : 'On duty now'),
        ],
      ),
      body: Text(
        empty
            ? 'Nobody is assigned for ${snapshot.day.shortLabel} ${snapshot.shift.displayName.toLowerCase()} '
                'across your rosters.'
            : '${snapshot.staff!.name} is scheduled for '
                '${snapshot.shift.displayName.toLowerCase()} (${snapshot.shift.hours}h).',
      ),
      actions: [
        GlassButton(
          label: 'Dismiss',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class LiveDutyPanel extends StatefulWidget {
  const LiveDutyPanel({super.key});

  @override
  State<LiveDutyPanel> createState() => _LiveDutyPanelState();
}

class _LiveDutyPanelState extends State<LiveDutyPanel> {
  LiveDutyController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final service = context.read<DutyStatusService>();
      _controller = LiveDutyController(service);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final snap = controller.snapshot;
        return DutyStatusCard(
          snapshot: snap,
          onTap: () => showGlassDialog<void>(
            context,
            builder: LiveDutyDialog(snapshot: snap),
          ),
        );
      },
    );
  }
}

/// Kept for roster detail screen import stability.
typedef WhoIsInNowFeatureView = LiveDutyPanel;
