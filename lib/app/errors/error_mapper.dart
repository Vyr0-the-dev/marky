import 'package:flutter/material.dart';

import 'package:marky/app/errors/app_exception.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Maps [Object] errors to user-friendly localized messages.
class ErrorMapper {
  ErrorMapper._();

  /// Returns a localized title for the given [error].
  static String titleFor(Object error, BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);

    if (error is NetworkException) {
      return l10n?.errorGenericTitle ?? 'Something went wrong';
    }
    if (error is DatabaseException) {
      return l10n?.errorGenericTitle ?? 'Something went wrong';
    }
    if (error is ScrapingException) {
      return l10n?.errorGenericTitle ?? 'Something went wrong';
    }
    if (error is VaultException) {
      return l10n?.errorGenericTitle ?? 'Something went wrong';
    }

    return l10n?.errorGenericTitle ?? 'Something went wrong';
  }

  /// Returns a localized message body for the given [error].
  static String messageFor(Object error, BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);

    if (error is NetworkException) {
      return l10n?.errorNetworkMessage ?? 'Check your connection and try again.';
    }
    if (error is DatabaseException) {
      return l10n?.errorLoadFeedMessage ?? 'The feed could not be loaded.';
    }
    if (error is ScrapingException) {
      return l10n?.errorNetworkMessage ?? 'Check your connection and try again.';
    }
    if (error is VaultException) {
      return l10n?.errorGenericTitle ?? 'Something went wrong';
    }

    return l10n?.errorNetworkMessage ?? 'Check your connection and try again.';
  }
}
