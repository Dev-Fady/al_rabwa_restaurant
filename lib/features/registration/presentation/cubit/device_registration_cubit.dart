import 'package:al_rabwa_restaurant/features/registration/domain/repositories/device_registration_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'device_registration_state.dart';

/// Creates the device session and keeps the form's submitting/error state.
class DeviceRegistrationCubit extends Cubit<DeviceRegistrationState> {
  DeviceRegistrationCubit(this._repository)
    : super(const DeviceRegistrationState());

  final DeviceRegistrationRepository _repository;

  Future<void> register({
    required String name,
    required String phone,
    required String locale,
  }) async {
    if (state.isSubmitting) return;

    emit(
      state.copyWith(
        status: DeviceRegistrationStatus.submitting,
        clearError: true,
      ),
    );

    final result = await _repository.registerDevice(
      name: name,
      phone: phone,
      locale: locale,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DeviceRegistrationStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (session) => emit(
        DeviceRegistrationState(
          status: DeviceRegistrationStatus.success,
          session: session,
        ),
      ),
    );
  }
}
