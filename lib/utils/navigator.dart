import 'package:navigation_builder/navigation_builder.dart';
import 'package:roster_system/main.dart';

class NavigationRepository extends Repository<int> {
  final navigator = NavigationBuilder.navigate;
  GlobalKey<NavigatorState> get key => navigator.navigatorKey;
  late final to = navigator.to;
  late final back = navigator.back;
  late final dialog = navigator.toDialog;
}
