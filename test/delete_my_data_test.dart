import 'dart:async';

import 'package:al_rabwa_restaurant/core/constants/app_keys.dart';
import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/settings/data/datasources/account_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/settings/data/repositories/account_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/settings/domain/repositories/account_repository.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/delete_my_data_cubit.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/delete_my_data_state.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSecureStorage extends FlutterSecureStorage {
  _FakeSecureStorage({Map<String, String>? initial}) {
    if (initial != null) values.addAll(initial);
  }

  final Map<String, String> values = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }
}

class _FakeRemoteDataSource implements AccountRemoteDataSource {
  _FakeRemoteDataSource({this.error});

  Object? error;
  int calls = 0;

  @override
  Future<void> deleteMyData() async {
    calls++;
    final error = this.error;
    if (error != null) throw error;
  }
}

class _FakeAccountRepository implements AccountRepository {
  _FakeAccountRepository({this.result});

  Either<Failure, Unit>? result;
  int calls = 0;

  @override
  Future<Either<Failure, Unit>> deleteMyData() async {
    calls++;
    return result ?? Right(unit);
  }
}

class _PendingAccountRepository implements AccountRepository {
  final Completer<Either<Failure, Unit>> completer =
      Completer<Either<Failure, Unit>>();
  int calls = 0;

  @override
  Future<Either<Failure, Unit>> deleteMyData() {
    calls++;
    return completer.future;
  }
}

void main() {
  group('AccountRepository', () {
    test('deletes the device and clears the stored token', () async {
      final remote = _FakeRemoteDataSource();
      final storage = _FakeSecureStorage(
        initial: {AppKeys.accessToken: 'device_token'},
      );
      final repository = AccountRepositoryImpl(
        remoteDataSource: remote,
        secureStorage: storage,
      );

      final result = await repository.deleteMyData();

      expect(result.isRight(), isTrue);
      expect(remote.calls, 1);
      expect(storage.values[AppKeys.accessToken], isNull);
    });

    test('keeps the token when the API rejects the request', () async {
      final remote = _FakeRemoteDataSource(
        error: DioException(
          requestOptions: RequestOptions(path: 'me'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: 'me'),
            statusCode: 401,
            data: {'message': 'انتهت الجلسة، يرجى فتح التطبيق مرة أخرى.'},
          ),
        ),
      );
      final storage = _FakeSecureStorage(
        initial: {AppKeys.accessToken: 'expired_token'},
      );
      final repository = AccountRepositoryImpl(
        remoteDataSource: remote,
        secureStorage: storage,
      );

      final result = await repository.deleteMyData();

      final failure = result.fold(
        (failure) => failure,
        (_) => fail('Expected the deletion to fail.'),
      );
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'انتهت الجلسة، يرجى فتح التطبيق مرة أخرى.');
      expect(storage.values[AppKeys.accessToken], 'expired_token');
    });
  });

  group('DeleteMyDataCubit', () {
    test('emits deleting then success', () async {
      final repository = _FakeAccountRepository();
      final cubit = DeleteMyDataCubit(repository);
      addTearDown(cubit.close);

      final statuses = <DeleteMyDataStatus>[];
      final subscription = cubit.stream.listen(
        (state) => statuses.add(state.status),
      );
      addTearDown(subscription.cancel);

      await cubit.deleteMyData();
      await Future<void>.delayed(Duration.zero);

      expect(statuses, [
        DeleteMyDataStatus.deleting,
        DeleteMyDataStatus.success,
      ]);
      expect(cubit.state.isDeleted, isTrue);
    });

    test('emits failure with the message returned by the repository', () async {
      final repository = _FakeAccountRepository(
        result: Left(ServerFailure('انتهت الجلسة، يرجى فتح التطبيق مرة أخرى.')),
      );
      final cubit = DeleteMyDataCubit(repository);
      addTearDown(cubit.close);

      await cubit.deleteMyData();

      expect(cubit.state.hasError, isTrue);
      expect(
        cubit.state.errorMessage,
        'انتهت الجلسة، يرجى فتح التطبيق مرة أخرى.',
      );
    });

    test('ignores a second delete while one request is running', () async {
      final repository = _PendingAccountRepository();
      final cubit = DeleteMyDataCubit(repository);
      addTearDown(cubit.close);

      final first = cubit.deleteMyData();
      await cubit.deleteMyData();
      expect(repository.calls, 1);

      repository.completer.complete(Right(unit));
      await first;
      expect(cubit.state.isDeleted, isTrue);
    });
  });
}
