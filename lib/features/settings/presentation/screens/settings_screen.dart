import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
// import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_status_body.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/delete_my_data_cubit.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/delete_my_data_state.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/widgets/settings_contact_card.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/widgets/settings_delete_data_button.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/widgets/settings_header.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/widgets/settings_language_selector.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/widgets/settings_working_hours_card.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Store tab ("المطعم"): the restaurant's identity, working hours and the menu
/// language picker, matching the `/{lang}/about` storefront page.
///
/// All content is derived from the `/api/settings` payload owned by
/// [StoreConfigCubit]; the selected menu language is the app locale managed by
/// [SettingsCubit].
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Matches the storefront's centered 460px column on wide screens.
  static const double _contentMaxWidth = 460;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<DeleteMyDataCubit, DeleteMyDataState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case DeleteMyDataStatus.success:
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(l10n.deleteMyDataSuccess)));
            // The device no longer has a session; start a fresh registration.
            GoRouter.maybeOf(context)?.go(AppRoutes.registration);
          case DeleteMyDataStatus.failure:
            final message = state.errorMessage.trim();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    message.isEmpty ? l10n.deleteMyDataError : message,
                  ),
                ),
              );
          case DeleteMyDataStatus.idle:
          case DeleteMyDataStatus.deleting:
            break;
        }
      },
      child: BlocBuilder<StoreConfigCubit, StoreConfigState>(
        builder: (context, state) {
          final settings = state.settings;

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              surfaceTintColor: Colors.transparent,
              // title: Text(
              //   l10n.navStore,
              //   style: theme.textTheme.titleLarge?.copyWith(
              //     color: context.appColors.brandGreen,
              //     fontWeight: FontWeight.w900,
              //   ),
              // ),
              actions: const [SettingsDeleteDataButton()],
            ),
            body: SafeArea(
              child: settings == null
                  ? HomeStatusBody(
                      state: state,
                      onRetry: () =>
                          context.read<StoreConfigCubit>().load(refresh: true),
                    )
                  : _SettingsContent(settings: settings),
            ),
          );
        },
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({required this.settings});

  final RestaurantSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<StoreConfigCubit>();
    final ordering = settings.ordering;
    final showWorkingHours = ordering.hasWorkingHours || ordering.enabled;

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 17.0;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: SettingsScreen._contentMaxWidth,
              ),
              child: ListView(
                key: const ValueKey('store-content'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  32,
                ),
                children: [
                  SettingsHeader(
                    restaurant: settings.restaurant,
                    fallbackName: l10n.appTitle,
                  ),
                  if (showWorkingHours) ...[
                    const SizedBox(height: 18),
                    SettingsWorkingHoursCard(ordering: ordering),
                  ],
                  const SizedBox(height: 21),
                  Text(
                    l10n.storeLanguageTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SettingsLanguageSelector(
                    locales: settings.localization.locales,
                    onChanged: (locale) {
                      try {
                        context.read<SettingsCubit>().changeLanguage(locale);
                      } catch (_) {
                        // Isolated tests may not provide the app-level cubit.
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SettingsContactCard(contact: settings.contact),
                  const SizedBox(height: 24),
                  Text(
                    l10n.storePoweredBy,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
