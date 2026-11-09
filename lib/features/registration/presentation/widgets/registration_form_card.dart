import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_text_button.dart';
import 'package:al_rabwa_restaurant/core/widget/app_text_form_field.dart';
import 'package:al_rabwa_restaurant/features/registration/presentation/cubit/device_registration_cubit.dart';
import 'package:al_rabwa_restaurant/features/registration/presentation/cubit/device_registration_state.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Name/phone form that creates the device session.
class RegistrationFormCard extends StatefulWidget {
  const RegistrationFormCard({super.key, this.onLocaleChanged});

  /// Lets the app-level settings cubit update the whole app language.
  final ValueChanged<String>? onLocaleChanged;

  @override
  State<RegistrationFormCard> createState() => _RegistrationFormCardState();
}

class _RegistrationFormCardState extends State<RegistrationFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<DeviceRegistrationCubit>().register(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      locale: Localizations.localeOf(context).languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 480;
        final fieldRadius = BorderRadius.circular(16);
        final fieldFill = colors.surfaceContainerHighest.withValues(
          alpha: 0.38,
        );

        return Container(
          padding: EdgeInsets.all(compact ? 20 : 28),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(compact ? 26 : 30),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.75),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: BlocBuilder<DeviceRegistrationCubit, DeviceRegistrationState>(
            builder: (context, state) {
              final isSubmitting = state.isSubmitting;
              final rawError = state.errorMessage?.trim() ?? '';
              final error =
                  state.status == DeviceRegistrationStatus.failure &&
                      rawError.isEmpty
                  ? l10n.registerError
                  : rawError;

              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FormHeader(compact: compact),
                    SizedBox(height: compact ? 22 : 28),
                    AppTextFormField(
                      controller: _nameController,
                      enabled: !isSubmitting,
                      filled: true,
                      fillColor: fieldFill,
                      hintText: l10n.registerNameHint,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: colors.onSurfaceVariant,
                      ),
                      inputTextStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface,
                      ),
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 17,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: fieldRadius,
                        borderSide: BorderSide(
                          color: colors.primary,
                          width: 1.6,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: fieldRadius,
                        borderSide: BorderSide(
                          color: colors.outlineVariant.withValues(alpha: 0.9),
                        ),
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.isEmpty) return l10n.registerNameRequired;
                        if (name.length < 2) return l10n.registerNameTooShort;
                        return null;
                      },
                      onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                    ),
                    const SizedBox(height: 14),
                    AppTextFormField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      enabled: !isSubmitting,
                      filled: true,
                      fillColor: fieldFill,
                      hintText: l10n.registerPhoneHint,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: colors.onSurfaceVariant,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9+\s\-()]'),
                        ),
                      ],
                      inputTextStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface,
                      ),
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 17,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: fieldRadius,
                        borderSide: BorderSide(
                          color: colors.primary,
                          width: 1.6,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: fieldRadius,
                        borderSide: BorderSide(
                          color: colors.outlineVariant.withValues(alpha: 0.9),
                        ),
                      ),
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isEmpty) return l10n.registerPhoneRequired;
                        final normalized = phone.replaceAll(
                          RegExp(r'[\s\-()]'),
                          '',
                        );
                        if (!RegExp(r'^\+?\d{7,15}$').hasMatch(normalized)) {
                          return l10n.registerPhoneInvalid;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    SizedBox(height: compact ? 20 : 24),
                    _LanguageToggle(
                      selectedCode: Localizations.localeOf(
                        context,
                      ).languageCode,
                      enabled: !isSubmitting,
                      onChanged: (code) => widget.onLocaleChanged?.call(code),
                    ),
                    const SizedBox(height: 18),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: error.isEmpty
                          ? const SizedBox.shrink()
                          : Padding(
                              key: ValueKey(error),
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _ErrorBanner(message: error),
                            ),
                    ),
                    AppTextButton(
                      buttonText: l10n.registerSubmit,
                      isLoading: isSubmitting,
                      onPressed: _submit,
                      backgroundColor: appColors.brandGreen,
                      borderRadius: 18,
                      buttonHeight: compact ? 54 : 56,
                      textStyle: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 15,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            l10n.registerPrivacyNote,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: compact ? 44 : 50,
          height: compact ? 44 : 50,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.person_add_alt_1_rounded,
            color: colors.onPrimaryContainer,
            size: compact ? 22 : 25,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.registerFormTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                l10n.registerFormSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({
    required this.selectedCode,
    required this.enabled,
    required this.onChanged,
  });

  final String selectedCode;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.language_rounded,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                l10n.registerLanguageLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        IgnorePointer(
          ignoring: !enabled,
          child: Row(
            children: [
              Expanded(
                child: _LanguageOption(
                  label: l10n.arabic,
                  isSelected: selectedCode == 'ar',
                  onTap: () => onChanged('ar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LanguageOption(
                  label: l10n.english,
                  isSelected: selectedCode == 'en',
                  onTap: () => onChanged('en'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = context.appColors;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSelected ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? appColors.brandGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? appColors.brandGreen
                    : colors.outlineVariant.withValues(alpha: 0.9),
                width: 1.3,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check_circle_rounded,
                    size: 17,
                    color: colors.onPrimary,
                  ),
                  const SizedBox(width: 7),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 19,
              color: colors.onErrorContainer,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onErrorContainer,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
