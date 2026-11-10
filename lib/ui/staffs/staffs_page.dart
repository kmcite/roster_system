import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:provider/provider.dart';
import 'package:roster_system/notifiers/staff_list_notifier.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';
import 'package:roster_system/ui/staffs/add_staff_sheet.dart';
import 'package:roster_system/ui/staffs/staff_page.dart';

class StaffsPage extends StatefulWidget {
  const StaffsPage({super.key});

  @override
  State<StaffsPage> createState() => _StaffsPageState();
}

class _StaffsPageState extends State<StaffsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final staffList = context.watch<StaffListNotifier>();
    final accent = context.glassAccent;
    final filtered = staffList.staff
        .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return GlassTabPage(
      eyebrow: 'PEOPLE',
      title: 'Team',
      subtitle: 'Add people once, assign them across the roster.',
      floatingActionButton: GlassFab(
        icon: FLucideIcons.userPlus,
        label: 'Add staff',
        onPressed: () => openAddStaffSheet(context),
      ),
      body: Padding(
        padding: AppGlassTheme.pagePadding.copyWith(top: 0),
        child: Column(
          spacing: 14,
          children: [
            GlassStatBanner(
              title: 'Active staff',
              value: '${staffList.staff.length}',
              leading: Icon(FLucideIcons.users, size: 28, color: accent),
            ),
            if (staffList.staff.isNotEmpty)
              GlassSearchField(
                hint: 'Search by name…',
                onChanged: (q) => setState(() => _query = q),
              ),
            if (staffList.staff.isEmpty)
              Expanded(
                child: GlassEmptyState(
                  icon: FLucideIcons.userPlus,
                  message: 'Build your team in seconds.\nTap “Add staff” below.',
                  action: GlassButton(
                    label: 'Add first member',
                    primary: true,
                    icon: FLucideIcons.plusCircle,
                    onPressed: () => openAddStaffSheet(context),
                  ),
                ),
              )
            else if (filtered.isEmpty)
              Expanded(
                child: GlassEmptyState(
                  icon: FLucideIcons.searchX,
                  message: 'No one matches “$_query”.',
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final staff = filtered[index];
                    return GlassListTile(
                      title: staff.name,
                      subtitle: staff.dutyPlace != null
                          ? 'Station ${staff.dutyPlace}'
                          : '${staff.entries.length} assignments · ${staff.totalHours}h',
                      leading: GlassAvatar(label: staff.name, size: 44),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => StaffPage(staffId: staff.id),
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
