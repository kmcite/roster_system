import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roster_system/notifiers/roster_list_notifier.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';

class RosterRemovalDialog extends StatelessWidget {
  const RosterRemovalDialog({super.key, required this.rosterId});

  final int rosterId;

  Future<void> _onRemoveRoster(BuildContext context) async {
    await context.read<RosterListNotifier>().remove(rosterId);
    if (!context.mounted) return;
    Navigator.of(context).pop(true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialogFrame(
      title: const Text('Remove Roster'),
      body: const Text('Are you sure you want to remove this roster?'),
      actions: [
        GlassButton(
          label: 'Cancel',
          icon: Icons.close_rounded,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        GlassButton(
          label: 'Remove',
          primary: true,
          icon: Icons.check_rounded,
          onPressed: () => _onRemoveRoster(context),
        ),
      ],
    );
  }
}
