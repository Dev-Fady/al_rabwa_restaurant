import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'address_list_state.dart';

/// Loads the customer's saved addresses for the delivery location picker.
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
        ),
      ),
    );
  }
}
