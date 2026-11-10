import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Asks the customer to confirm deleting [addressName].
///
/// Returns `true` only when the destructive action was confirmed.
Future<bool> showDeleteAddressDialog(
  BuildContext context, {
  required String addressName,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final colors = Theme.of(context).colorScheme;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.addressDeleteConfirmTitle),
      content: Text(l10n.addressDeleteConfirmMessage(addressName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.addressDeleteCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: colors.error),
          child: Text(l10n.addressDeleteConfirm),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
