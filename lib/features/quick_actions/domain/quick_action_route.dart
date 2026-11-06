import 'package:marky/app/routing/routes.dart';

abstract final class QuickActionRoute {
  static const String home = Routes.home;
  static const String add = Routes.add;
  static const String search = Routes.search;
  static const String unread = Routes.homeUnread;
  static const String reminders = Routes.reminders;

  static const Set<String> supportedRoutes = <String>{
    home,
    add,
    search,
    unread,
    reminders,
  };

  static String? normalize(Object? value) {
    if (value is! String) return null;
    final String route = value.trim();
    return supportedRoutes.contains(route) ? route : null;
  }
}
