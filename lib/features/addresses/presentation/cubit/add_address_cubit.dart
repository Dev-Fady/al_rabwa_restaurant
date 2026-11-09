import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/errors/location_failure.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/device_location_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_address_state.dart';

/// Owns the add-address form state: the selected kind, the optional device
/// location lookup, and the `POST /addresses` submission.
///
/// The map camera itself stays in the widget layer; the screen hands the
/// chosen [GeoPoint] to [save], where the Qatar delivery rule is enforced.
class AddAddressCubit extends Cubit<AddAddressState> {
  AddAddressCubit(
    this._repository,
    this._locationRepository, {
    this.lang = 'ar',
  }) : super(const AddAddressState());

  final AddressesRepository _repository;
  final DeviceLocationRepository _locationRepository;

  /// BCP-47 language sent to the API so `kind_label`/`title` match the UI.
  final String lang;

  void selectKind(AddressKind kind) {
    if (kind == state.kind || state.isSubmitting) return;
    emit(state.copyWith(kind: kind));
  }

  /// Moves the pin to the device's current position.
  Future<void> useCurrentLocation() async {
    if (state.isLocating || state.isSubmitting) return;

    emit(
      state.copyWith(status: AddAddressStatus.locating, clearMessages: true),
    );

    final result = await _locationRepository.currentLocation();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AddAddressStatus.failure,
          locationIssue: failure is LocationFailure
              ? failure.issue
              : LocationIssue.unavailable,
        ),
      ),
      (point) => emit(
        state.copyWith(
          status: AddAddressStatus.initial,
          focusPoint: point,
          focusRequest: state.focusRequest + 1,
        ),
      ),
    );
  }

  /// Saves the address. Coordinates outside Qatar are rejected locally because
  /// the restaurant only delivers inside the country.
  Future<void> save({
    required GeoPoint point,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
  }) async {
    if (state.isSubmitting) return;

    if (!point.isWithinQatar) {
      emit(
        state.copyWith(
          status: AddAddressStatus.failure,
          outsideQatar: true,
          clearMessages: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AddAddressStatus.submitting,
        outsideQatar: false,
        clearMessages: true,
      ),
    );

    final result = await _repository.createAddress(
      kind: state.kind,
      label: label,
      area: area,
      street: street,
      building: building,
      notes: notes,
      point: point,
      lang: lang,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AddAddressStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (address) => emit(
        AddAddressState(
          status: AddAddressStatus.success,
          kind: state.kind,
          createdAddress: address,
        ),
      ),
    );
  }
}
