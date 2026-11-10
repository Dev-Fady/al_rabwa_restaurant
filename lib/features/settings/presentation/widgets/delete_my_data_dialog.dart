import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Asks the customer to confirm deleting every piece of data stored for this
/// device. Returns `true` only when the destructive action was confirmed.
Future<bool> showDeleteMyDataDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final colors = Theme.of(context).colorScheme;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(Icons.delete_forever_outlined, size: 30, color: colors.error),
      title: Text(l10n.deleteMyDataConfirmTitle, textAlign: TextAlign.center),
      content: Text(
        l10n.deleteMyDataConfirmMessage,
        textAlign: TextAlign.center,
        style: Theme.of(
          dialogContext,
        ).textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.deleteMyDataCancelAction),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: colors.error),
          child: Text(l10n.deleteMyDataConfirmAction),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
