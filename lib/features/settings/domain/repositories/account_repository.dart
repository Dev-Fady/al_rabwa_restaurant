import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:dartz/dartz.dart';

/// Device-account actions that are not tied to the storefront catalog.
abstract class AccountRepository {
  /// Permanently deletes this device's data through `DELETE /api/me`.
  ///
  /// The backend also drops the issued token, so a successful call clears the
  /// local session before it completes.
  Future<Either<Failure, Unit>> deleteMyData();
}
