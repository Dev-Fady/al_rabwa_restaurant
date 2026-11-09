import 'package:al_rabwa_restaurant/core/widget/app_text_form_field.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Text fields of the add-address form.
///
/// The controller state lives in the screen; this widget only renders the
/// labels, hints and validators so it can be reused by the wide (two-column)
/// and narrow (stacked) layouts.
class AddressFormFields extends StatelessWidget {
  const AddressFormFields({
    super.key,
    required this.labelController,
    required this.areaController,
    required this.streetController,
    required this.buildingController,
    required this.notesController,
    this.enabled = true,
  });

  final TextEditingController labelController;
  final TextEditingController areaController;
  final TextEditingController streetController;
  final TextEditingController buildingController;
  final TextEditingController notesController;
  final bool enabled;

  /// Below this width the street/building pair stacks instead of sitting side
  /// by side, so neither field is squeezed on small phones.
  static const double _pairBreakpoint = 360;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final street = _AddressField(
      label: l10n.addressStreetField,
      hint: l10n.addressStreetHint,
      controller: streetController,
      enabled: enabled,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      validator: (value) =>
          (value?.trim() ?? '').isEmpty ? l10n.addressStreetRequired : null,
    );
    final building = _AddressField(
      label: l10n.addressBuildingField,
      hint: l10n.addressBuildingHint,
      controller: buildingController,
      enabled: enabled,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      validator: (value) =>
          (value?.trim() ?? '').isEmpty ? l10n.addressBuildingRequired : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AddressField(
          label: l10n.addressLabelField,
          hint: l10n.addressLabelHint,
          controller: labelController,
          enabled: enabled,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _AddressField(
          label: l10n.addressAreaField,
          hint: l10n.addressAreaHint,
          controller: areaController,
          enabled: enabled,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              (value?.trim() ?? '').isEmpty ? l10n.addressAreaRequired : null,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < _pairBreakpoint) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [street, const SizedBox(height: 16), building],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Expanded(child: street),
                Expanded(child: building),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _AddressField(
          label: l10n.addressNotesField,
          hint: l10n.addressNotesHint,
          controller: notesController,
          enabled: enabled,
          maxLines: 3,
          minLines: 2,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.maxLines,
    this.minLines,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final fieldRadius = BorderRadius.circular(14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 2, bottom: 8),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        AppTextFormField(
          controller: controller,
          enabled: enabled,
          hintText: hint,
          validator: validator,
          maxLines: maxLines,
          minLines: minLines,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          filled: true,
          fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.35),
          inputTextStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
          ),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: BorderSide(color: colors.primary, width: 1.6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
        ),
      ],
    );
  }
}
