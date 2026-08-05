import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Pure Dart service for normalizing URLs and computing canonical hashes.
///
/// Zero Flutter imports — safe to use in isolates or pure Dart contexts.
class UrlNormalizationService {
  UrlNormalizationService._();

  static final UrlNormalizationService instance = UrlNormalizationService._();

  /// Known tracking parameters to strip during normalization.
  static final Set<String> _trackingParams = <String>{
    'fbclid',
    'gclid',
    'dclid',
    'ref',
    'ref_src',
    'source',
    'camp',
    'mc_cid',
    'mc_eid',
    'igshid',
    'igsh',
    'si',
    'feature',
    'spm',
    'mkt_tok',
    '_branch_match_id',
    '_branch_referrer',
  };

  /// Normalizes [raw] into a canonical URL string.
  ///
  /// Steps:
  /// 1. Trim whitespace.
  /// 2. Prepend `https://` if no scheme is present.
  /// 3. Parse the URI.
  /// 4. Lowercase the host.
  /// 5. Strip known tracking query parameters (including `utm_*`).
  /// 6. Rebuild the URI without fragment.
  ///
  /// Returns `null` if the URL cannot be parsed.
  String? normalizeUrl(String raw) {
    String url = raw.trim();
    if (url.isEmpty) {
      return null;
    }

    // Ensure scheme.
    if (!url.contains('://')) {
      url = 'https://$url';
    }

    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    // Lowercase host.
    final String host = uri.host.toLowerCase();

    // Strip tracking params and sort alphabetically for hash stability.
    final Map<String, String> cleanedParams =
        Map<String, String>.from(uri.queryParameters)
          ..removeWhere((String key, String value) {
            final String lowerKey = key.toLowerCase();
            return lowerKey.startsWith('utm_') ||
                _trackingParams.contains(lowerKey);
          });

    final Map<String, String> sortedParams = Map<String, String>.fromEntries(
      cleanedParams.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );

    final Uri canonical = Uri(
      scheme: uri.scheme.toLowerCase(),
      host: host,
      port: uri.hasPort && !_isDefaultPort(uri.scheme, uri.port)
          ? uri.port
          : null,
      path: uri.path,
      queryParameters: sortedParams.isEmpty ? null : sortedParams,
    );

    return canonical.toString();
  }

  /// Computes a SHA-256 hex hash of [canonicalUrl].
  String computeUrlHash(String canonicalUrl) {
    final List<int> bytes = utf8.encode(canonicalUrl);
    final Digest digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _isDefaultPort(String scheme, int port) {
    return (scheme == 'http' && port == 80) ||
        (scheme == 'https' && port == 443);
  }
}
