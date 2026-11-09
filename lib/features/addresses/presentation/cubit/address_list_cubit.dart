import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'address_list_state.dart';

/// Loads the customer's saved addresses for the delivery location picker and
/// lets one of them become the default.
class AddressListCubit extends Cubit<AddressListState> {
  AddressListCubit(this._repository, {this.lang = 'ar'})
    : super(const AddressListState());

  final AddressesRepository _repository;

  /// BCP-47 language sent to the API so titles/labels match the UI.
  final String lang;

  Future<void> load() async {
    if (state.isLoading) return;

    emit(state.copyWith(status: AddressListStatus.loading, clearError: true));

    final result = await _repository.fetchAddresses(lang: lang);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AddressListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (addresses) => emit(
        AddressListState(
          status: AddressListStatus.success,
          addresses: List.unmodifiable(addresses),
          defaultAddressId: _resolveDefaultId(addresses),
        ),
      ),
    );
  }

  /// Marks [id] as the default address on the backend.
  Future<void> setDefault(int id) async {
    if (state.settingDefaultId != null || state.isDefault(id)) return;

    emit(state.copyWith(settingDefaultId: id, clearDefaultError: true));

    final result = await _repository.setDefaultAddress(id: id, lang: lang);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          clearSettingDefault: true,
          defaultError: failure.message,
        ),
      ),
      (address) => emit(
        state.copyWith(
          addresses: List.unmodifiable(
            state.addresses.map((item) => item.id == id ? address : item),
          ),
          defaultAddressId: id,
          clearSettingDefault: true,
          clearDefaultError: true,
        ),
      ),
    );
  }

  /// Prefers the flag the API returned; otherwise keeps the previous default
  /// when it still exists, so a refresh does not forget the latest change.
  int? _resolveDefaultId(List<Address> addresses) {
    for (final address in addresses) {
      if (address.isDefault && address.id != null) return address.id;
    }

    final previous = state.defaultAddressId;
    if (previous != null &&
        addresses.any((address) => address.id == previous)) {
      return previous;
    }

    return null;
  }
}
