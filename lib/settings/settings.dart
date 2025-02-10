import '../main.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
class Settings with _$Settings {
  const factory Settings({
    @MaterialColorConverter()
    @Default(Colors.blueGrey)
    final MaterialColor materialColor,
    @Default(ThemeMode.system) final ThemeMode themeMode,
    @Default(0) final int pageIndex,
    @Default(1.0) final double textScaleFactor,
    @Default(8.0) final double borderRadius,
    @Default(8.0) final double padding,
  }) = _Settings;
  const Settings._();

  factory Settings.fromJson(json) => _$SettingsFromJson(json);
}

final SettingsRM settingsRM = SettingsRM();

class SettingsRM {
  final settingsRM = RM.inject(
    () => Settings(),
    persist: () => PersistState(
      key: 'settings',
      fromJson: (json) => Settings.fromJson(jsonDecode(json)),
      toJson: (state) => jsonEncode(state.toJson()),
    ),
  );

  Settings settings([Settings? _settings]) {
    if (_settings != null) settingsRM.state = _settings;
    return settingsRM.state;
  }

  MaterialColor materialColor([MaterialColor? _materialColor]) {
    if (_materialColor != null)
      settings(
        settings().copyWith(materialColor: _materialColor),
      );
    return settings().materialColor;
  }

  int pageIndex([int? _pageIndex]) {
    if (_pageIndex != null)
      settings(
        settings().copyWith(pageIndex: _pageIndex),
      );
    return settings().pageIndex;
  }

  ThemeMode themeMode([ThemeMode? _themeMode]) {
    if (_themeMode != null)
      settings(
        settings().copyWith(themeMode: _themeMode),
      );
    return settings().themeMode;
  }

  double textScaleFactor([double? _textScaleFactor]) {
    if (_textScaleFactor != null)
      settings(
        settings().copyWith(textScaleFactor: _textScaleFactor),
      );
    return settings().textScaleFactor;
  }

  double borderRadius([double? _]) {
    if (_ != null)
      settings(
        settings().copyWith(borderRadius: _),
      );
    return settings().borderRadius;
  }

  double padding([double? _]) {
    if (_ != null)
      settings(
        settings().copyWith(padding: _),
      );
    return settings().padding;
  }
}
