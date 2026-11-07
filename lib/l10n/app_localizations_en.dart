// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Al Rabwa Restaurant';

  @override
  String get navHome => 'Home';

  @override
  String get navMenu => 'Menu';

  @override
  String get navCart => 'Cart';

  @override
  String get navOrders => 'Orders';

  @override
  String get navStore => 'Store';

  @override
  String get homeWelcomeTitle => 'Welcome to Al Rabwa Restaurant';

  @override
  String get homeWelcomeSubtitle =>
      'Pick your favorite dishes from the menu and enjoy a special dining experience.';

  @override
  String get sectionComingSoon => 'Coming soon';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get pageNotFound => 'Page not found';
}
