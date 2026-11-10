import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_delivery_address_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_delivery_address_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAddressesRepository implements AddressesRepository {
  Either<Failure, List<Address>> result = const Right([]);
  int fetchCalls = 0;
  String? lastLang;

  @override
  Future<Either<Failure, List<Address>>> fetchAddresses({
    String lang = 'ar',
  }) async {
    fetchCalls++;
    lastLang = lang;
    return result;
  }

  @override
  Future<Either<Failure, Address>> fetchAddress({
    required int id,
    String lang = 'ar',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Address>> createAddress({
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Address>> updateAddress({
    required int id,
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Address>> setDefaultAddress({
    required int id,
    String lang = 'ar',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteAddress({
    required int id,
    String lang = 'ar',
  }) async {
    throw UnimplementedError();
  }
}

Address _address({
  required int id,
  required String label,
  bool isDefault = false,
}) {
  return Address(
    id: id,
    kind: AddressKind.home,
    kindLabel: 'المنزل',
    label: label,
    title: label,
    summary: 'الدوحة',
    deliveryZone: null,
    isDeliverable: true,
    area: 'الدوحة',
    street: 'شارع 1',
    building: 'مبنى 2',
    notes: '',
    point: null,
    lastUsedAt: null,
    isDefault: isDefault,
  );
}

void main() {
  late _FakeAddressesRepository repository;
  late HomeDeliveryAddressCubit cubit;

  setUp(() {
    repository = _FakeAddressesRepository();
    cubit = HomeDeliveryAddressCubit(
      repository,
      const FlutterSecureStorage(),
      lang: 'ar',
    );
  });

  tearDown(() => cubit.close());

  test('loads the address marked as default', () async {
    repository.result = Right([
      _address(id: 1, label: 'البيت'),
      _address(id: 2, label: 'العمل', isDefault: true),
    ]);

    await cubit.load();

    expect(cubit.state.status, HomeDeliveryAddressStatus.success);
    expect(cubit.state.selectedAddress?.id, 2);
    expect(cubit.state.selectedAddress?.displayName, 'العمل');
    expect(repository.lastLang, 'ar');
  });

  test('falls back to the first address when none is default', () async {
    repository.result = Right([
      _address(id: 1, label: 'البيت'),
      _address(id: 2, label: 'العمل'),
    ]);

    await cubit.load();

    expect(cubit.state.selectedAddress?.id, 1);
  });

  test('keeps the picked address across a reload', () async {
    repository.result = Right([
      _address(id: 1, label: 'البيت'),
      _address(id: 2, label: 'العمل', isDefault: true),
    ]);
    await cubit.load();

    cubit.select(_address(id: 1, label: 'البيت'));
    await cubit.load();

    expect(cubit.state.selectedAddress?.id, 1);
  });

  test('shows the newly saved default after the picker is dismissed', () async {
    repository.result = Right([
      _address(id: 1, label: 'البيت', isDefault: true),
      _address(id: 2, label: 'العمل'),
    ]);
    await cubit.load();
    expect(cubit.state.selectedAddress?.id, 1);

    repository.result = Right([
      _address(id: 1, label: 'البيت'),
      _address(id: 2, label: 'العمل', isDefault: true),
    ]);
    await cubit.load(preferDefault: true);

    expect(cubit.state.selectedAddress?.id, 2);
    expect(cubit.state.selectedAddress?.displayName, 'العمل');
  });

  test('keeps the visible address when a refresh fails', () async {
    repository.result = Right([_address(id: 1, label: 'البيت')]);
    await cubit.load();

    repository.result = Left(ServerFailure('offline'));
    await cubit.load();

    expect(cubit.state.status, HomeDeliveryAddressStatus.failure);
    expect(cubit.state.errorMessage, 'offline');
    expect(cubit.state.selectedAddress?.id, 1);
  });

  test('clears the selection when the customer has no addresses', () async {
    repository.result = Right([_address(id: 1, label: 'البيت')]);
    await cubit.load();

    repository.result = const Right([]);
    await cubit.load();

    expect(cubit.state.status, HomeDeliveryAddressStatus.success);
    expect(cubit.state.selectedAddress, isNull);
    expect(cubit.state.hasAddresses, isFalse);
  });
}
