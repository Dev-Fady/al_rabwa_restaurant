import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';

enum HomeDeliveryAddressStatus { initial, loading, success, failure }

/// Saved addresses plus the one the home delivery bar currently shows.
class HomeDeliveryAddressState {
  const HomeDeliveryAddressState({
    this.status = HomeDeliveryAddressStatus.initial,
    this.addresses = const [],
    this.selectedAddress,
    this.errorMessage,
  });

  final HomeDeliveryAddressStatus status;

  /// Kept on failure so a refresh never blanks an already visible bar.
  final List<Address> addresses;

  /// Address shown in the delivery bar; the default address when one exists.
  final Address? selectedAddress;

  /// Message returned by the API; empty means "ignore the failure".
  final String? errorMessage;

  bool get isLoading => status == HomeDeliveryAddressStatus.loading;

  bool get hasAddresses => addresses.isNotEmpty;

  bool get hasError => status == HomeDeliveryAddressStatus.failure;

  HomeDeliveryAddressState copyWith({
    HomeDeliveryAddressStatus? status,
    List<Address>? addresses,
    Address? selectedAddress,
    bool clearSelectedAddress = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeDeliveryAddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      selectedAddress: clearSelectedAddress
          ? null
          : (selectedAddress ?? this.selectedAddress),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
