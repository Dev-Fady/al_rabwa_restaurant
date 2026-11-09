import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';

enum AddressListStatus { initial, loading, success, failure }

/// Saved delivery addresses shown in the location picker.
class AddressListState {
  const AddressListState({
    this.status = AddressListStatus.initial,
    this.addresses = const [],
    this.errorMessage,
  });

  final AddressListStatus status;

  /// Kept on failure so a refresh never blanks an already visible list.
  final List<Address> addresses;

  /// Message returned by the API; empty means "show the localized fallback".
  final String? errorMessage;

  bool get isLoading => status == AddressListStatus.loading;

  bool get hasAddresses => addresses.isNotEmpty;

  bool get hasError => status == AddressListStatus.failure;

  AddressListState copyWith({
    AddressListStatus? status,
    List<Address>? addresses,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddressListState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
