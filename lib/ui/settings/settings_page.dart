import 'package:manager/dark/dark_repository.dart';
import '../../main.dart';

void toggle() => darkRepository.state = !dark;
bool get dark => darkRepository.state;

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
          FButton(
            onPress: toggle,
            label: FIcon(
              dark ? FAssets.icons.moon : FAssets.icons.sun,
              size: 48,
            ).pad(),
          ).pad(),
        ],
      ),
    );
  }
}
