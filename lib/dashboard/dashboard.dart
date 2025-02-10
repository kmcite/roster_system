import 'package:forui/forui.dart';
// import 'package:manager/manager.dart' hide FilledButton;
import 'package:roster_system/dashboard/navigation_targets.dart';
import 'package:roster_system/main.dart';

class DashboardPage extends UI {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      content: NavigationTargets.values[navigationIndexRM.state].page,
      footer: FBottomNavigationBar(
        index: navigationIndexRM.state,
        onChange: (value) => navigationIndexRM.state = value,
        children: [
          ...NavigationTargets.values.map(
            (target) {
              return FBottomNavigationBarItem(
                icon: FIcon(target.icon),
                label: target.name.text(),
              );
            },
          )
        ],
      ),
    );
  }
}
