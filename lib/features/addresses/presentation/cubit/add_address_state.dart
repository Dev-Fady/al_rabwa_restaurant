import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/errors/location_failure.dart';

enum AddAddressStatus { initial, locating, submitting, success, failure }

class AddAddressState {
  const AddAddressState({
    this.status = AddAddressStatus.initial,
    this.kind = AddressKind.home,
    this.focusPoint,
    this.focusRequest = 0,
    this.locationIssue,
    this.outsideQatar = false,
    this.errorMessage,
    this.createdAddress,
  });

  final AddAddressStatus status;
  final AddressKind kind;

  /// Where the map should jump to (device location). Only applied when
  /// [focusRequest] changes, so rebuilding the screen never moves the camera
  /// away from where the customer panned to.
  final GeoPoint? focusPoint;
  final int focusRequest;

  /// Set when "use my location" fails; the map pin is unaffected.
  final LocationIssue? locationIssue;

  /// The chosen coordinate is outside Qatar, so it was not submitted.
  final bool outsideQatar;

  /// Message returned by the API; empty means "show the localized fallback".
  final String? errorMessage;

  final Address? createdAddress;

  bool get isLocating => status == AddAddressStatus.locating;

  bool get isSubmitting => status == AddAddressStatus.submitting;

  bool get isSuccess => status == AddAddressStatus.success;

  AddAddressState copyWith({
    AddAddressStatus? status,
    AddressKind? kind,
    GeoPoint? focusPoint,
    int? focusRequest,
    LocationIssue? locationIssue,
    bool? outsideQatar,
    String? errorMessage,
    Address? createdAddress,
    bool clearMessages = false,
  }) {
    return AddAddressState(
      status: status ?? this.status,
      kind: kind ?? this.kind,
      focusPoint: focusPoint ?? this.focusPoint,
      focusRequest: focusRequest ?? this.focusRequest,
      locationIssue: clearMessages
          ? null
          : (locationIssue ?? this.locationIssue),
      outsideQatar: outsideQatar ?? this.outsideQatar,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      createdAddress: createdAddress ?? this.createdAddress,
    );
  }
}
