import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'address_details_state.dart';

/// Loads one saved address for the details screen and reflects edits made
/// through the add-address form without a second round trip.
class AddressDetailsCubit extends Cubit<AddressDetailsState> {
  AddressDetailsCubit(
    this._repository, {
    required this.addressId,
    this.lang = 'ar',
  }) : super(const AddressDetailsState());

  final AddressesRepository _repository;
  final int addressId;

  /// BCP-47 language sent to the API so labels match the UI.
  final String lang;

  Future<void> load() async {
    if (state.isLoading) return;

    emit(
      state.copyWith(status: AddressDetailsStatus.loading, clearError: true),
    );

    final result = await _repository.fetchAddress(id: addressId, lang: lang);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AddressDetailsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (address) => emit(
        AddressDetailsState(
          status: AddressDetailsStatus.success,
          address: address,
        ),
      ),
    );
  }

  /// Applies the address returned by the edit form immediately.
  void applyAddress(Address address) {
    emit(
      AddressDetailsState(
        status: AddressDetailsStatus.success,
        address: address,
      ),
    );
  }

  /// Deletes the loaded address; [AddressDetailsState.isDeleted] then tells the
  /// screen to close.
  Future<void> deleteAddress() async {
    if (state.isDeleting || state.isDeleted) return;

    emit(state.copyWith(isDeleting: true, clearDeleteError: true));

    final result = await _repository.deleteAddress(id: addressId, lang: lang);
    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(state.copyWith(isDeleting: false, deleteError: failure.message)),
      (_) => emit(state.copyWith(isDeleting: false, isDeleted: true)),
    );
  }
}
