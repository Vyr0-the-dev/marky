import 'package:flutter/foundation.dart';

import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/capture/domain/duplicate_check_result.dart';

/// The outcome of a single capture attempt.
///
/// Every code path through the capture pipeline must produce exactly
/// one [CaptureResult] — the UI maps this to a snackbar / sheet:
///
/// | status           | user-facing meaning                        |
/// |------------------|--------------------------------------------|
/// | [saved]          | New bookmark created.                      |
/// | [duplicate]      | Already saved — shows existing bookmark.   |
/// | [invalidUrl]     | The input is not a valid HTTP(S) URL.       |
/// | [error]          | An unexpected error (I/O, DB) occurred.     |
@immutable
class CaptureResult {
  const CaptureResult._({
    required this.status,
    this.bookmark,
    this.duplicateMatchLevel,
    this.errorMessage,
  });

  // ─── Factories ─────────────────────────────────────────────────

  /// A brand-new bookmark was persisted successfully.
  factory CaptureResult.saved(Bookmark bookmark) => CaptureResult._(
        status: CaptureStatus.saved,
        bookmark: bookmark,
      );

  /// The URL was already in the library.  [bookmark] is the
  /// existing row; [matchLevel] explains how the match was found.
  factory CaptureResult.duplicate(
    Bookmark existing,
    DuplicateMatchLevel matchLevel,
  ) =>
      CaptureResult._(
        status: CaptureStatus.duplicate,
        bookmark: existing,
        duplicateMatchLevel: matchLevel,
      );

  /// The raw input could not be parsed into a valid URL.
  const CaptureResult.invalidUrl()
      : status = CaptureStatus.invalidUrl,
        bookmark = null,
        duplicateMatchLevel = null,
        errorMessage = null;

  /// An unexpected runtime error.  [message] is a developer-facing
  /// diagnostic — the UI should show a generic string to the user.
  factory CaptureResult.error(String message) => CaptureResult._(
        status: CaptureStatus.error,
        errorMessage: message,
      );

  // ─── Fields ────────────────────────────────────────────────────

  final CaptureStatus status;

  /// The bookmark that was created or already existed.
  /// Non-null for [saved] and [duplicate]; null for [invalidUrl]
  /// and [error].
  final Bookmark? bookmark;

  /// Present only when [status] == [CaptureStatus.duplicate].
  final DuplicateMatchLevel? duplicateMatchLevel;

  /// Developer diagnostic for [error] status.
  final String? errorMessage;

  /// Convenience — true when the capture produced a new row.
  bool get isSaved => status == CaptureStatus.saved;

  @override
  String toString() => 'CaptureResult($status, '
      'bookmark: ${bookmark?.id}, '
      'match: $duplicateMatchLevel, '
      'error: $errorMessage)';
}

/// Top-level outcome of a capture attempt.
enum CaptureStatus {
  saved,
  duplicate,
  invalidUrl,
  error,
}
