import 'package:flutter/widgets.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Convenience extension on [BuildContext] to access [AppLocalizations].
extension LocalizationExtension on BuildContext {
  /// Look up the localized string table for the nearest [Localizations] ancestor.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
