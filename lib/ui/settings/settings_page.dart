import 'package:roster_system/domain/api/settings_repository.dart';

import '../../main.dart';

class SettingsBloc extends Bloc {
  late final SettingsRepository settingsRepository = depend();
  void toggle() {
    settingsRepository.toggle();
  }

  late final dark = global(settingsRepository.dark);
}

class SettingsPage extends UI<SettingsBloc> {
  const SettingsPage({super.key});
  @override
  SettingsBloc create() => SettingsBloc();

  @override
  Widget build(context) {
    return FScaffold(
      header: FHeader(
        title: 'Settings'.text(),
      ),
      child: ListView(
        children: [
          FButton(
            onPress: context.toggle,
            child: Icon(
              context.dark() ? FIcons.moon : FIcons.sun,
              size: 48,
            ).pad(),
          ).pad(),
        ],
      ),
    );
  }
}
