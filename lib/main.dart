import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:provider/provider.dart';
import 'package:roster_system/notifiers/roster_list_notifier.dart';
import 'package:roster_system/notifiers/shell_notifier.dart';
import 'package:roster_system/notifiers/staff_list_notifier.dart';
import 'package:roster_system/notifiers/theme_notifier.dart';
import 'package:roster_system/objectbox.g.dart' show openStore;
import 'package:roster_system/services/duty_status_service.dart';
import 'package:roster_system/services/objectbox_service.dart';
import 'package:roster_system/services/preferences_service.dart';
import 'package:roster_system/ui/application_shell.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final path = await getApplicationDocumentsDirectory();
  await Hive.initFlutter();
  final store = await openStore(
    directory: join(path.path, 'roster_system'),
  );
  final hiveBox = await Hive.openBox('roster_system');

  final objectBox = ObjectBoxService(store);
  final preferences = PreferencesService(hiveBox);

  runApp(
    MultiProvider(
      providers: [
        Provider<ObjectBoxService>.value(value: objectBox),
        Provider<DutyStatusService>(
          create: (context) => DutyStatusService(context.read<ObjectBoxService>()),
        ),
        Provider<PreferencesService>.value(value: preferences),
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(preferences),
        ),
        ChangeNotifierProvider(
          create: (_) => ShellNotifier(preferences),
        ),
        ChangeNotifierProvider(
          create: (context) => StaffListNotifier(context.read<ObjectBoxService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => RosterListNotifier(context.read<ObjectBoxService>()),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeNotifier>().isDark;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ApplicationShell(),
      theme: AppGlassTheme.material(isDark: false),
      darkTheme: AppGlassTheme.material(isDark: true),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
