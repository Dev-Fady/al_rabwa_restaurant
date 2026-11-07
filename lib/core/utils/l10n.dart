import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Convenience accessor for the app's localized strings.
extension L10nBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
