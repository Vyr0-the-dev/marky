import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/features/capture/domain/capture_result.dart';

/// The public capture boundary.
///
/// Feature code (manual-add screen, share-intent handler, clipboard
/// monitor) calls [capture] with a raw string; everything else is
/// internal.  The caller does **not** need to normalise, hash, or
/// dedupe — this service owns the full pipeline.
abstract interface class CaptureService {
  /// Runs the full capture pipeline for [rawInput]:
  ///
  /// 1. Validate & normalise the URL.
  /// 2. Compute the URL hash and extract content metadata.
  /// 3. Check for duplicates.
  /// 4. If new, persist the bookmark.
  /// 5. Return a [CaptureResult] describing the outcome.
  ///
  /// [sourceType] indicates how the URL arrived (manual entry,
  /// share sheet, clipboard).  It is written on the created
  /// bookmark for analytics and automation.
  Future<CaptureResult> capture(
    String rawInput, {
    BookmarkSourceType sourceType = BookmarkSourceType.manual,
  });

  /// Like [capture], but accepts arbitrary text (share payload,
  /// clipboard contents) that may contain one or more URLs mixed
  /// with regular text.
  ///
  /// Extracts the first URL from [text] and runs the capture pipeline.
  /// Returns [CaptureResult.invalidUrl] when no URL is found.
  Future<CaptureResult> captureFromText(
    String text, {
    BookmarkSourceType sourceType = BookmarkSourceType.share,
  });

  /// Captures all URLs found in [text]. Returns one [CaptureResult]
  /// per extracted URL. Empty list when no URLs are found.
  Future<List<CaptureResult>> captureAllFromText(
    String text, {
    BookmarkSourceType sourceType = BookmarkSourceType.share,
  });
}
