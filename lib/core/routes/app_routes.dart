class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String initial = splash;

  /// Auth entry point used when the API invalidates the session.
  static const String login = '/login';

  // Shell branches — order MUST match `shellDestinations` and `AppRouter`.
  static const String home = '/home';
  static const String menu = '/menu';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String store = '/store';
}
