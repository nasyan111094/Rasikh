import 'package:flutter/material.dart';

/// Extends [RouteObserver] (not plain [NavigatorObserver]) so screens can use
/// the route lifecycle via [RouteAware]. Since Flutter 3.35 `subscribe` /
/// `unsubscribe` live on [RouteObserver]; `didPush` / `didPop` below call
/// `super`, which is what notifies the subscribed [RouteAware]s.
class NavObs extends RouteObserver<Route<dynamic>> {
  /// Shared instance registered on the root [MaterialApp].
  /// Screens that need a route lifecycle callback ([RouteAware]) must subscribe
  /// to *this* exact observer, so it has to be reachable as a singleton.
  static final NavObs instance = NavObs('MAIN');

  final String title;

  NavObs(this.title);

  List<String> pages = [];

  String? get current {
    if (pages.isEmpty) {
      return null;
    }
    return pages.last;
  }

  printStack() => debugPrint('${title}_NAV:-\n${pages.join('\n')}');

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final name = route.settings.name;
    if (name != null) {
      pages.add(name);
    }
    printStack();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final name = route.settings.name;
    if (name != null) {
      pages.remove(name);
    }
    printStack();
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    final name = route.settings.name;
    if (name != null) {
      //todo fix
      pages.remove(name);
    }
    printStack();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final oldName = oldRoute?.settings.name;
    final newName = oldRoute?.settings.name;
    if (oldName != null) {
      pages.remove(oldName);
    }
    if (newName != null) {
      pages.add(newName);
    }
    printStack();
  }
}
