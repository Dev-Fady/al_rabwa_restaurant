import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';

enum StoreConfigStatus { initial, loading, success, failure }

class StoreConfigState {
  const StoreConfigState({
    this.status = StoreConfigStatus.initial,
    this.settings,
    this.errorMessage,
    this.lang = 'ar',
  });

  final StoreConfigStatus status;
  final RestaurantSettings? settings;
  final String? errorMessage;
  final String lang;

  bool get isLoading => status == StoreConfigStatus.loading;

  bool get hasSettings => settings != null;

  bool get isRefreshing => isLoading && hasSettings;

  StoreConfigState copyWith({
    StoreConfigStatus? status,
    RestaurantSettings? settings,
    String? errorMessage,
    String? lang,
    bool clearError = false,
  }) {
    return StoreConfigState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lang: lang ?? this.lang,
    );
  }
}
