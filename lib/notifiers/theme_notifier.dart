import 'package:flutter/foundation.dart';
import 'package:roster_system/services/preferences_service.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier(this._preferences) : _isDark = _preferences.isDarkMode;

  final PreferencesService _preferences;
  bool _isDark;

  bool get isDark => _isDark;

  Future<void> toggle() async {
    _isDark = !_isDark;
    await _preferences.setDarkMode(_isDark);
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    await _preferences.setDarkMode(_isDark);
    notifyListeners();
  }
}
