import 'package:flutter/material.dart';

import 'package:marky/app/errors/error_mapper.dart';
import 'package:marky/l10n/app_localizations.dart';

/// A user-facing fallback widget displayed when a widget crashes.
///
/// Used via [ErrorWidget.builder] to replace the default red-screen
/// with a branded, localized error UI.
class ErrorBoundary extends StatelessWidget {
  /// Creates an [ErrorBoundary].
  const ErrorBoundary({
    super.key,
    this.error,
    this.stackTrace,
    this.onRetry,
  });

  /// The caught error object.
  final Object? error;

  /// The stack trace associated with the error.
  final StackTrace? stackTrace;

  /// Optional callback to retry/rebuild the failed widget.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final String title = error != null
        ? ErrorMapper.titleFor(error!, context)
        : (l10n?.errorGenericTitle ?? 'Something went wrong');

    final String message = error != null
        ? ErrorMapper.messageFor(error!, context)
        : (l10n?.errorNetworkMessage ?? 'Check your connection and try again.');

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...<Widget>[
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n?.actionRetry ?? 'Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
