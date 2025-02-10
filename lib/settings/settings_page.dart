import 'package:forui/forui.dart';
import 'package:manager/manager.dart';
import 'package:roster_system/settings/settings.dart';

class SettingsPage extends UI {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: 'Settings'.text(),
      ),
      content: ListView(
        children: [
          FButton.icon(
            onPress: () {
              final currentTheme = settingsRM.themeMode();
              if (currentTheme == ThemeMode.light) {
                settingsRM.themeMode(ThemeMode.dark);
              } else if (currentTheme == ThemeMode.dark) {
                settingsRM.themeMode(ThemeMode.light);
              } else {
                final brightness = MediaQuery.of(context).platformBrightness;
                if (brightness == Brightness.dark) {
                  settingsRM.themeMode(ThemeMode.light);
                } else {
                  settingsRM.themeMode(ThemeMode.dark);
                }
              }
            },
            child: FIcon(FAssets.icons.galleryThumbnails),
          ).pad(),
        ],
      ),
    );
  }
}
