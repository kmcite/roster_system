import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:provider/provider.dart';
import 'package:roster_system/api/staff.dart';
import 'package:roster_system/domain/staff_workload.dart';
import 'package:roster_system/notifiers/staff_list_notifier.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';

class StaffPage extends StatelessWidget {
  const StaffPage({super.key, required this.staffId});

  final int staffId;

  @override
  Widget build(BuildContext context) {
    final staff = context.watch<StaffListNotifier>().byId(staffId);
    if (staff == null) {
      return const GlassRouteScaffold(
        title: 'Staff',
        body: Center(child: Text('Staff member not found')),
      );
    }

    final accent = context.glassAccent;

    return GlassRouteScaffold(
      title: staff.name,
      actions: [
        GlassIconButton(
          icon: FLucideIcons.delete,
          tooltip: 'Delete Staff',
          onPressed: () async {
            await context.read<StaffListNotifier>().remove(staff.id);
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
        const SizedBox(width: 8),
      ],
      body: SingleChildScrollView(
        padding: AppGlassTheme.pagePadding,
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassPanel(
              radius: AppGlassTheme.radiusLg,
              child: Column(
                spacing: 16,
                children: [
                  GlassAvatar(label: staff.name, size: 96),
                  Text(
                    staff.name,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                  if (staff.dutyPlace != null)
                    GlassChip(label: 'Duty: ${staff.dutyPlace}'),
                ],
              ),
            ),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  const GlassSectionHeader(title: 'Actions'),
                  GlassButton(
                    label: 'Edit Profile',
                    icon: FLucideIcons.pen,
                    primary: true,
                    onPressed: () => showGlassDialog<void>(
                      context,
                      builder: StaffEditDialog(staff: staff),
                    ),
                  ),
                ],
              ),
            ),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  const GlassSectionHeader(title: 'Work Summary'),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(label: 'Total Hours', value: '${staff.totalHours}h'),
                      ),
                      Expanded(
                        child: _MetricTile(
                          label: 'Assignments',
                          value: '${staff.assignmentCount}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class StaffEditDialog extends StatefulWidget {
  const StaffEditDialog({super.key, required this.staff});

  final Staff staff;

  @override
  State<StaffEditDialog> createState() => _StaffEditDialogState();
}

class _StaffEditDialogState extends State<StaffEditDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    widget.staff.name = _nameController.text;
    await context.read<StaffListNotifier>().update(widget.staff);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialogFrame(
      title: const Row(
        children: [
          Icon(FLucideIcons.edit, size: 22),
          SizedBox(width: 8),
          Text('Edit Staff Profile'),
        ],
      ),
      body: GlassTextField(
        label: 'Staff Name',
        hint: 'Enter staff name',
        controller: _nameController,
        prefixIcon: const Icon(FLucideIcons.user),
      ),
      actions: [
        GlassButton(
          label: 'Cancel',
          icon: FLucideIcons.x,
          onPressed: () => Navigator.of(context).pop(),
        ),
        GlassButton(
          label: 'Save Changes',
          icon: FLucideIcons.check,
          primary: true,
          onPressed: _save,
        ),
      ],
    );
  }
}
