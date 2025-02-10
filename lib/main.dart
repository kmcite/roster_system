// export 'package:manager/manager.dart';

export 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roster_system/objectbox.g.dart';

import 'main.dart';
import 'settings/settings.dart';

export 'dart:async';
export 'package:flutter/foundation.dart';
export 'package:flutter_native_splash/flutter_native_splash.dart';
// export 'package:freezed_annotation/freezed_annotation.dart';
export 'package:states_rebuilder/states_rebuilder.dart';
export 'package:roster_system/dashboard/dashboard.dart';

void main() async {
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );
  await RM.storageInitializer(HiveStorage());
  final storage = await getApplicationDocumentsDirectory();
  final appName = await PackageInfo.fromPlatform();
  store = await openStore(
    directory: storage.path + appName.appName,
  );
  runApp(App());
}

final navigator = RM.navigate;

class App extends UI {
  @override
  void didMountWidget(BuildContext context) {
    super.didMountWidget(context);
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigator.navigatorKey,
      home: DashboardPage(),
      themeMode: settingsRM.themeMode(),
      builder: (context, child) => FTheme(
        data: switch (settingsRM.themeMode()) {
          ThemeMode.light => FThemes.yellow.light,
          _ => FThemes.yellow.dark,
        },
        child: child!,
      ),
    );
  }
}

typedef UI = ReactiveStatelessWidget;
