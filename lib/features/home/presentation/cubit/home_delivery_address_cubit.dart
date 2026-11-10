import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/utils/auth_helper.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'home_delivery_address_state.dart';

/// Loads the saved addresses behind the home delivery bar so a returning
/// customer sees their default address instead of "Select your location".
///
/// Addresses can only be fetched with a device token, so [loadIfAuthenticated]
/// skips the request on a fresh install. The caller reloads after registration.
class HomeDeliveryAddressCubit extends Cubit<HomeDeliveryAddressState> {
  HomeDeliveryAddressCubit(
    this._repository,
    this._secureStorage, {
    this.lang = 'ar',
  }) : super(const HomeDeliveryAddressState());

  final AddressesRepository _repository;
  final FlutterSecureStorage _secureStorage;

  /// BCP-47 language sent to the API so titles/labels match the UI.
  final String lang;

  /// Incremented for every request so a slow earlier response cannot overwrite
  /// the result of a newer one.
  int _loadToken = 0;

  /// Loads the addresses only when the device already has a bearer token.
  Future<void> loadIfAuthenticated() async {
    final hasToken = await AuthHelper.hasSavedToken(_secureStorage);
    if (isClosed || !hasToken) return;
    await load();
  }

  Future<void> load({bool preferDefault = false, bool force = false}) async {
    if (state.isLoading && !force) return;

    final token = ++_loadToken;
    emit(
      state.copyWith(
        status: HomeDeliveryAddressStatus.loading,
        clearError: true,
      ),
    );

    try {
      final result = await _repository.fetchAddresses(lang: lang);
      if (isClosed || token != _loadToken) return;

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: HomeDeliveryAddressStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (addresses) => emit(
          HomeDeliveryAddressState(
            status: HomeDeliveryAddressStatus.success,
            addresses: List.unmodifiable(addresses),
            selectedAddress: _resolveSelected(
              addresses,
              preferDefault: preferDefault,
            ),
          ),
        ),
      );
    } on Failure catch (failure) {
      if (isClosed || token != _loadToken) return;
      emit(
        state.copyWith(
          status: HomeDeliveryAddressStatus.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (error) {
      if (isClosed || token != _loadToken) return;
      emit(
        state.copyWith(
          status: HomeDeliveryAddressStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Shows [address] in the delivery bar without changing the saved default.
  void select(Address address) {
    emit(state.copyWith(selectedAddress: address, clearError: true));
  }

  /// Keeps the address the customer picked when it still exists; otherwise
  /// shows the saved default, then the first address.
  ///
  /// [preferDefault] ignores the previous pick so a default changed in the
  /// address picker is visible as soon as the customer returns home.
  Address? _resolveSelected(
    List<Address> addresses, {
    required bool preferDefault,
  }) {
    if (addresses.isEmpty) return null;

    if (!preferDefault) {
      final previousId = state.selectedAddress?.id;
      if (previousId != null) {
        for (final address in addresses) {
          if (address.id == previousId) return address;
        }
      }
    }

    for (final address in addresses) {
      if (address.isDefault) return address;
    }

    return addresses.first;
  }
}
