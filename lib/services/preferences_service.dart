import 'package:hive_flutter/hive_flutter.dart';

class PreferencesService {
  PreferencesService(this._box);

  final Box _box;

  static const darkModeKey = 'dark_mode';
  static const navIndexKey = 'nav_index';

  bool get isDarkMode => _box.get(darkModeKey, defaultValue: true) as bool;

  Future<void> setDarkMode(bool value) => _box.put(darkModeKey, value);

  int get navIndex => _box.get(navIndexKey, defaultValue: 0) as int;

  Future<void> setNavIndex(int value) => _box.put(navIndexKey, value);
}
