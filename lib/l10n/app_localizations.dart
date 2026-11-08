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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Al Rabwa Restaurant'**
  String get appTitle;

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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
