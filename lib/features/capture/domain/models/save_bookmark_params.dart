/// Immutable value object bundling all parameters that may be supplied
/// when attempting to save a bookmark that could turn into an upsert.
///
/// All fields are nullable so that callers can express "don't touch this
/// field" by leaving it `null`.
class SaveBookmarkParams {
  const SaveBookmarkParams({
    this.rawUrl,
    this.tagIds,
    this.collectionIds,
    this.sharedText,
    this.sourceType,
    this.importSource,
  });

  /// The raw URL as originally captured (e.g. from a share sheet).
  final String? rawUrl;

  /// Tag IDs to attach to the bookmark.
  final List<int>? tagIds;

  /// Collection IDs to attach to the bookmark.
  final List<int>? collectionIds;

  /// Optional text that accompanied the shared link.
  final String? sharedText;

  /// Source classification, e.g. 'manual', 'share_sheet', 'clipboard'.
  final String? sourceType;

  /// Import batch source if this came from an import job.
  final String? importSource;
}
