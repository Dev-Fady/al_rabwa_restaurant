import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/settings_fixtures.dart';

class _FakeRepository implements SettingsRepository {
  _FakeRepository({this.result, this.error});

  RestaurantSettings? result;
  Object? error;
  int calls = 0;
  String? lastLang;

  @override
  Future<Either<Failure, RestaurantSettings>> fetchSettings({
    String lang = 'ar',
  }) async {
    calls++;
    lastLang = lang;
    final failure = error;
    if (failure != null) {
      if (failure is Failure) return Left(failure);
      throw failure;
    }
    return Right(result!);
  }
}

void main() {
  group('StoreConfigCubit', () {
    test('starts loading and emits the fetched settings', () async {
      final repository = _FakeRepository(result: sampleSettings());
      final cubit = StoreConfigCubit(repository, lang: 'ar');

      expect(cubit.state.status, StoreConfigStatus.loading);
      expect(cubit.state.hasSettings, isFalse);

      await pumpEventQueue();

      expect(cubit.state.status, StoreConfigStatus.success);
      expect(cubit.state.settings?.restaurant.name, 'مطعم الربوة');
      expect(cubit.state.errorMessage, isNull);
      expect(repository.lastLang, 'ar');
      await cubit.close();
    });

    test('requests the storefront in the selected language', () async {
      final repository = _FakeRepository(result: sampleSettings());
      final cubit = StoreConfigCubit(repository, lang: 'en');

      await pumpEventQueue();

      expect(repository.lastLang, 'en');
      await cubit.close();
    });

    test('emits a failure with the repository message', () async {
      final repository = _FakeRepository(
        error: ServerFailure('تعذر الاتصال بالخادم'),
      );
      final cubit = StoreConfigCubit(repository);

      await pumpEventQueue();

      expect(cubit.state.status, StoreConfigStatus.failure);
      expect(cubit.state.errorMessage, 'تعذر الاتصال بالخادم');
      expect(cubit.state.hasSettings, isFalse);
      await cubit.close();
    });

    test('keeps the previous settings when a refresh fails', () async {
      final repository = _FakeRepository(result: sampleSettings());
      final cubit = StoreConfigCubit(repository);

      await pumpEventQueue();
      expect(cubit.state.hasSettings, isTrue);

      repository.error = ServerFailure('انقطع الاتصال');
      await cubit.refresh();

      expect(cubit.state.status, StoreConfigStatus.failure);
      expect(cubit.state.settings?.restaurant.name, 'مطعم الربوة');
      expect(cubit.state.errorMessage, 'انقطع الاتصال');
      await cubit.close();
    });
  });
}
