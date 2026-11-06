import 'package:flutter/material.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';

/// Unified error-state layout.
///
/// Same visual grammar as [MarkyEmptyState] — short serif headline,
/// supporting body, optional retry CTA — but tinted with the danger
/// colour and defaulting to a "Retry" label.
///
/// Technical details ([detail]) are hidden behind a disclosure toggle
/// so power users can grab a stack trace for bug reports without
/// normal users seeing a wall of text.
class MarkyErrorState extends StatefulWidget {
  const MarkyErrorState({
    required this.title,
    required this.body,
    this.detail,
    this.retryLabel,
    this.onRetry,
    super.key,
  });

  final String title;
  final String body;
  final String? detail;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  State<MarkyErrorState> createState() => _MarkyErrorStateState();
}

class _MarkyErrorStateState extends State<MarkyErrorState> {
  bool _detailExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(ReadingRoomSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 360,
                minHeight: constraints.maxHeight.isFinite
                    ? constraints.maxHeight - ReadingRoomSpacing.xl * 2
                    : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.error_outline_rounded,
                    size: 28,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: ReadingRoomSpacing.lg),
                  Text(
                    widget.title,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ReadingRoomSpacing.sm),
                  Text(
                    widget.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.onRetry != null) ...<Widget>[
                    const SizedBox(height: ReadingRoomSpacing.xl),
                    OutlinedButton.icon(
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(widget.retryLabel ?? 'Retry'),
                    ),
                  ],
                  if (widget.detail != null) ...<Widget>[
                    const SizedBox(height: ReadingRoomSpacing.lg),
                    TextButton(
                      onPressed: () => setState(
                        () => _detailExpanded = !_detailExpanded,
                      ),
                      child: Text(
                        _detailExpanded ? 'Hide details' : 'Show details',
                      ),
                    ),
                    if (_detailExpanded)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          top: ReadingRoomSpacing.sm,
                        ),
                        padding: const EdgeInsets.all(ReadingRoomSpacing.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          border: Border.all(color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(
                            ReadingRoomRadii.chip,
                          ),
                        ),
                        child: SelectableText(
                          widget.detail!,
                          style: theme.textTheme.bodySmall,
                        ),
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
