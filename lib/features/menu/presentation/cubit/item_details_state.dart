import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item_details.dart';

import 'menu_state.dart';

class ItemDetailsState {
  const ItemDetailsState({
    this.status = MenuStatus.initial,
    this.details,
    this.errorMessage,
    this.lang = 'ar',
  });

  final MenuStatus status;
  final MenuItemDetails? details;
  final String? errorMessage;
  final String lang;

  bool get isLoading => status == MenuStatus.loading;

  bool get hasDetails => details != null;

  ItemDetailsState copyWith({
    MenuStatus? status,
    MenuItemDetails? details,
    String? errorMessage,
    String? lang,
    bool clearError = false,
  }) {
    return ItemDetailsState(
      status: status ?? this.status,
      details: details ?? this.details,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lang: lang ?? this.lang,
    );
  }
}
