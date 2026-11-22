import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/storage/cache_management_service.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/capture/domain/bulk_metadata_refetch_service.dart';
import 'package:marky/features/dashboard/data/dashboard_providers.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Launches a cancellable progress dialog for refetching metadata on
/// [bookmarkIds], invalidates storage/dashboard counters when done, and
/// displays a concise result SnackBar.
Future<BulkRefetchResult?> runBulkMetadataRefetchWithDialog({
  required BuildContext context,
  required WidgetRef ref,
  required List<int> bookmarkIds,
}) async {
  if (bookmarkIds.isEmpty || !context.mounted) return null;

  final BulkRefetchResult? result = await showDialog<BulkRefetchResult>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => _BulkRefetchProgressDialog(
      bookmarkIds: bookmarkIds,
    ),
  );

  ref.invalidate(cacheSizeBytesProvider);
  ref.invalidate(dashboardStatsProvider);

  if (result == null || !context.mounted) return result;

  final AppLocalizations? l10n = AppLocalizations.of(context);
  final String summary = result.cancelled
      ? (l10n?.bulkRefetchCancelledSummary(
            result.succeeded,
            result.processed,
          ) ??
          'Stopped — updated ${result.succeeded} of ${result.processed} checked bookmarks.')
      : (l10n?.bulkRefetchSummary(result.succeeded, result.total) ??
          'Updated metadata for ${result.succeeded} of ${result.total} bookmarks.');

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(summary)));

  return result;
}

/// Scans the library for bookmarks with incomplete metadata, asks the user to
/// confirm the discovered count, and runs [runBulkMetadataRefetchWithDialog].
Future<void> runIncompleteLibraryRefetchFlow({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final AppLocalizations? l10n = AppLocalizations.of(context);
  final BulkMetadataRefetchService service =
      ref.read(bulkMetadataRefetchServiceProvider);

  bool scanDialogOpen = false;
  late final List<int> incompleteIds;
  try {
    if (context.mounted) {
      scanDialogOpen = true;
      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => PopScope(
            canPop: false,
            child: AlertDialog(
              content: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(width: ReadingRoomSpacing.lg),
                  Expanded(
                    child: Text(
                      l10n?.bulkRefetchScanning ?? 'Scanning library…',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    incompleteIds = await service.findIncompleteBookmarkIds();
  } finally {
    if (scanDialogOpen && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  if (!context.mounted) return;
  if (incompleteIds.isEmpty) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n?.bulkRefetchAllComplete ??
                'All bookmarks already have complete metadata.',
          ),
        ),
      );
    return;
  }

  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(
        l10n?.bulkRefetchConfirmTitle ?? 'Complete missing metadata?',
      ),
      content: Text(
        l10n?.bulkRefetchConfirmBody(incompleteIds.length) ??
            '${incompleteIds.length} bookmarks are missing covers, summaries, '
                'or titles. Your existing titles, tags, and notes will not be '
                'overwritten.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n?.actionCancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n?.bulkRefetchStartAction ?? 'Start'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  await runBulkMetadataRefetchWithDialog(
    context: context,
    ref: ref,
    bookmarkIds: incompleteIds,
  );
}

class _BulkRefetchProgressDialog extends ConsumerStatefulWidget {
  const _BulkRefetchProgressDialog({required this.bookmarkIds});

  final List<int> bookmarkIds;

  @override
  ConsumerState<_BulkRefetchProgressDialog> createState() =>
      _BulkRefetchProgressDialogState();
}

class _BulkRefetchProgressDialogState
    extends ConsumerState<_BulkRefetchProgressDialog> {
  final BulkRefetchCancellationToken _cancelToken =
      BulkRefetchCancellationToken();
  late BulkRefetchProgress _progress = BulkRefetchProgress(
    total: widget.bookmarkIds.length,
    processed: 0,
    succeeded: 0,
    failed: 0,
  );
  bool _stopping = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final BulkMetadataRefetchService service =
        ref.read(bulkMetadataRefetchServiceProvider);
    final BulkRefetchResult result = await service.runBatch(
      bookmarkIds: widget.bookmarkIds,
      cancelToken: _cancelToken,
      onProgress: (BulkRefetchProgress progress) {
        if (!mounted) return;
        setState(() {
          _progress = progress;
        });
      },
    );
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  void _stop() {
    if (_stopping) return;
    setState(() {
      _stopping = true;
    });
    _cancelToken.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l10n?.bulkRefetchTitle ?? 'Refetching metadata'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _progress.currentHost ?? '…',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ReadingRoomTextStyles.metadata(context),
                  ),
                ),
                const SizedBox(width: ReadingRoomSpacing.sm),
                Text(
                  l10n?.bulkRefetchProgressLabel(
                        _progress.processed,
                        _progress.total,
                      ) ??
                      '${_progress.processed} / ${_progress.total}',
                  style: ReadingRoomTextStyles.metadata(context).copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(ReadingRoomRadii.chip),
              child: LinearProgressIndicator(
                value: _progress.total > 0 ? _progress.fraction : null,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.sm),
            Text(
              l10n?.bulkRefetchStatsLabel(
                    _progress.succeeded,
                    _progress.failed,
                  ) ??
                  '${_progress.succeeded} updated · ${_progress.failed} unchanged',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _stopping ? null : _stop,
            child: Text(l10n?.bulkRefetchStopAction ?? 'Stop'),
          ),
        ],
      ),
    );
  }
}
