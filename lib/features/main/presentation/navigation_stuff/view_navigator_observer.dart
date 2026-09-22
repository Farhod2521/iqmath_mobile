import 'package:flutter/material.dart';

class ViewNavigatorObserver extends NavigatorObserver {
  ViewNavigatorObserver(this.onNavigation);

  final Function(String) onNavigation;

  @override
  void didPop(Route route, Route? previousRoute) {
    onNavigation(previousRoute?.settings.name ?? '');
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    onNavigation(route.settings.name ?? '');
    super.didPush(route, previousRoute);
  }
}
