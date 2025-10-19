// export 'package:manager/manager.dart';

export 'package:forui/forui.dart';
export 'package:roster_system/utils/navigator.dart';
export 'package:roster_system/utils/extensions.dart';

export 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roster_system/domain/api/rosters_repository.dart';
import 'package:roster_system/domain/api/settings_repository.dart';
import 'package:roster_system/domain/api/staffs_repository.dart';
import 'package:roster_system/objectbox.g.dart' hide Box;
export 'package:roster_system/utils/architecture.dart';

import 'main.dart';

export 'dart:async';
export 'package:flutter_native_splash/flutter_native_splash.dart';
export 'package:roster_system/ui/dashboard/dashboard.dart';

void main() {
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );
  AppRunner(
    initialize: () async {
      final path = await getApplicationDocumentsDirectory();
      serve<Store>(await openStore(directory: path.path));
      await Hive.initFlutter();
      serve<Box>(await Hive.openBox('roster_system'));

      depend(SettingsRepository());
      depend(StaffsRepository());
      depend(RostersRepository());
    },
    app: Application(),
  );
}

class ApplicationBloc extends Bloc {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  late SettingsRepository settingsRepository = depend();

  late final dark = global(settingsRepository.dark);
}

class Application extends UI<ApplicationBloc> {
  @override
  ApplicationBloc create() => ApplicationBloc();

  @override
  Widget build(controller) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigator.key,
      home: DashboardPage(),
      themeMode: controller.dark() ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => FTheme(
        data: switch (controller.dark()) {
          true => FThemes.yellow.dark,
          false => FThemes.yellow.light,
        },
        child: child!,
      ),
    );
  }
}
