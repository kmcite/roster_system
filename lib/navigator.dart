import 'package:flutter/material.dart';
import 'package:navigation_builder/navigation_builder.dart';

class Navigation {
  final navigator = NavigationBuilder.navigate;
  GlobalKey<NavigatorState> get key => navigator.navigatorKey;
  late final to = navigator.to;
  late final back = navigator.back;
  late final dialog = navigator.toDialog;
}

final navigator = Navigation();
