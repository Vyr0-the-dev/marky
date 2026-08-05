import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/theme/theme.dart';
import 'package:marky/features/import_export/domain/models/import_result.dart';

/// Dialog that displays the progress or result of a bookmark import.
///
/// Shows a circular progress indicator while loading, a success summary
/// on completion, or an error message on failure.
class ImportResultDialog extends StatelessWidget {
  /// Creates the [ImportResultDialog].
  const ImportResultDialog({
    super.key,
    this.result,
    this.error,
    required this.isLoading,
  });

  /// The import result to display. Non-null when the import succeeded.
  final ImportResult? result;

  /// The error to display. Non-null when the import failed.
  final Object? error;

  /// Whether the import is currently in progress.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        _title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280),
        child: _buildContent(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Close',
            style: TextStyle(color: AppColors.accentPrimary),
          ),
        ),
      ],
    );
  }

  String get _title {
    if (isLoading) return 'Importing bookmarks…';
    if (error != null) return 'Import failed';
    return 'Import complete';
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.accentPrimary,
          ),
        ),
      );
    }

    if (error != null) {
      return Text(
        error.toString(),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      );
    }

    final ImportResult r = result!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildRow('Found', r.totalFound),
        _buildRow('Imported', r.imported, color: AppColors.accentPrimary),
        _buildRow('Skipped (duplicates)', r.duplicatesSkipped),
        if (r.failed > 0) _buildRow('Failed', r.failed, color: Colors.redAccent),
        if (r.failureReasons.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              r.failureReasons.take(3).join('\n'),
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildRow(String label, int value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows an [ImportResultDialog] for the given [AsyncValue] state.
///
/// Returns a [Future] that completes when the dialog is dismissed.
Future<void> showImportResultDialog(
  BuildContext context, {
  required AsyncValue<ImportResult?> state,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: !state.isLoading,
    builder: (BuildContext context) {
      return ImportResultDialog(
        result: state.valueOrNull,
        error: state.hasError ? state.error : null,
        isLoading: state.isLoading,
      );
    },
  );
}
