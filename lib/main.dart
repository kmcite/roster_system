import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'
    show FlutterNativeSplash;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:roster_system/api/database.dart';
import 'package:roster_system/api/navigation.dart';
import 'package:roster_system/features/application_shell.dart';

import 'objectbox.g.dart' show openStore;

void main() async {
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );
  final path = await getApplicationDocumentsDirectory();
  await Hive.initFlutter();
  hive = await Hive.openBox('roster_system');
  objects = await openStore(
    directory: join(path.path, 'roster_system'),
  );

  runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  StreamSubscription? _darkSubscription;
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _darkSubscription = dark.watch().listen((event) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _darkSubscription?.cancel();
    _darkSubscription = null;
    super.dispose();
  }

  @override
  Widget build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigator,
      home: ApplicationShell(),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: dark() ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
