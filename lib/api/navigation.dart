import 'package:flutter/material.dart'
    show GlobalKey, MaterialPageRoute, NavigatorState, Widget, showDialog;

final navigator = GlobalKey<NavigatorState>();

Future<T?> navigateTo<T extends Object?>(Widget widget) async {
  return navigator.currentState?.push(
    MaterialPageRoute(builder: (context) => widget),
  );
}

void navigateBack<T extends Object?>([T? result]) =>
    navigator.currentState?.pop(result);
Future<T?> navigateToDialog<T extends Object?>(Widget widget) async {
  return showDialog<T>(
    context: navigator.currentContext!,
    builder: (context) => widget,
  );
}
