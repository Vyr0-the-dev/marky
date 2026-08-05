/// Lifecycle states for the thumbnail download and cache process.
///
/// Each bookmark item transitions through these states as its thumbnail
/// is downloaded, cached locally, and processed for dominant color extraction.
enum ThumbnailStatus {
  /// Initial state — thumbnail download has been requested but not started.
  pending,

  /// Thumbnail is actively being downloaded or processed.
  processing,

  /// Thumbnail successfully downloaded, cached, and color extracted.
  done,

  /// Download or processing encountered an unrecoverable error.
  failed,
}
