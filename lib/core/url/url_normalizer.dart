/// Pure URL normalization — no I/O, no side-effects.
///
/// Responsibilities:
/// 1. Scheme normalisation (`http` → `https`)
/// 2. Host normalisation (lowercase, strip `www.`, `m.`, `mobile.`)
/// 3. Tracking-parameter removal (utm_*, fbclid, gclid, …)
/// 4. Fragment removal
/// 5. Trailing-slash normalisation
/// 6. Percent-encoding normalisation (uppercase hex)
///
/// This class is deliberately **not** an interface — it is a pure
/// function bag with no injected dependency.  Tests call it directly.
class UrlNormalizer {
  const UrlNormalizer();

  // ─── Public API ──────────────────────────────────────────────────

  /// Returns a normalised URL string or `null` when [raw] is not a
  /// valid HTTP(S) URL.
  String? normalize(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    try {
      // Step 0: Try to parse.  Reject non-http(s) early.
      final Uri? parsed = _tryParse(trimmed);
      if (parsed == null) return null;

      // Step 1: Scheme → always https.
      const String scheme = 'https';

      // Step 2: Host → lowercase, strip mobile/www prefixes.
      final String host = _normalizeHost(parsed.host);
      if (host.isEmpty) return null;

      // Step 3: Port → drop default ports.
      final String portSuffix = _portSuffix(parsed);

      // Step 4: Path → normalize percent-encoding + trailing slash.
      final String path = _normalizePath(parsed.path);

      // Step 5: Query → remove tracking params, sort remaining.
      final String query = _normalizeQuery(parsed.queryParameters);

      // Step 6: Fragment → always dropped.

      // Re-assemble.
      final StringBuffer buf = StringBuffer()
        ..write(scheme)
        ..write('://')
        ..write(host)
        ..write(portSuffix)
        ..write(path);

      if (query.isNotEmpty) {
        buf
          ..write('?')
          ..write(query);
      }

      return buf.toString();
    } on FormatException {
      return null;
    }
  }

  /// Extracts just the normalised host from [raw], or `null`.
  String? extractNormalizedHost(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    try {
      final Uri? parsed = _tryParse(trimmed);
      if (parsed == null) return null;

      final String host = _normalizeHost(parsed.host);
      return host.isEmpty ? null : host;
    } on FormatException {
      return null;
    }
  }

  // ─── Internals ───────────────────────────────────────────────────

  Uri? _tryParse(String raw) {
    // Prepend scheme if the user typed a bare "example.com/path".
    String input = raw;
    if (!input.startsWith(RegExp('https?://', caseSensitive: false))) {
      // Reject if it already has a non-http scheme (ftp://, mailto:, etc.)
      if (input.contains('://')) return null;
      // Only prepend if it looks like a domain.
      if (!input.contains('.')) return null;
      input = 'https://$input';
    }

    final Uri? uri = Uri.tryParse(input);
    if (uri == null || !uri.hasAuthority) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return uri;
  }

  String _normalizeHost(String host) {
    String h = host.toLowerCase();
    // Strip leading "www.", "m.", "mobile." prefixes.
    for (final String prefix in _hostPrefixes) {
      if (h.startsWith(prefix)) {
        h = h.substring(prefix.length);
        break; // only strip one prefix layer
      }
    }
    return h;
  }

  String _portSuffix(Uri uri) {
    if (!uri.hasPort) return '';
    if (uri.port == 80 || uri.port == 443) return '';
    return ':${uri.port}';
  }

  String _normalizePath(String path) {
    if (path.isEmpty || path == '/') return '/';

    // Normalize percent-encoding: decode unreserved chars, uppercase
    // remaining hex digits.
    final String decoded = _collapseAmpPath(Uri.decodeFull(path));
    final String reEncoded = Uri.encodeFull(decoded);

    // Remove trailing slash for non-root paths.
    if (reEncoded.endsWith('/') && reEncoded.length > 1) {
      return reEncoded.substring(0, reEncoded.length - 1);
    }
    return reEncoded;
  }

  String _collapseAmpPath(String path) {
    if (path.isEmpty || path == '/') return path;
    String candidate = path;
    if (candidate.endsWith('/') && candidate.length > 1) {
      candidate = candidate.substring(0, candidate.length - 1);
    }
    final List<String> segments = candidate.split('/');
    if (segments.length > 2 && segments[1].toLowerCase() == 'amp') {
      return '/${segments.skip(2).join('/')}';
    }
    if (segments.length > 2 && segments.last.toLowerCase() == 'amp') {
      return segments.take(segments.length - 1).join('/');
    }
    return candidate;
  }

  String _normalizeQuery(Map<String, String> params) {
    if (params.isEmpty) return '';

    final List<MapEntry<String, String>> kept = params.entries
        .where((MapEntry<String, String> e) => !_isTrackingParam(e.key))
        .toList()
      ..sort((MapEntry<String, String> a, MapEntry<String, String> b) =>
          a.key.compareTo(b.key));

    if (kept.isEmpty) return '';

    return kept
        .map(
            (MapEntry<String, String> e) => '${Uri.encodeQueryComponent(e.key)}'
                '=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
  }

  bool _isTrackingParam(String key) {
    final String lower = key.toLowerCase();
    return _trackingParams.contains(lower) ||
        lower.startsWith('utm_') ||
        lower.startsWith('_branch');
  }

  // ─── Constants ───────────────────────────────────────────────────

  static const List<String> _hostPrefixes = <String>[
    'www.',
    'mobile.',
    'm.',
  ];

  /// Exhaustive set of known tracking query parameters.
  /// Keeping `utm_*` as a prefix check above — these are the
  /// non-utm trackers.
  static const Set<String> _trackingParams = <String>{
    'fbclid',
    'gclid',
    'dclid',
    'igshid',
    'igsh',
    'si',
    'ref',
    'ref_src',
    'feature',
    'spm',
    'mkt_tok',
    'mc_cid',
    'mc_eid',
    'camp',
    'source',
    '_branch_match_id',
    '_branch_referrer',
    'yclid',
    'msclkid',
    'twclid',
    'ttclid',
    's_kwcid',
    'wickedid',
    'gdf',
    'nb_klid',
    '_openstat',
    'pk_campaign',
    'pk_kwd',
    'pk_source',
    'pk_medium',
    'pk_content',
    'hsa_cam',
    'hsa_grp',
    'hsa_mt',
    'hsa_src',
    'hsa_ad',
    'hsa_acc',
    'hsa_net',
    'hsa_ver',
    'hsa_la',
    'hsa_ol',
    'hsa_kw',
    'hsa_tgt',
  };
}
