import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';

enum AddressDetailsStatus { initial, loading, success, failure }

/// One saved address loaded through `GET /addresses/{id}`.
class AddressDetailsState {
  const AddressDetailsState({
    this.status = AddressDetailsStatus.initial,
    this.address,
    this.errorMessage,
    this.isDeleting = false,
    this.deleteError,
    this.isDeleted = false,
  });

  final AddressDetailsStatus status;
  final Address? address;

  /// Message returned by the API; empty means "show the localized fallback".
  final String? errorMessage;

  /// Whether a delete request is currently running.
  final bool isDeleting;

  /// Message returned when the address could not be deleted.
  final String? deleteError;

  /// Whether the address was deleted and the screen should close.
  final bool isDeleted;

  bool get isLoading => status == AddressDetailsStatus.loading;

  bool get hasError => status == AddressDetailsStatus.failure;

  AddressDetailsState copyWith({
    AddressDetailsStatus? status,
    Address? address,
    String? errorMessage,
    bool clearError = false,
    bool? isDeleting,
    String? deleteError,
    bool clearDeleteError = false,
    bool? isDeleted,
  }) {
    return AddressDetailsState(
      status: status ?? this.status,
      address: address ?? this.address,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isDeleting: isDeleting ?? this.isDeleting,
      deleteError: clearDeleteError ? null : (deleteError ?? this.deleteError),
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
