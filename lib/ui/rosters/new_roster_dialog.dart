import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:provider/provider.dart';
import 'package:roster_system/api/roster.dart';
import 'package:roster_system/notifiers/roster_list_notifier.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';

class NewRosterDialog extends StatefulWidget {
  const NewRosterDialog({super.key});

  @override
  State<NewRosterDialog> createState() => _NewRosterDialogState();
}

class _NewRosterDialogState extends State<NewRosterDialog> {
  String _rosterName = '';

  Future<void> _onRosterCreated() async {
    final roster = Roster()..name = _rosterName;
    await context.read<RosterListNotifier>().add(roster);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialogFrame(
      title: const Row(
        children: [
          Icon(FLucideIcons.calendarPlus, size: 22),
          SizedBox(width: 8),
          Text('Create New Roster'),
        ],
      ),
      body: GlassTextField(
        label: 'Roster Name',
        hint: 'Enter roster name',
        onChanged: (name) => setState(() => _rosterName = name),
      ),
      actions: [
        GlassButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        GlassButton(
          label: 'Create Roster',
          primary: true,
          enabled: _rosterName.isNotEmpty,
          onPressed: _onRosterCreated,
        ),
      ],
    );
  }
}
