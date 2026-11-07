class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String initial = splash;

  /// Auth entry point used when the API invalidates the session.
  static const String login = '/login';

  // Shell branches — order MUST match `shellDestinations` and `AppRouter`.
  static const String home = '/home';
  static const String menu = '/menu';

  /// Dish details; keep it under the menu branch so the shell stays visible.
  /// Nested go_router paths must stay relative to the parent route.
  static const String menuItemSegment = 'item/:itemId';

  static String menuItemPath(int itemId) => '/menu/item/$itemId';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String store = '/store';
}
