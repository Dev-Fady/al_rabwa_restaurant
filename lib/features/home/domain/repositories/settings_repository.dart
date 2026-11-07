import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';

/// Reads the storefront configuration shown across the app.
abstract class SettingsRepository {
  /// Fetches `GET /api/settings?lang=...`.
  ///
  /// Throws a `Failure` when the request fails and no cached copy exists.
  Future<RestaurantSettings> fetchSettings({String lang = 'ar'});
}
