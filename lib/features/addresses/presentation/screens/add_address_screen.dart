import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_text_button.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/errors/location_failure.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/add_address_cubit.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/add_address_state.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/widgets/address_form_fields.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/widgets/address_kind_selector.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/widgets/address_location_picker.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/item_details_widgets.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Creates a delivery address with a map pin, kind, and address parts.
///
/// Opens over the shell and returns the saved address to its caller so the
/// delivery bar can show it immediately.
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  /// Below this width the map and the form stack vertically.
  static const double _wideBreakpoint = 900;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _areaController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _notesController = TextEditingController();

  /// Live map centre; the picker writes it, [_submit] reads it.
  final ValueNotifier<GeoPoint> _point = ValueNotifier(GeoPoint.qatarCenter);

  @override
  void dispose() {
    _labelController.dispose();
    _areaController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _notesController.dispose();
    _point.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AddAddressCubit>().save(
      point: _point.value,
      label: _labelController.text.trim(),
      area: _areaController.text.trim(),
      street: _streetController.text.trim(),
      building: _buildingController.text.trim(),
      notes: _notesController.text.trim(),
    );
  }

  String _failureMessage(AppLocalizations l10n, AddAddressState state) {
    if (state.outsideQatar) return l10n.addressOutsideQatar;

    final issue = state.locationIssue;
    if (issue != null) {
      return switch (issue) {
        LocationIssue.serviceDisabled => l10n.addressLocationServiceDisabled,
        LocationIssue.permissionDenied => l10n.addressLocationPermissionDenied,
        LocationIssue.permissionDeniedForever =>
          l10n.addressLocationPermissionDeniedForever,
        LocationIssue.unavailable => l10n.addressLocationUnavailable,
      };
    }

    final raw = state.errorMessage?.trim() ?? '';
    return raw.isEmpty ? l10n.addressSaveError : raw;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocListener<AddAddressCubit, AddAddressState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.isSuccess) {
          final address = state.createdAddress;
          if (address != null && !address.isDeliverable) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.addressNotDeliverable)));
          }
          context.pop(address);
          return;
        }

        if (state.status != AddAddressStatus.failure) return;

        final message = _failureMessage(l10n, state);
        if (message.isEmpty) return;

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
            l10n.addressAddTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: context.appColors.brandGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocBuilder<AddAddressCubit, AddAddressState>(
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide =
                      constraints.maxWidth >= AddAddressScreen._wideBreakpoint;
                  final horizontalPadding = constraints.maxWidth >= 600
                      ? 32.0
                      : 16.0;

                  final map = _MapCard(
                    point: _point,
                    state: state,
                    height: isWide ? 460 : 220,
                    onLocate: () =>
                        context.read<AddAddressCubit>().useCurrentLocation(),
                  );

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      28,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isWide ? 1080 : 620,
                        ),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 24,
                                children: [
                                  Expanded(flex: 5, child: map),
                                  Expanded(
                                    flex: 4,
                                    child: _FormCard(
                                      boxed: true,
                                      child: _buildForm(
                                        context,
                                        state,
                                        colors: colors,
                                        l10n: l10n,
                                        theme: theme,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  map,
                                  const SizedBox(height: 18),
                                  _buildForm(
                                    context,
                                    state,
                                    colors: colors,
                                    l10n: l10n,
                                    theme: theme,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AddAddressState state, {
    required ColorScheme colors,
    required AppLocalizations l10n,
    required ThemeData theme,
  }) {
    final isSubmitting = state.isSubmitting;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AddressKindSelector(
            selected: state.kind,
            enabled: !isSubmitting,
            onChanged: (kind) =>
                context.read<AddAddressCubit>().selectKind(kind),
          ),
          const SizedBox(height: 20),
          AddressFormFields(
            labelController: _labelController,
            areaController: _areaController,
            streetController: _streetController,
            buildingController: _buildingController,
            notesController: _notesController,
            enabled: !isSubmitting,
          ),
          const SizedBox(height: 24),
          AppTextButton(
            buttonText: l10n.addressSave,
            isLoading: isSubmitting,
            onPressed: _submit,
            backgroundColor: context.appColors.brandGreen,
            borderRadius: 16,
            buttonHeight: 54,
            textStyle: TextStyle(
              color: colors.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Map plus the live coordinate readout below it.
class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.point,
    required this.state,
    required this.height,
    required this.onLocate,
  });

  final ValueNotifier<GeoPoint> point;
  final AddAddressState state;
  final double height;
  final VoidCallback onLocate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: AddressLocationPicker(
            point: point,
            focusPoint: state.focusPoint,
            focusRequest: state.focusRequest,
            isLocating: state.isLocating,
            onLocate: onLocate,
          ),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<GeoPoint>(
          valueListenable: point,
          builder: (context, value, _) => Text(
            // Five decimals is ~1 m, plenty for a delivery pin while staying
            // readable the way the design shows it.
            '${value.latitude.toStringAsFixed(5)}, '
            '${value.longitude.toStringAsFixed(5)}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// Card chrome for the wide layout; the phone layout is borderless like the
/// design.
class _FormCard extends StatelessWidget {
  const _FormCard({required this.child, required this.boxed});

  final Widget child;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    if (!boxed) return child;

    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: child,
    );
  }
}
