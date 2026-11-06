import 'package:flutter/material.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';

/// Unified empty-state layout for Reading Room.
///
/// Instead of a friendly cartoon illustration, empty states are
/// **typographic** — a short declarative sentence in the library's
/// serif voice, supported by a single body line and at most one call
/// to action. This matches the "quiet library" feel of the app.
class MarkyEmptyState extends StatelessWidget {
  const MarkyEmptyState({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.icon,
    super.key,
  });

  /// Short declarative sentence in the serif voice. No period.
  /// e.g. "Your library is quiet"
  final String title;

  /// One-line explanation of what the user can do next.
  /// e.g. "Share a link or paste one to get started."
  final String body;

  /// Optional CTA label.
  final String? actionLabel;

  /// Optional CTA callback. Required if [actionLabel] is set.
  final VoidCallback? onAction;

  /// Optional decorative icon above the title. Kept small and muted.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight - ReadingRoomSpacing.xl * 2
            : 0;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(ReadingRoomSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 360,
                minHeight: availableHeight < 0 ? 0 : availableHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(
                      icon,
                      size: 28,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: ReadingRoomSpacing.lg),
                  ],
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ReadingRoomSpacing.sm),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (actionLabel != null && onAction != null) ...<Widget>[
                    const SizedBox(height: ReadingRoomSpacing.xl),
                    FilledButton(
                      onPressed: onAction,
                      child: Text(actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
