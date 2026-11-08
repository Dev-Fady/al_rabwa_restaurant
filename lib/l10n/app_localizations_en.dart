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
  String get storeOpenNow => 'Open now — taking orders';

  @override
  String get storeOpenShort => 'Open';

  @override
  String get storeClosed => 'Currently closed';

  @override
  String get orderStatus => 'Order status';

  @override
  String get storeInfoTitle => 'Restaurant info';

  @override
  String get orderOptionsTitle => 'Order options';

  @override
  String get browseMenu => 'Browse the menu';

  @override
  String get orderNow => 'Order now';

  @override
  String get retry => 'Try again';

  @override
  String get storeSettingsError =>
      'Couldn\'t load the restaurant. Check your connection and try again.';

  @override
  String get loadingStore => 'Loading the restaurant...';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get paymentLabel => 'Payment';

  @override
  String get deliveryFeeLabel => 'Delivery fee';

  @override
  String get taxLabel => 'Tax';

  @override
  String get serviceLabel => 'Service charge';

  @override
  String get deliveryZonesLabel => 'Delivery zones';

  @override
  String get reservationsLabel => 'Reservations';

  @override
  String get availableLabel => 'Available';

  @override
  String get workingHoursLabel => 'Working hours';

  @override
  String get locationRequiredLabel => 'Location';

  @override
  String get requiredLabel => 'Required';

  @override
  String get onlinePaymentLabel => 'Online payment';

  @override
  String get contactTitle => 'Contact us';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get whatsappLabel => 'WhatsApp';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get facebookLabel => 'Facebook';

  @override
  String get locationLabel => 'Location';

  @override
  String get sectionComingSoon => 'Coming soon';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get deliverTo => 'Deliver to';

  @override
  String get selectLocation => 'Select your location';

  @override
  String get searchFoodHint => 'What are you craving today?';

  @override
  String get homeCategoriesTitle => 'Discover the menu';

  @override
  String get homeCategoriesViewAll => 'View all';

  @override
  String get homeCategoriesHint => 'Swipe the categories or tap one to open it';

  @override
  String get homeCategoriesError => 'Couldn\'t load the menu categories.';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuSearchHint => 'Search for your favorite dish';

  @override
  String get clearSearch => 'Clear search';

  @override
  String menuItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get menuBrowseAllCategories => 'Browse all categories';

  @override
  String get menuChooseDishHint => 'Pick your dish and add it to your cart';

  @override
  String get menuAllCategoriesTitle => 'All categories';

  @override
  String get menuItemsError => 'Couldn\'t load the dishes.';

  @override
  String get menuEmptyCategory => 'No dishes in this category yet.';

  @override
  String get menuSearchNoResults => 'No dishes match your search.';

  @override
  String get backLabel => 'Back';

  @override
  String get viewCart => 'View cart';

  @override
  String get addToCartLabel => 'Add to cart';

  @override
  String get addedToCart => 'Added to the cart';

  @override
  String get itemDetailsError => 'Couldn\'t load the dish details.';

  @override
  String get itemDetailsFreshlyPrepared => 'Freshly prepared to order';

  @override
  String get itemDetailsQuantity => 'Quantity';

  @override
  String get itemDetailsSpecialInstructions => 'Special instructions';

  @override
  String get itemDetailsSpecialInstructionsHint =>
      'e.g. no onions, cooking level...';

  @override
  String get itemDetailsIncreaseQuantity => 'Increase quantity';

  @override
  String get itemDetailsDecreaseQuantity => 'Decrease quantity';

  @override
  String itemDetailsAddToCartPrice(String price) {
    return 'Add to cart - $price';
  }

  @override
  String get arabic => 'عربي';

  @override
  String get english => 'EN';
}
