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
  String get splashTagline => 'Fresh flavors, warm hospitality';

  @override
  String get splashLoading => 'Preparing your table…';

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
  String get menuCategoriesTitle => 'Menu sections';

  @override
  String get menuCategoriesSubtitle => 'Choose what you crave';

  @override
  String get menuCategoriesBackHome => 'Back to home';

  @override
  String get menuCategoriesHeroTitle => 'All flavors in one place';

  @override
  String menuCategoriesHeroSubtitle(String restaurant, int count) {
    return 'Browse the $restaurant menu ($count)';
  }

  @override
  String get menuCategoriesEmpty => 'No sections to show yet.';

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
  String get itemDetailsChooseOne => 'Choose one';

  @override
  String get itemDetailsAddons => 'Optional add-ons';

  @override
  String get itemDetailsWeight => 'Weight';

  @override
  String itemDetailsWeightHint(String min, String max) {
    return 'From $min to $max kg';
  }

  @override
  String itemDetailsWeightValue(String value) {
    return '$value kg';
  }

  @override
  String get itemDetailsPerKg => '/kg';

  @override
  String get itemDetailsVideo => 'Video';

  @override
  String get itemDetailsPhoto => 'Photo';

  @override
  String get arabic => 'عربي';

  @override
  String get english => 'EN';

  @override
  String get registerWelcomeTitle => 'Welcome to Al Rabwa';

  @override
  String get registerWelcomeSubtitle =>
      'Tell us a little about you and start ordering in seconds.';

  @override
  String get registerHeroBadge => 'Al Rabwa Restaurant';

  @override
  String get registerFormTitle => 'Create your profile';

  @override
  String get registerFormSubtitle =>
      'We\'ll use your details to personalize your orders.';

  @override
  String get registerNameHint => 'e.g. Ahmed Mohamed';

  @override
  String get registerPhoneHint => '+974 555 1234';

  @override
  String get registerLanguageLabel => 'Preferred language';

  @override
  String get registerSubmit => 'Start ordering';

  @override
  String get registerError => 'Something went wrong. Please try again.';

  @override
  String get registerNameRequired => 'Please enter your name.';

  @override
  String get registerNameTooShort => 'Your name is too short.';

  @override
  String get registerPhoneRequired => 'Please enter your phone number.';

  @override
  String get registerPhoneInvalid => 'Please enter a valid phone number.';

  @override
  String get registerPrivacyNote =>
      'Your session is stored securely on this device. By continuing, you agree to our terms and privacy policy.';

  @override
  String get registerFeatureFresh => 'Freshly prepared';

  @override
  String get registerFeatureFast => 'Fast delivery';

  @override
  String get registerFeatureSecure => 'Secure & private';

  @override
  String get addressAddTitle => 'Add a new address';

  @override
  String get addressEditTitle => 'Edit address';

  @override
  String get addressSaveChanges => 'Save changes';

  @override
  String get addressDetailsTitle => 'Address details';

  @override
  String get addressDetailsInfo => 'Address information';

  @override
  String get addressDetailsError =>
      'Couldn\'t load the address details. Please try again.';

  @override
  String get addressOptions => 'Address options';

  @override
  String get addressViewDetails => 'View details';

  @override
  String get addressCoordinates => 'Coordinates';

  @override
  String get addressSelectTitle => 'Select delivery address';

  @override
  String get addressSelectSubtitle =>
      'Choose a saved address or add a new one.';

  @override
  String get addressSavedTitle => 'Saved addresses';

  @override
  String get addressListEmpty => 'You haven\'t saved any addresses yet.';

  @override
  String get addressListError =>
      'Couldn\'t load your saved addresses. Please try again.';

  @override
  String get addressOutsideArea => 'Outside the delivery area';

  @override
  String get addressUseCurrentLocation => 'Use my current location';

  @override
  String get addressMapHint => 'Move the map to confirm your exact spot';

  @override
  String get addressKindHome => 'Home';

  @override
  String get addressKindWork => 'Work';

  @override
  String get addressKindOther => 'Other';

  @override
  String get addressLabelField => 'Address name (optional)';

  @override
  String get addressLabelHint => 'e.g. Family home';

  @override
  String get addressAreaField => 'Area / district';

  @override
  String get addressAreaHint => 'Al Sadd, Doha';

  @override
  String get addressStreetField => 'Street';

  @override
  String get addressStreetHint => 'Street 901';

  @override
  String get addressBuildingField => 'Building / floor / flat';

  @override
  String get addressBuildingHint => 'Building 35, floor 2';

  @override
  String get addressNotesField => 'Driver instructions';

  @override
  String get addressNotesHint => 'e.g. The green door';

  @override
  String get addressSave => 'Save address';

  @override
  String get addressAreaRequired => 'Please enter the area or district.';

  @override
  String get addressStreetRequired => 'Please enter the street.';

  @override
  String get addressBuildingRequired => 'Please enter the building number.';

  @override
  String get addressOutsideQatar =>
      'That spot is outside Qatar. Move the map to pick a location inside the country.';

  @override
  String get addressSaveError =>
      'Couldn\'t save the address. Please try again.';

  @override
  String get addressNotDeliverable =>
      'Address saved, but it is outside the current delivery area.';

  @override
  String get addressLocationServiceDisabled =>
      'Location services are off. Turn them on in your device settings and try again.';

  @override
  String get addressLocationPermissionDenied =>
      'Allow location access to use your current location.';

  @override
  String get addressLocationPermissionDeniedForever =>
      'Location permission is blocked. You can enable it in the app settings.';

  @override
  String get addressLocationUnavailable =>
      'Couldn\'t get your current location. Move the map manually.';
}
