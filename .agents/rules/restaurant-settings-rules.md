---
trigger: always_on
---

# Restaurant Settings & Dynamic Storefront Rules

The endpoint `{{base_url}}/settings?lang={{lang}}` (`ApiConstants.baseUrl + ApiConstants.settings?lang=...`) is the central source of truth for the restaurant storefront. It dynamically manages branding, theming, currency, operational hours, order options, payment gateways, banners, and store contact info.

## 1. Single Source of Truth
- **Never hardcode storefront configuration**: Never hardcode store name, logo, contact info, brand colors, currency symbols, order types, delivery fees, or operating status in UI widgets or constants.
- **Dynamic content priority**: All storefront details must be derived from `RestaurantSettings` supplied by `StoreConfigCubit` (`StoreConfigState.settings`).

## 2. Dynamic Theming & Branding
- **Colors and Theme**: Brand colors (`primary_color`, `accent_color`, `background_color`, `text_color`, `title_color`) and font families are managed via `BrandTheme` in settings.
- **Theme integration**: Styles and colors must adapt via `AppTheme.fromTheme(...)` and `Theme.of(context)`. Never introduce fixed conflicting brand hex values in feature code.
- **Logos & Assets**: Brand logos and backgrounds are provided via URLs in `RestaurantBrand` and `BrandTheme`. Always provide graceful fallback UI if an image URL is empty or fails to load.

## 3. Currency & Price Formatting
- **Standardized formatting**: Always format monetary amounts using `RestaurantSettings.currency.format(amount)` (or the active `StoreCurrency`).
- **No hardcoded currencies**: NEVER hardcode `'QAR'`, `'ر.ق'`, `'$'`, or fixed decimal logic (`toStringAsFixed(2)`). Respect `currency.code`, `currency.symbol`, and `currency.decimals` (e.g. 3 decimals for QAR).

## 4. Store Availability & Operating Hours
- **Open/Closed State**: Check `settings.isOpenNow` (`ordering.enabled && ordering.acceptingOrdersNow`) before permitting order creation or checkout flows.
- **Closed State UI**: When the restaurant is closed, display `ordering.closedMessage` (or localized default) and disable checkout actions while keeping browsing enabled.
- **Working Hours & Zones**: Respect `ordering.workingHours` and `ordering.deliveryZones` when validating customer delivery requests.

## 5. Order Types & Payment Configuration
- **Order Types**: Dynamically populate delivery/fulfillment options only from `ordering.orderTypes` (e.g., `delivery`, `takeaway`, `dine_in`).
- **Payment Methods**: Only offer payment methods active in `ordering.paymentMethods` (e.g., `cash`, card) and check `onlinePaymentEnabled` / `onlinePaymentGateway` before showing digital payment options.
- **Location Requirements**: Respect `ordering.requireCustomerLocation` before requiring map pin or address coordinates.
- **Extra Fees & Taxes**: Calculate totals using `ordering.taxPercent`, `ordering.servicePercent`, and `ordering.deliveryFee`. Never hardcode fee percentages.
- **Reservations**: Check `reservationsEnabled` before presenting table reservation features.

## 6. Home Content & Promotional Banners
- **Hero & Welcome**: Respect `home.showWelcomeMessage`, `home.heroTitle`, and `home.heroSubtitle`.
- **Dynamic Banners**: Render promotional banners from `home.banners` when `home.showBanner` is true.
- **Banner Navigation**: Handle `linkType` properly (`category`, `item`, `url`, `external`) using entity helpers `opensMenu` and `opensExternalUrl`.

## 7. Localization & Multi-language Support
- **Query Parameter**: Whenever changing or loading language, query `{{base_url}}/settings?lang={{lang}}` (passing the current locale, e.g., `'ar'` or `'en'`).
- **Directionality**: Respect `StoreLocalization.direction` (`rtl` vs `ltr`) and `timezone`. UI must support both Arabic (RTL) and English (LTR) seamlessly.

## 8. Architecture & State Management
- **Layer Separation**:
  - `data`: `RestaurantSettingsResponse` and DTOs parse API JSON. All fields MUST have safe fallback defaults (`toEntity()`) so partial/malformed backend responses never crash the app.
  - `domain`: `RestaurantSettings` and sub-models (`RestaurantBrand`, `BrandTheme`, etc.) must remain pure Dart—zero Flutter or UI framework imports.
  - `presentation`: `StoreConfigCubit` manages `StoreConfigState`. Access it via `context.read<StoreConfigCubit>()` or `BlocBuilder<StoreConfigCubit, StoreConfigState>`. Never call `SettingsRepository` directly from widgets.
- **Non-blocking Refresh**: Pull-to-refresh (`StoreConfigCubit.refresh()`) must retain current settings in state while reloading to prevent flashing loading skeletons over existing content.
- **Offline & Cache Resilience**: Always ensure cached settings from `CacheHelper` or fallback defaults are served when network requests fail.

## 9. Testing & Fixtures
- **Use Standard Fixtures**: Use `settingsPayload()` and `sampleSettings()` from `test/helpers/settings_fixtures.dart` in unit and widget tests.
- **Cover Edge Cases**: Test open vs. closed store behavior, zero/missing fees, fallback branding, and banner-less configurations (`sampleSettingsWithoutImages()`).

