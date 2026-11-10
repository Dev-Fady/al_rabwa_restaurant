import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/address_list_cubit.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/address_list_state.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/widgets/address_card.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/widgets/delete_address_dialog.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/item_details_widgets.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Lets the customer pick a saved delivery address or create a new one.
///
/// The chosen [Address] is returned to the caller (the home delivery bar), so
/// it can be shown immediately. Adding an address opens the existing form and
/// selects the newly saved result on the way back.
class AddressSelectionScreen extends StatelessWidget {
  const AddressSelectionScreen({super.key, this.selectedAddressId});

  /// Highlights the address currently used for delivery, when there is one.
  final int? selectedAddressId;

  Future<void> _addNewAddress(BuildContext context) async {
    final address = await context.push<Address>(AppRoutes.addAddress);
    if (!context.mounted || address == null) return;
    context.pop(address);
  }

  Future<void> _openDetails(BuildContext context, Address address) async {
    final id = address.id;
    if (id == null) return;

    await context.push<void>(AppRoutes.addressDetailsPath(id));
    if (!context.mounted) return;
    // The address may have been edited on the details screen.
    context.read<AddressListCubit>().load();
  }

  Future<void> _editAddress(BuildContext context, Address address) async {
    final updated = await context.push<Address>(
      AppRoutes.addAddress,
      extra: address,
    );
    if (!context.mounted || updated == null) return;
    context.read<AddressListCubit>().load();
  }

  Future<void> _deleteAddress(BuildContext context, Address address) async {
    final id = address.id;
    if (id == null) return;

    final confirmed = await showDeleteAddressDialog(
      context,
      addressName: address.displayName,
    );
    if (!context.mounted || !confirmed) return;

    await context.read<AddressListCubit>().deleteAddress(id);
  }

  void _selectAddress(BuildContext context, Address address) {
    Navigator.of(context).pop(address);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AddressListCubit, AddressListState>(
      listenWhen: (previous, current) =>
          (current.defaultError != null &&
              previous.defaultError != current.defaultError) ||
          (current.deleteError != null &&
              previous.deleteError != current.deleteError),
      listener: (context, state) {
        final defaultError = state.defaultError;
        final deleteError = state.deleteError;

        final String? message;
        if (deleteError != null) {
          final raw = deleteError.trim();
          message = raw.isEmpty ? l10n.addressDeleteError : raw;
        } else if (defaultError != null) {
          final raw = defaultError.trim();
          message = raw.isEmpty ? l10n.addressSetDefaultError : raw;
        } else {
          message = null;
        }

        if (message == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      child: Scaffold(
        backgroundColor: context.appColors.background,
        appBar: AppBar(
          backgroundColor: context.appColors.surface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          leadingWidth: 64,
          leading: const Padding(
            padding: EdgeInsetsDirectional.only(start: 8),
            child: Center(child: ItemBackButton()),
          ),
          title: Text(
            l10n.addressSelectTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: context.appColors.brandGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth >= 600
                  ? 32.0
                  : 16.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: BlocBuilder<AddressListCubit, AddressListState>(
                    builder: (context, state) {
                      final selectedId = _selectedId(state);

                      return ListView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16,
                          horizontalPadding,
                          28,
                        ),
                        children: [
                          Text(
                            l10n.addressSelectSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _AddAddressButton(
                            label: l10n.addressAddTitle,
                            onTap: () => _addNewAddress(context),
                          ),
                          const SizedBox(height: 22),
                          if (state.hasAddresses) ...[
                            _SectionTitle(label: l10n.addressSavedTitle),
                            if (state.hasError) ...[
                              const SizedBox(height: 10),
                              _InlineError(
                                message: _errorMessage(l10n, state),
                                retryLabel: l10n.retry,
                                onRetry: () =>
                                    context.read<AddressListCubit>().load(),
                              ),
                            ],
                            const SizedBox(height: 10),
                            for (final address in state.addresses)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AddressCard(
                                  key: ValueKey('address-${address.id}'),
                                  address: address,
                                  selected: address.id == selectedId,
                                  isDefault: state.isDefault(address.id),
                                  isSettingDefault: state.isSettingDefault(
                                    address.id,
                                  ),
                                  isDeleting: state.isDeleting(address.id),
                                  onTap: () => _selectAddress(context, address),
                                  onDetails: address.id == null
                                      ? null
                                      : () => _openDetails(context, address),
                                  onEdit: address.id == null
                                      ? null
                                      : () => _editAddress(context, address),
                                  onSetDefault: address.id == null
                                      ? null
                                      : () => context
                                            .read<AddressListCubit>()
                                            .setDefault(address.id!),
                                  onDelete: address.id == null
                                      ? null
                                      : () => _deleteAddress(context, address),
                                ),
                              ),
                          ] else if (state.isLoading)
                            const _LoadingAddresses()
                          else if (state.hasError)
                            _AddressListError(
                              message: _errorMessage(l10n, state),
                              retryLabel: l10n.retry,
                              onRetry: () =>
                                  context.read<AddressListCubit>().load(),
                            )
                          else
                            _EmptyAddresses(message: l10n.addressListEmpty),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, AddressListState state) {
    final raw = state.errorMessage?.trim() ?? '';
    return raw.isEmpty ? l10n.addressListError : raw;
  }

  /// The address currently used for delivery when it is still in the list;
  /// otherwise the saved default is shown as the pre-selected choice.
  int? _selectedId(AddressListState state) {
    final current = selectedAddressId;
    if (current != null &&
        state.addresses.any((address) => address.id == current)) {
      return current;
    }

    return state.defaultAddressId;
  }
}

class _AddAddressButton extends StatelessWidget {
  const _AddAddressButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.appColors.brandGreen;

    return Semantics(
      button: true,
      label: label,
      child: OutlinedButton.icon(
        key: const ValueKey('add-address-button'),
        onPressed: onTap,
        icon: const Icon(Icons.add_location_alt_rounded, size: 21),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: brand,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: brand.withValues(alpha: 0.5), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: context.appColors.titleColor,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _LoadingAddresses extends StatelessWidget {
  const _LoadingAddresses();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: CircularProgressIndicator(color: context.appColors.brandGreen),
      ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 46,
            color: colors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _AddressListError extends StatelessWidget {
  const _AddressListError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 46, color: colors.error),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: colors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onErrorContainer),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}
