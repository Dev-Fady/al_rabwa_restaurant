import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Al Rabwa Restaurant'**
  String get appTitle;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Fresh flavors, warm hospitality'**
  String get splashTagline;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your table…'**
  String get splashLoading;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get navStore;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Al Rabwa Restaurant'**
  String get homeWelcomeTitle;

  /// No description provided for @homeWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your favorite dishes from the menu and enjoy a special dining experience.'**
  String get homeWelcomeSubtitle;

  /// No description provided for @storeOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now — taking orders'**
  String get storeOpenNow;

  /// No description provided for @storeOpenShort.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get storeOpenShort;

  /// No description provided for @storeClosed.
  ///
  /// In en, this message translates to:
  /// **'Currently closed'**
  String get storeClosed;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order status'**
  String get orderStatus;

  /// No description provided for @storeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurant info'**
  String get storeInfoTitle;

  /// No description provided for @orderOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order options'**
  String get orderOptionsTitle;

  /// No description provided for @browseMenu.
  ///
  /// In en, this message translates to:
  /// **'Browse the menu'**
  String get browseMenu;

  /// No description provided for @orderNow.
  ///
  /// In en, this message translates to:
  /// **'Order now'**
  String get orderNow;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @storeSettingsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the restaurant. Check your connection and try again.'**
  String get storeSettingsError;

  /// No description provided for @loadingStore.
  ///
  /// In en, this message translates to:
  /// **'Loading the restaurant...'**
  String get loadingStore;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @paymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentLabel;

  /// No description provided for @deliveryFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFeeLabel;

  /// No description provided for @taxLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get taxLabel;

  /// No description provided for @serviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service charge'**
  String get serviceLabel;

  /// No description provided for @deliveryZonesLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery zones'**
  String get deliveryZonesLabel;

  /// No description provided for @reservationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get reservationsLabel;

  /// No description provided for @availableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableLabel;

  /// No description provided for @workingHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get workingHoursLabel;

  /// No description provided for @locationRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationRequiredLabel;

  /// No description provided for @requiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredLabel;

  /// No description provided for @onlinePaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Online payment'**
  String get onlinePaymentLabel;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactTitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @whatsappLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsappLabel;

  /// No description provided for @instagramLabel.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagramLabel;

  /// No description provided for @facebookLabel.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebookLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @sectionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get sectionComingSoon;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliverTo;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select your location'**
  String get selectLocation;

  /// No description provided for @searchFoodHint.
  ///
  /// In en, this message translates to:
  /// **'What are you craving today?'**
  String get searchFoodHint;

  /// No description provided for @homeCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover the menu'**
  String get homeCategoriesTitle;

  /// No description provided for @homeCategoriesViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeCategoriesViewAll;

  /// No description provided for @homeCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe the categories or tap one to open it'**
  String get homeCategoriesHint;

  /// No description provided for @homeCategoriesError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the menu categories.'**
  String get homeCategoriesError;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @menuCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu sections'**
  String get menuCategoriesTitle;

  /// No description provided for @menuCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what you crave'**
  String get menuCategoriesSubtitle;

  /// No description provided for @menuCategoriesBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get menuCategoriesBackHome;

  /// No description provided for @menuCategoriesHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'All flavors in one place'**
  String get menuCategoriesHeroTitle;

  /// No description provided for @menuCategoriesHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse the {restaurant} menu ({count})'**
  String menuCategoriesHeroSubtitle(String restaurant, int count);

  /// No description provided for @menuCategoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sections to show yet.'**
  String get menuCategoriesEmpty;

  /// No description provided for @menuSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for your favorite dish'**
  String get menuSearchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @menuItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} one{1 item} other{{count} items}}'**
  String menuItemsCount(int count);

  /// No description provided for @menuBrowseAllCategories.
  ///
  /// In en, this message translates to:
  /// **'Browse all categories'**
  String get menuBrowseAllCategories;

  /// No description provided for @menuChooseDishHint.
  ///
  /// In en, this message translates to:
  /// **'Pick your dish and add it to your cart'**
  String get menuChooseDishHint;

  /// No description provided for @menuAllCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get menuAllCategoriesTitle;

  /// No description provided for @menuItemsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the dishes.'**
  String get menuItemsError;

  /// No description provided for @menuEmptyCategory.
  ///
  /// In en, this message translates to:
  /// **'No dishes in this category yet.'**
  String get menuEmptyCategory;

  /// No description provided for @menuSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No dishes match your search.'**
  String get menuSearchNoResults;

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @addToCartLabel.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCartLabel;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to the cart'**
  String get addedToCart;

  /// No description provided for @itemDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the dish details.'**
  String get itemDetailsError;

  /// No description provided for @itemDetailsFreshlyPrepared.
  ///
  /// In en, this message translates to:
  /// **'Freshly prepared to order'**
  String get itemDetailsFreshlyPrepared;

  /// No description provided for @itemDetailsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get itemDetailsQuantity;

  /// No description provided for @itemDetailsSpecialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special instructions'**
  String get itemDetailsSpecialInstructions;

  /// No description provided for @itemDetailsSpecialInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. no onions, cooking level...'**
  String get itemDetailsSpecialInstructionsHint;

  /// No description provided for @itemDetailsIncreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get itemDetailsIncreaseQuantity;

  /// No description provided for @itemDetailsDecreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get itemDetailsDecreaseQuantity;

  /// No description provided for @itemDetailsAddToCartPrice.
  ///
  /// In en, this message translates to:
  /// **'Add to cart - {price}'**
  String itemDetailsAddToCartPrice(String price);

  /// No description provided for @itemDetailsChooseOne.
  ///
  /// In en, this message translates to:
  /// **'Choose one'**
  String get itemDetailsChooseOne;

  /// No description provided for @itemDetailsAddons.
  ///
  /// In en, this message translates to:
  /// **'Optional add-ons'**
  String get itemDetailsAddons;

  /// No description provided for @itemDetailsWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get itemDetailsWeight;

  /// No description provided for @itemDetailsWeightHint.
  ///
  /// In en, this message translates to:
  /// **'From {min} to {max} kg'**
  String itemDetailsWeightHint(String min, String max);

  /// No description provided for @itemDetailsWeightValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String itemDetailsWeightValue(String value);

  /// No description provided for @itemDetailsPerKg.
  ///
  /// In en, this message translates to:
  /// **'/kg'**
  String get itemDetailsPerKg;

  /// No description provided for @itemDetailsVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get itemDetailsVideo;

  /// No description provided for @itemDetailsPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get itemDetailsPhoto;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'عربي'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get english;

  /// No description provided for @registerWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Al Rabwa'**
  String get registerWelcomeTitle;

  /// No description provided for @registerWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us a little about you and start ordering in seconds.'**
  String get registerWelcomeSubtitle;

  /// No description provided for @registerHeroBadge.
  ///
  /// In en, this message translates to:
  /// **'Al Rabwa Restaurant'**
  String get registerHeroBadge;

  /// No description provided for @registerFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your profile'**
  String get registerFormTitle;

  /// No description provided for @registerFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use your details to personalize your orders.'**
  String get registerFormSubtitle;

  /// No description provided for @registerNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ahmed Mohamed'**
  String get registerNameHint;

  /// No description provided for @registerPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+974 555 1234'**
  String get registerPhoneHint;

  /// No description provided for @registerLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred language'**
  String get registerLanguageLabel;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Start ordering'**
  String get registerSubmit;

  /// No description provided for @registerError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get registerError;

  /// No description provided for @registerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get registerNameRequired;

  /// No description provided for @registerNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Your name is too short.'**
  String get registerNameTooShort;

  /// No description provided for @registerPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number.'**
  String get registerPhoneRequired;

  /// No description provided for @registerPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number.'**
  String get registerPhoneInvalid;

  /// No description provided for @registerPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your session is stored securely on this device. By continuing, you agree to our terms and privacy policy.'**
  String get registerPrivacyNote;

  /// No description provided for @registerFeatureFresh.
  ///
  /// In en, this message translates to:
  /// **'Freshly prepared'**
  String get registerFeatureFresh;

  /// No description provided for @registerFeatureFast.
  ///
  /// In en, this message translates to:
  /// **'Fast delivery'**
  String get registerFeatureFast;

  /// No description provided for @registerFeatureSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure & private'**
  String get registerFeatureSecure;

  /// No description provided for @addressAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a new address'**
  String get addressAddTitle;

  /// No description provided for @addressUseCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get addressUseCurrentLocation;

  /// No description provided for @addressMapHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map to confirm your exact spot'**
  String get addressMapHint;

  /// No description provided for @addressKindHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get addressKindHome;

  /// No description provided for @addressKindWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get addressKindWork;

  /// No description provided for @addressKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get addressKindOther;

  /// No description provided for @addressLabelField.
  ///
  /// In en, this message translates to:
  /// **'Address name (optional)'**
  String get addressLabelField;

  /// No description provided for @addressLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Family home'**
  String get addressLabelHint;

  /// No description provided for @addressAreaField.
  ///
  /// In en, this message translates to:
  /// **'Area / district'**
  String get addressAreaField;

  /// No description provided for @addressAreaHint.
  ///
  /// In en, this message translates to:
  /// **'Al Sadd, Doha'**
  String get addressAreaHint;

  /// No description provided for @addressStreetField.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get addressStreetField;

  /// No description provided for @addressStreetHint.
  ///
  /// In en, this message translates to:
  /// **'Street 901'**
  String get addressStreetHint;

  /// No description provided for @addressBuildingField.
  ///
  /// In en, this message translates to:
  /// **'Building / floor / flat'**
  String get addressBuildingField;

  /// No description provided for @addressBuildingHint.
  ///
  /// In en, this message translates to:
  /// **'Building 35, floor 2'**
  String get addressBuildingHint;

  /// No description provided for @addressNotesField.
  ///
  /// In en, this message translates to:
  /// **'Driver instructions'**
  String get addressNotesField;

  /// No description provided for @addressNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. The green door'**
  String get addressNotesHint;

  /// No description provided for @addressSave.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get addressSave;

  /// No description provided for @addressAreaRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the area or district.'**
  String get addressAreaRequired;

  /// No description provided for @addressStreetRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the street.'**
  String get addressStreetRequired;

  /// No description provided for @addressBuildingRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the building number.'**
  String get addressBuildingRequired;

  /// No description provided for @addressOutsideQatar.
  ///
  /// In en, this message translates to:
  /// **'That spot is outside Qatar. Move the map to pick a location inside the country.'**
  String get addressOutsideQatar;

  /// No description provided for @addressSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the address. Please try again.'**
  String get addressSaveError;

  /// No description provided for @addressNotDeliverable.
  ///
  /// In en, this message translates to:
  /// **'Address saved, but it is outside the current delivery area.'**
  String get addressNotDeliverable;

  /// No description provided for @addressLocationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are off. Turn them on in your device settings and try again.'**
  String get addressLocationServiceDisabled;

  /// No description provided for @addressLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow location access to use your current location.'**
  String get addressLocationPermissionDenied;

  /// No description provided for @addressLocationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked. You can enable it in the app settings.'**
  String get addressLocationPermissionDeniedForever;

  /// No description provided for @addressLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your current location. Move the map manually.'**
  String get addressLocationUnavailable;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
