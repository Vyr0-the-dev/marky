import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Generates a deterministic SHA-256 hash for a normalised URL.
///
/// The hash is used as the fast-path dedupe key during capture:
/// `BookmarkEntity.urlHash` is indexed, so a single get-by-hash
/// replaces a full-text canonical-URL scan.
///
/// Pure function — no state, no I/O.
class UrlHasher {
  const UrlHasher();

  /// Returns a lowercase hex-encoded SHA-256 hash of [normalizedUrl].
  ///
  /// Caller **must** pass the already-normalised URL (output of
  /// [UrlNormalizer.normalize]) to guarantee determinism. Passing
  /// the raw user-typed URL defeats the purpose.
  String hash(String normalizedUrl) {
    final List<int> bytes = utf8.encode(normalizedUrl);
    return sha256.convert(bytes).toString();
  }
}
