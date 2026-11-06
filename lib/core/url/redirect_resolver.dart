/// Resolves redirect chains (bit.ly, t.co, youtu.be, etc.) to the
/// final destination URL.
///
/// Interface so capture tests can use a no-network fake.
abstract interface class RedirectResolver {
  /// Follows the redirect chain from [url] and returns the final
  /// destination URL.
  ///
  /// Returns [url] unchanged when:
  /// - The URL does not redirect (HTTP 200 on first try).
  /// - The network is unreachable.
  /// - The chain exceeds [maxRedirects].
  /// - Any hop times out.
  ///
  /// **Never** throws — capture must not crash when the network is
  /// down.  The caller gets the best URL available and continues.
  Future<String> resolve(String url);
}
