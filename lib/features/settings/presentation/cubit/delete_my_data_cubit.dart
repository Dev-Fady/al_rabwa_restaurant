import 'package:al_rabwa_restaurant/features/settings/domain/repositories/account_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'delete_my_data_state.dart';

/// Runs `DELETE /api/me` for the device behind the settings bar action.
class DeleteMyDataCubit extends Cubit<DeleteMyDataState> {
  DeleteMyDataCubit(this._repository) : super(const DeleteMyDataState());

  final AccountRepository _repository;

  Future<void> deleteMyData() async {
    if (state.isDeleting) return;

    emit(const DeleteMyDataState(status: DeleteMyDataStatus.deleting));

    final result = await _repository.deleteMyData();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        DeleteMyDataState(
          status: DeleteMyDataStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(const DeleteMyDataState(status: DeleteMyDataStatus.success)),
    );
  }
}
