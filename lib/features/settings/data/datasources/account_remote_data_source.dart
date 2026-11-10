import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';

/// Deletes the current device through `DELETE /api/me`.
abstract class AccountRemoteDataSource {
  Future<void> deleteMyData();
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  AccountRemoteDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<void> deleteMyData() async {
    // Retrofit throws for non-2xx responses; a 204 simply completes.
    await apiService.deleteMyData();
  }
}
