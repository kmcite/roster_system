export 'package:manager/manager.dart';

export 'package:forui/forui.dart';
export 'package:roster_system/navigator.dart';

export 'package:flutter/material.dart';
import 'package:manager/dark/dark_repository.dart';
// import 'package:roster_system/domain/api/dark_repository.dart';
import 'package:roster_system/objectbox.g.dart';
import 'main.dart';

export 'dart:async';
export 'package:flutter_native_splash/flutter_native_splash.dart';
export 'package:states_rebuilder/states_rebuilder.dart';
export 'package:roster_system/ui/dashboard/dashboard.dart';

void main() async {
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );
  manager(
    MainApp(),
    openStore: openStore,
  );
}

bool get dark => darkRepository.state;

class MainApp extends UI {
  @override
  void didMountWidget(BuildContext context) {
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigator.key,
      home: DashboardPage(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => FTheme(
        data: switch (dark) {
          true => FThemes.yellow.dark,
          false => FThemes.yellow.light,
        },
        child: child!,
      ),
    );
  }
}
