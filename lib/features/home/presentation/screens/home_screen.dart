import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Landing tab of the shell.
///
/// Everything on this screen comes from `GET /api/settings`: branding, hero
/// banner, welcome copy, order options, currency and payment methods. While
/// the request is in flight (or after a failure) the screen shows its own
/// loading/error state instead of an empty scaffold.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreConfigCubit, StoreConfigState>(
      builder: (context, state) {
        final settings = state.settings;

        return Scaffold(
          appBar: _HomeAppBar(settings: settings),
          body: settings == null
              ? _StatusBody(
                  state: state,
                  onRetry: () =>
                      context.read<StoreConfigCubit>().load(refresh: true),
                )
              : _HomeContent(settings: settings),
        );
      },
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar({this.settings});

  final RestaurantSettings? settings;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final restaurant = settings?.restaurant;
    final title = (restaurant?.name.trim().isNotEmpty ?? false)
        ? restaurant!.name
        : l10n.appTitle;

    return AppBar(
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RestaurantLogo(restaurant: restaurant),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (settings != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: _OpenStatusBadge(isOpen: settings!.isOpenNow),
          ),
      ],
    );
  }
}

class _RestaurantLogo extends StatelessWidget {
  const _RestaurantLogo({this.restaurant});

  final RestaurantBrand? restaurant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (restaurant?.hasLogo ?? false) {
      return ClipOval(
        child: AppNetworkImage(
          url: restaurant!.logo,
          width: 36,
          height: 36,
          backgroundColor: scheme.primaryContainer,
          fallbackColor: scheme.primary,
          fallbackIconSize: 18,
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.restaurant, size: 20, color: scheme.primary),
    );
  }
}

class _OpenStatusBadge extends StatelessWidget {
  const _OpenStatusBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final background = isOpen ? scheme.primaryContainer : scheme.errorContainer;
    final foreground = isOpen ? scheme.primary : scheme.onErrorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? l10n.storeOpenShort : l10n.storeClosed,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBody extends StatelessWidget {
  const _StatusBody({required this.state, required this.onRetry});

  final StoreConfigState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (state.status != StoreConfigStatus.failure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              l10n.loadingStore,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 56,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.storeSettingsError,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (state.errorMessage != null &&
                  state.errorMessage!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.settings});

  final RestaurantSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<StoreConfigCubit>();

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 16.0;
          final banners = settings.home.banners;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  28,
                ),
                children: [
                  if (settings.home.showBanner) ...[
                    if (banners.isEmpty)
                      _HeroBanner(
                        banner: null,
                        restaurant: settings.restaurant,
                        onTap: () => context.go(AppRoutes.menu),
                      )
                    else
                      for (var i = 0; i < banners.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _HeroBanner(
                          banner: banners[i],
                          restaurant: settings.restaurant,
                          onTap: () => _openBanner(context, banners[i]),
                        ),
                      ],
                  ],
                  if (settings.home.showWelcomeMessage) ...[
                    const SizedBox(height: 24),
                    _WelcomeSection(settings: settings),
                  ],
                  if (settings.ordering.orderTypes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _SectionTitle(text: l10n.orderOptionsTitle),
                    const SizedBox(height: 12),
                    _OrderOptions(options: settings.ordering.orderTypes),
                  ],
                  const SizedBox(height: 20),
                  _StoreInfoCard(settings: settings),
                  if (settings.contact.hasAny) ...[
                    const SizedBox(height: 20),
                    _ContactSection(contact: settings.contact),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.menu),
                    icon: const Icon(Icons.restaurant_menu),
                    label: Text(
                      l10n.browseMenu,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.banner,
    required this.restaurant,
    required this.onTap,
  });

  final HomeBanner? banner;
  final RestaurantBrand restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final hasImage = banner?.hasImage ?? false;
    final title = _firstNonEmpty([banner?.title, restaurant.name]);
    final subtitle = _firstNonEmpty([banner?.subtitle, restaurant.about]);
    final buttonLabel = _firstNonEmpty([banner?.buttonText, l10n.orderNow]);

    return Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 200),
            child: Stack(
              children: [
                Positioned.fill(
                  child: hasImage
                      ? AppNetworkImage(
                          url: banner!.image,
                          backgroundColor: scheme.primary,
                          fallbackColor: scheme.onPrimary,
                          fallbackIconSize: 42,
                        )
                      : _BannerFallback(scheme: scheme),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xCC08160E)],
                        stops: [0.35, 1],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(18, 72, 18, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title.isNotEmpty)
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(color: Color(0x66000000), blurRadius: 8),
                            ],
                          ),
                        ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xF2FFFFFF),
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                buttonLabel,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: scheme.onSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: scheme.onSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, Colors.black, 0.28)!,
          ],
        ),
      ),
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Icon(
            Icons.restaurant_menu,
            size: 64,
            color: scheme.onPrimary.withValues(alpha: 0.22),
          ),
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({required this.settings});

  final RestaurantSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final title = _firstNonEmpty([
      settings.home.heroTitle,
      l10n.homeWelcomeTitle,
    ]);
    final subtitle = _firstNonEmpty([
      settings.home.heroSubtitle,
      settings.restaurant.about,
      l10n.homeWelcomeSubtitle,
    ]);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.secondary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.appColors.titleColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: context.appColors.titleColor,
      ),
    );
  }
}

class _OrderOptions extends StatelessWidget {
  const _OrderOptions({required this.options});

  final List<OrderOption> options;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options) _OrderOptionChip(option: option),
      ],
    );
  }
}

class _OrderOptionChip extends StatelessWidget {
  const _OrderOptionChip({required this.option});

  final OrderOption option;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(option.value), size: 18, color: scheme.primary),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String value) => switch (value) {
    'delivery' => Icons.delivery_dining_outlined,
    'takeaway' => Icons.shopping_bag_outlined,
    'dine_in' => Icons.restaurant_outlined,
    _ => Icons.local_mall_outlined,
  };
}

class _StoreInfoCard extends StatelessWidget {
  const _StoreInfoCard({required this.settings});

  final RestaurantSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isOpen = settings.isOpenNow;
    final statusColor = isOpen ? scheme.primary : scheme.error;
    final statusBackground = isOpen
        ? scheme.primaryContainer
        : scheme.errorContainer;
    final closedMessage = settings.ordering.closedMessage.trim();
    final statusLabel = isOpen
        ? l10n.storeOpenNow
        : (closedMessage.isNotEmpty ? closedMessage : l10n.storeClosed);
    final payments = settings.ordering.paymentMethods
        .map((method) => method.label)
        .where((label) => label.trim().isNotEmpty)
        .toList();
    if (settings.onlinePaymentEnabled) {
      final gateway = settings.onlinePaymentGateway.trim();
      payments.add(
        gateway.isEmpty ? l10n.onlinePaymentLabel : gateway,
      );
    }
    final ordering = settings.ordering;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOpen ? Icons.schedule : Icons.schedule_outlined,
                  size: 21,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.orderStatus,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      statusLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: scheme.outlineVariant),
          const SizedBox(height: 12),
          if (payments.isNotEmpty) ...[
            _DetailRow(
              icon: Icons.payments_outlined,
              label: l10n.paymentLabel,
              value: payments.join(' • '),
            ),
            const SizedBox(height: 10),
          ],
          _DetailRow(
            icon: Icons.currency_exchange,
            label: l10n.currencyLabel,
            value: '${settings.currency.symbol} · ${settings.currency.code}',
          ),
          if (settings.reservationsEnabled) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.event_available_outlined,
              label: l10n.reservationsLabel,
              value: l10n.availableLabel,
            ),
          ],
          if (ordering.hasWorkingHours) ...[
            const SizedBox(height: 10),
            // _DetailRow(
            //   icon: Icons.schedule,
            //   label: l10n.workingHoursLabel,
            //   value: l10n.availableLabel,
            // ),
          ],
          if (ordering.requireCustomerLocation) ...[
            const SizedBox(height: 10),
            // _DetailRow(
            //   icon: Icons.location_on_outlined,
            //   label: l10n.locationRequiredLabel,
            //   value: l10n.requiredLabel,
            // ),
          ],
          if (ordering.deliveryFee > 0) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.delivery_dining_outlined,
              label: l10n.deliveryFeeLabel,
              value: settings.currency.format(ordering.deliveryFee),
            ),
          ],
          if (ordering.taxPercent > 0) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.percent,
              label: l10n.taxLabel,
              value: _formatPercent(ordering.taxPercent),
            ),
          ],
          if (ordering.servicePercent > 0) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.room_service_outlined,
              label: l10n.serviceLabel,
              value: _formatPercent(ordering.servicePercent),
            ),
          ],
          if (ordering.hasDeliveryZones) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.map_outlined,
              label: l10n.deliveryZonesLabel,
              value: '${ordering.deliveryZones.length}',
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.contact});

  final StoreContact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final entries = <_ContactEntry>[
      if (contact.phone.trim().isNotEmpty)
        _ContactEntry(
          icon: Icons.call_outlined,
          label: l10n.phoneLabel,
          value: contact.phone,
          uri: _tryUri('tel:${contact.phone.trim()}'),
        ),
      if (contact.whatsapp.trim().isNotEmpty)
        _ContactEntry(
          icon: Icons.chat_bubble_outline,
          label: l10n.whatsappLabel,
          value: contact.whatsapp,
          uri: _whatsappUri(contact.whatsapp),
        ),
      if (contact.instagram.trim().isNotEmpty)
        _ContactEntry(
          icon: Icons.camera_alt_outlined,
          label: l10n.instagramLabel,
          value: contact.instagram,
          uri: _socialUri(contact.instagram, 'https://instagram.com/'),
        ),
      if (contact.facebook.trim().isNotEmpty)
        _ContactEntry(
          icon: Icons.facebook,
          label: l10n.facebookLabel,
          value: contact.facebook,
          uri: _socialUri(contact.facebook, 'https://facebook.com/'),
        ),
      if (contact.location.trim().isNotEmpty)
        _ContactEntry(
          icon: Icons.location_on_outlined,
          label: l10n.locationLabel,
          value: contact.location,
          uri: _locationUri(contact.location),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.contactTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.appColors.titleColor,
            ),
          ),
          const SizedBox(height: 6),
          for (final entry in entries) _ContactRow(entry: entry),
        ],
      ),
    );
  }
}

class _ContactEntry {
  const _ContactEntry({
    required this.icon,
    required this.label,
    required this.value,
    this.uri,
  });

  final IconData icon;
  final String label;
  final String value;
  final Uri? uri;
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.entry});

  final _ContactEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final uri = entry.uri;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: uri == null ? null : () => _launchExternal(uri),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(entry.icon, size: 18, color: scheme.primary),
            const SizedBox(width: 10),
            Text(
              entry.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchExternal(Uri uri) async {
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // A missing dialer/browser must never break the screen.
  }
}

Uri? _tryUri(String value) => Uri.tryParse(value);

Uri? _whatsappUri(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return Uri.tryParse(trimmed);
  }
  final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? null : Uri.tryParse('https://wa.me/$digits');
}

Uri? _socialUri(String value, String base) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return Uri.tryParse(trimmed);
  }
  return Uri.tryParse('$base${trimmed.replaceFirst(RegExp(r'^@'), '')}');
}

Uri? _locationUri(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return Uri.tryParse(trimmed);
  }
  return Uri.tryParse(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(trimmed)}',
  );
}

void _openBanner(BuildContext context, HomeBanner banner) {
  if (banner.opensExternalUrl) {
    final uri = Uri.tryParse(banner.url.trim());
    if (uri != null) {
      _launchExternal(uri);
      return;
    }
  }
  context.go(AppRoutes.menu);
}

String _formatPercent(double value) {
  return value == value.roundToDouble()
      ? '${value.toInt()}%'
      : '${value.toStringAsFixed(1)}%';
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}
