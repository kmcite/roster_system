import 'package:roster_system/utils/architecture.dart';

class SettingsRepository extends Repository {
  late var dark = inject(() => true);

  void toggle() {
    dark.set(!dark());
  }
}
