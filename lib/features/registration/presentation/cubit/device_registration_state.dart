import 'package:al_rabwa_restaurant/features/registration/domain/entities/device_session.dart';

enum DeviceRegistrationStatus { initial, submitting, success, failure }

class DeviceRegistrationState {
  const DeviceRegistrationState({
    this.status = DeviceRegistrationStatus.initial,
    this.session,
    this.errorMessage,
  });

  final DeviceRegistrationStatus status;
  final DeviceSession? session;
  final String? errorMessage;

  bool get isSubmitting => status == DeviceRegistrationStatus.submitting;

  bool get isSuccess => status == DeviceRegistrationStatus.success;

  DeviceRegistrationState copyWith({
    DeviceRegistrationStatus? status,
    DeviceSession? session,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeviceRegistrationState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
