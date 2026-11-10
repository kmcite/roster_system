import 'package:flutter/foundation.dart';
import 'package:roster_system/services/preferences_service.dart';

class ShellNotifier extends ChangeNotifier {
  ShellNotifier(this._preferences) : _index = _preferences.navIndex;

  final PreferencesService _preferences;
  int _index;

  int get index => _index;

  Future<void> setIndex(int value) async {
    if (_index == value) return;
    _index = value;
    await _preferences.setNavIndex(value);
    notifyListeners();
  }
}
