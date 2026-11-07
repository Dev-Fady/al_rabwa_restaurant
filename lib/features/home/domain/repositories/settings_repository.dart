import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:dartz/dartz.dart';

/// Reads the storefront configuration shown across the app.
abstract class SettingsRepository {
  /// Fetches `GET /api/settings?lang=...`.
  ///
  /// Returns cached settings when the request fails and a copy is available.
  Future<Either<Failure, RestaurantSettings>> fetchSettings({
    String lang = 'ar',
  });
}
