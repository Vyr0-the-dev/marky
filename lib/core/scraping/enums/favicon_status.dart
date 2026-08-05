/// Lifecycle states for the favicon download and cache process.
///
/// Each bookmark item transitions through these states as its favicon
/// is downloaded and cached locally.
enum FaviconStatus {
  /// Initial state — favicon download has been requested but not started.
  pending,

  /// Favicon is actively being downloaded or processed.
  processing,

  /// Favicon successfully downloaded and cached.
  done,

  /// Download or processing encountered an unrecoverable error.
  failed,
}
