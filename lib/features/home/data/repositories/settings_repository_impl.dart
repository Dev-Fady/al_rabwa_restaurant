import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/home/data/datasources/settings_local_data_source.dart';
import 'package:al_rabwa_restaurant/features/home/data/datasources/settings_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/home/data/models/restaurant_settings_response.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

/// Fetches the storefront settings and keeps the last successful payload in
/// local storage, so a cold start without network still renders the menu's
/// branding instead of an error screen.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final SettingsRemoteDataSource remoteDataSource;
  final SettingsLocalDataSource localDataSource;

  @override
  Future<Either<Failure, RestaurantSettings>> fetchSettings({
    String lang = 'ar',
  }) async {
    try {
      final response = await remoteDataSource.getSettings(lang: lang);
      final settings = response.response.toEntity();

      if (settings == null) {
        throw const FormatException('Empty settings payload');
      }

      await _cacheSettings(lang, response.raw);
      return Right(settings);
    } on Failure catch (failure) {
      return _readCacheOr(failure, lang);
    } on DioException catch (error) {
      return _readCacheOr(ServerFailure.fromDioException(error), lang);
    } catch (error) {
      return _readCacheOr(ServerFailure.fromError(error), lang);
    }
  }

  Either<Failure, RestaurantSettings> _readCacheOr(
    Failure failure,
    String lang,
  ) {
    final cached = _readFromCache(lang);
    if (cached != null) return Right(cached);
    return Left(failure);
  }

  Future<void> _cacheSettings(String lang, Map<String, dynamic> raw) async {
    try {
      await localDataSource.save(lang: lang, payload: raw);
    } catch (_) {
      // Caching is best-effort; the fresh response is already in hand.
    }
  }

  RestaurantSettings? _readFromCache(String lang) {
    try {
      final raw = localDataSource.read(lang: lang);
      if (raw == null) return null;
      return RestaurantSettingsResponse.fromJson(raw).toEntity();
    } catch (_) {
      return null;
    }
  }
}
