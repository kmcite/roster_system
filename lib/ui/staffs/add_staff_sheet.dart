import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:provider/provider.dart';
import 'package:roster_system/api/staff.dart';
import 'package:roster_system/notifiers/staff_list_notifier.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';

class AddStaffSheet extends StatefulWidget {
  const AddStaffSheet({super.key});

  @override
  State<AddStaffSheet> createState() => _AddStaffSheetState();
}

class _AddStaffSheetState extends State<AddStaffSheet> {
  final _controller = TextEditingController();
  String _name = '';

  static const _suggestions = [
    'Alex Morgan',
    'Jordan Lee',
    'Sam Taylor',
    'Riley Chen',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.trim();
    if (name.isEmpty) return;
    await context.read<StaffListNotifier>().add(Staff()..name = name);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _applySuggestion(String name) {
    _controller.text = name;
    setState(() => _name = name);
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.glassAccent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Row(
          children: [
            GlassCircle(
              size: 44,
              child: Icon(FLucideIcons.userPlus, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New team member',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                  Text(
                    'Type a name and tap Add — or pick a suggestion.',
                    style: TextStyle(fontSize: 12, color: accent.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ],
        ),
        GlassTextField(
          controller: _controller,
          hint: 'Full name',
          prefixIcon: Icon(FLucideIcons.user, color: accent),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onChanged: (v) => setState(() => _name = v),
          onSubmitted: (_) => _submit(),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final name in _suggestions)
              GlassChip(label: name, onTap: () => _applySuggestion(name)),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlassButton(
                label: 'Add',
                primary: true,
                enabled: _name.trim().isNotEmpty,
                icon: FLucideIcons.check,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void openAddStaffSheet(BuildContext context) {
  showGlassSheet<void>(context, child: const AddStaffSheet());
}
