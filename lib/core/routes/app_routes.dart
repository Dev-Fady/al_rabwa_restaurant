class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String initial = splash;

  /// First-run device registration (name + phone) that stores the token.
  static const String registration = '/register';

  /// Auth entry point used when the API invalidates the session.
  static const String login = '/login';

  // Shell branches — order MUST match `shellDestinations` and `AppRouter`.
  static const String home = '/home';
  static const String menu = '/menu';

  /// Dish details; keep it under the menu branch so the shell stays visible.
  /// Nested go_router paths must stay relative to the parent route.
  static const String menuItemSegment = 'item/:itemId';

  /// Every menu section as a card grid, also inside the menu branch.
  static const String menuCategoriesSegment = 'categories';
  static const String menuCategories = '/menu/categories';

  static String menuItemPath(int itemId) => '/menu/item/$itemId';

  /// Add-address form; pushed above the shell and returns the saved address.
  static const String addAddress = '/addresses/add';

  /// Saved-address picker; returns the selected address to the caller.
  static const String selectAddress = '/addresses/select';

  /// Read-only address details; `/addresses/detail/:id`.
  static const String addressDetails = '/addresses/detail/:id';

  static String addressDetailsPath(int id) => '/addresses/detail/$id';

  static const String cart = '/cart';

  /// Cart checkout; pushed above the shell so the order form has focus.
  static const String checkout = '/checkout';

  static const String orders = '/orders';

  /// One order; keep it under the orders branch so the shell stays visible.
  static const String orderDetailsSegment = ':orderId';

  static String orderDetailsPath(int orderId) => '/orders/$orderId';

  static const String store = '/store';
}
