import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';

enum AddressDetailsStatus { initial, loading, success, failure }

/// One saved address loaded through `GET /addresses/{id}`.
class AddressDetailsState {
  const AddressDetailsState({
    this.status = AddressDetailsStatus.initial,
    this.address,
    this.errorMessage,
  });

  final AddressDetailsStatus status;
  final Address? address;

  /// Message returned by the API; empty means "show the localized fallback".
  final String? errorMessage;

  bool get isLoading => status == AddressDetailsStatus.loading;

  bool get hasError => status == AddressDetailsStatus.failure;

  AddressDetailsState copyWith({
    AddressDetailsStatus? status,
    Address? address,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddressDetailsState(
      status: status ?? this.status,
      address: address ?? this.address,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
