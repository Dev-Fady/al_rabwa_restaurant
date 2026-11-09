import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';

enum AddressListStatus { initial, loading, success, failure }

/// Saved delivery addresses shown in the location picker.
class AddressListState {
  const AddressListState({
    this.status = AddressListStatus.initial,
    this.addresses = const [],
    this.errorMessage,
    this.defaultAddressId,
    this.settingDefaultId,
    this.defaultError,
  });

  final AddressListStatus status;

  /// Kept on failure so a refresh never blanks an already visible list.
  final List<Address> addresses;

  /// Message returned by the API; empty means "show the localized fallback".
  final String? errorMessage;

  /// Address the backend currently treats as the customer's default.
  final int? defaultAddressId;

  /// Address whose "set as default" request is in flight.
  final int? settingDefaultId;

  /// Message returned when the default could not be changed.
  final String? defaultError;

  bool get isLoading => status == AddressListStatus.loading;

  bool get hasAddresses => addresses.isNotEmpty;

  bool get hasError => status == AddressListStatus.failure;

  bool isDefault(int? id) => id != null && id == defaultAddressId;

  bool isSettingDefault(int? id) => id != null && id == settingDefaultId;

  AddressListState copyWith({
    AddressListStatus? status,
    List<Address>? addresses,
    String? errorMessage,
    bool clearError = false,
    int? defaultAddressId,
    bool clearDefaultAddress = false,
    int? settingDefaultId,
    bool clearSettingDefault = false,
    String? defaultError,
    bool clearDefaultError = false,
  }) {
    return AddressListState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      defaultAddressId: clearDefaultAddress
          ? null
          : (defaultAddressId ?? this.defaultAddressId),
      settingDefaultId: clearSettingDefault
          ? null
          : (settingDefaultId ?? this.settingDefaultId),
      defaultError: clearDefaultError
          ? null
          : (defaultError ?? this.defaultError),
    );
  }
}
