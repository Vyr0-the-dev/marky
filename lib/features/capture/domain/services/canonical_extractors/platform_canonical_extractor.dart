import 'package:marky/features/capture/domain/services/canonical_extractors/canonical_extraction_result.dart';

/// Pure Dart extractor that pattern-matches URLs for known platforms and
/// returns a canonical URL + external content ID.
///
/// No network calls. Returns `null` for unknown platforms or malformed input.
class PlatformCanonicalExtractor {
  PlatformCanonicalExtractor._();

  static final PlatformCanonicalExtractor instance =
      PlatformCanonicalExtractor._();

  /// Attempts to extract a canonical URL and content ID from [rawUrl].
  ///
  /// Returns `null` if the URL does not match any known platform pattern
  /// or if the input is empty/malformed.
  CanonicalExtractionResult? extract(String rawUrl) {
    if (rawUrl.isEmpty) return null;

    Uri? uri;
    try {
      uri = Uri.parse(rawUrl.trim());
    } on FormatException {
      return null;
    }

    // Ensure scheme is present for host extraction.
    if (!uri.hasScheme) {
      try {
        uri = Uri.parse('https://${rawUrl.trim()}');
      } on FormatException {
        return null;
      }
    }

    final String host = uri.host.toLowerCase();

    // ---- YouTube ----
    final CanonicalExtractionResult? youtube = _extractYouTube(uri, host);
    if (youtube != null) return youtube;

    // ---- X / Twitter ----
    final CanonicalExtractionResult? x = _extractX(uri, host);
    if (x != null) return x;

    // ---- Reddit ----
    final CanonicalExtractionResult? reddit = _extractReddit(uri, host);
    if (reddit != null) return reddit;

    // ---- Amazon ----
    final CanonicalExtractionResult? amazon = _extractAmazon(uri, host);
    if (amazon != null) return amazon;

    // ---- Medium ----
    final CanonicalExtractionResult? medium = _extractMedium(uri, host);
    if (medium != null) return medium;

    // ---- Spotify ----
    final CanonicalExtractionResult? spotify = _extractSpotify(uri, host);
    if (spotify != null) return spotify;

    // ---- Instagram ----
    final CanonicalExtractionResult? instagram = _extractInstagram(uri, host);
    if (instagram != null) return instagram;

    return null;
  }

  // --------------------------------------------------------------------------
  // YouTube
  // --------------------------------------------------------------------------
  CanonicalExtractionResult? _extractYouTube(Uri uri, String host) {
    final bool isYouTube = host == 'youtube.com' ||
        host == 'www.youtube.com' ||
        host == 'm.youtube.com' ||
        host == 'music.youtube.com' ||
        host == 'youtu.be';
    if (!isYouTube) return null;

    // youtu.be/ID
    if (host == 'youtu.be') {
      final String id = _cleanId(uri.pathSegments.isNotEmpty
          ? uri.pathSegments.first
          : '');
      if (id.isEmpty) return null;
      return CanonicalExtractionResult(
        canonicalUrl: 'https://www.youtube.com/watch?v=$id',
        externalContentId: id,
      );
    }

    final List<String> segs = uri.pathSegments;

    // youtube.com/shorts/ID
    if (segs.length >= 2 &&
        segs[0].toLowerCase() == 'shorts') {
      final String id = _cleanId(segs[1]);
      if (id.isEmpty) return null;
      return CanonicalExtractionResult(
        canonicalUrl: 'https://www.youtube.com/shorts/$id',
        externalContentId: id,
      );
    }

    // youtube.com/playlist?list=ID
    if (segs.isNotEmpty &&
        segs[0].toLowerCase() == 'playlist') {
      final String? listId = uri.queryParameters['list'];
      if (listId == null || listId.isEmpty) return null;
      final String id = _cleanId(listId);
      return CanonicalExtractionResult(
        canonicalUrl: 'https://www.youtube.com/playlist?list=$id',
        externalContentId: id,
      );
    }

    // youtube.com/watch?v=ID
    final String? v = uri.queryParameters['v'];
    if (v != null && v.isNotEmpty) {
      final String id = _cleanId(v);
      return CanonicalExtractionResult(
        canonicalUrl: 'https://www.youtube.com/watch?v=$id',
        externalContentId: id,
      );
    }

    return null;
  }

  // --------------------------------------------------------------------------
  // X / Twitter
  // --------------------------------------------------------------------------
  CanonicalExtractionResult? _extractX(Uri uri, String host) {
    final bool isX = host == 'x.com' ||
        host == 'www.x.com' ||
        host == 'twitter.com' ||
        host == 'www.twitter.com' ||
        host == 'mobile.twitter.com';
    if (!isX) return null;

    final List<String> segs = uri.pathSegments;
    if (segs.length < 2) return null;

    // Look for a numeric tweet ID in the path.
    // Common patterns:
    //   /username/status/1234567890
    //   /i/web/status/1234567890
    for (int i = 0; i < segs.length - 1; i++) {
      final String segment = segs[i].toLowerCase();
      if (segment == 'status' || segment == 'statuses') {
        final String id = _cleanId(segs[i + 1]);
        if (_isNumericId(id)) {
          return CanonicalExtractionResult(
            canonicalUrl: 'https://x.com/i/web/status/$id',
            externalContentId: id,
          );
        }
      }
    }

    // Direct /i/web/status/ID
    if (segs.length >= 3 &&
        segs[0].toLowerCase() == 'i' &&
        segs[1].toLowerCase() == 'web' &&
        segs[2].toLowerCase() == 'status') {
      if (segs.length >= 4) {
        final String id = _cleanId(segs[3]);
        if (_isNumericId(id)) {
          return CanonicalExtractionResult(
            canonicalUrl: 'https://x.com/i/web/status/$id',
            externalContentId: id,
          );
        }
      }
    }

    return null;
  }

  // --------------------------------------------------------------------------
  // Reddit
  // --------------------------------------------------------------------------
  CanonicalExtractionResult? _extractReddit(Uri uri, String host) {
    final bool isReddit = host == 'reddit.com' ||
        host == 'www.reddit.com' ||
        host == 'old.reddit.com' ||
        host == 'new.reddit.com' ||
        host == 'redd.it';
    if (!isReddit) return null;

    // redd.it/ID
    if (host == 'redd.it') {
      final String id = _cleanId(uri.pathSegments.isNotEmpty
          ? uri.pathSegments.first
          : '');
      if (id.isEmpty) return null;
      return CanonicalExtractionResult(
        canonicalUrl: 'https://www.reddit.com/comments/$id',
        externalContentId: id,
      );
    }

    final List<String> segs = uri.pathSegments;

    // /r/subreddit/comments/ID/...
    for (int i = 0; i < segs.length - 1; i++) {
      if (segs[i].toLowerCase() == 'comments') {
        final String id = _cleanId(segs[i + 1]);
        if (id.isNotEmpty) {
          return CanonicalExtractionResult(
            canonicalUrl: 'https://www.reddit.com/comments/$id',
            externalContentId: id,
          );
        }
      }
    }

    return null;
  }

  // --------------------------------------------------------------------------
  // Amazon
  // --------------------------------------------------------------------------
  CanonicalExtractionResult? _extractAmazon(Uri uri, String host) {
    final bool isAmazon = host == 'amazon.com' ||
        host == 'www.amazon.com' ||
        host == 'amazon.co.uk' ||
        host == 'www.amazon.co.uk' ||
        host == 'amazon.de' ||
        host == 'www.amazon.de' ||
        host == 'amazon.fr' ||
        host == 'www.amazon.fr' ||
        host == 'amazon.ca' ||
        host == 'www.amazon.ca' ||
        host == 'amazon.co.jp' ||
        host == 'www.amazon.co.jp' ||
        host == 'amazon.in' ||
        host == 'www.amazon.in' ||
        host == 'amazon.es' ||
        host == 'www.amazon.es' ||
        host == 'amazon.it' ||
        host == 'www.amazon.it' ||
        host == 'amazon.com.br' ||
        host == 'www.amazon.com.br' ||
        host == 'amazon.com.mx' ||
        host == 'www.amazon.com.mx' ||
        host == 'amazon.nl' ||
        host == 'www.amazon.nl' ||
        host == 'amazon.com.au' ||
        host == 'www.amazon.com.au' ||
        host == 'amazon.ae' ||
        host == 'www.amazon.ae' ||
        host == 'amazon.sa' ||
        host == 'www.amazon.sa' ||
        host == 'amazon.sg' ||
        host == 'www.amazon.sg' ||
        host == 'amazon.se' ||
        host == 'www.amazon.se' ||
        host == 'amazon.pl' ||
        host == 'www.amazon.pl' ||
        host == 'amazon.com.tr' ||
        host == 'www.amazon.com.tr';
    if (!isAmazon) return null;

    final String path = uri.path;

    // /dp/ASIN
    String? asin = _extractAmazonAsin(path, '/dp/([A-Z0-9]{10})');
    // /gp/product/ASIN
    asin ??= _extractAmazonAsin(path, '/gp/product/([A-Z0-9]{10})');
    // /gp/aw/d/ASIN
    asin ??= _extractAmazonAsin(path, '/gp/aw/d/([A-Z0-9]{10})');

    if (asin == null || asin.isEmpty) return null;

    return CanonicalExtractionResult(
      canonicalUrl: 'https://www.amazon.com/dp/$asin',
      externalContentId: asin,
    );
  }

  String? _extractAmazonAsin(String path, String pattern) {
    final RegExp regex = RegExp(pattern, caseSensitive: false);
    final RegExpMatch? match = regex.firstMatch(path);
    return match?.group(1);
  }

  // --------------------------------------------------------------------------
  // Medium
  // --------------------------------------------------------------------------
  CanonicalExtractionResult? _extractMedium(Uri uri, String host) {
    final bool isMedium = host == 'medium.com' ||
        host == 'www.medium.com' ||
        host.endsWith('.medium.com');
    if (!isMedium) return null;

    final List<String> segs = uri.pathSegments;

    // medium.com/@user/post-id
    if (segs.length >= 2 && segs[0].startsWith('@')) {
      final String id = _cleanId(segs.last);
      if (id.isEmpty) return null;
      return CanonicalExtractionResult(
        canonicalUrl: 'https://${uri.host}/${segs[0]}/$id',
        externalContentId: id,
      );
    }

    // medium.com/p/post-id
    if (segs.length >= 2 && segs[0].toLowerCase() == 'p') {
      final String id = _cleanId(segs[1]);
      if (id.isEmpty) return null;
      return CanonicalExtractionResult(
        canonicalUrl: 'https://${uri.host}/p/$id',
        externalContentId: id,
      );
    }

    return null;
  }

  // --------------------------------------------------------------------------
  // Spotify
  // --------------------------------------------------------------------------
  CanonicalExtractionResult? _extractSpotify(Uri uri, String host) {
    final bool isSpotify = host == 'open.spotify.com' ||
        host == 'www.open.spotify.com';
    if (!isSpotify) return null;

    final List<String> segs = uri.pathSegments;
    if (segs.length < 2) return null;

    final String type = segs[0].toLowerCase();
    if (type != 'track' &&
        type != 'album' &&
        type != 'playlist' &&
        type != 'episode' &&
        type != 'show') {
      return null;
    }

    final String id = _cleanId(segs[1]);
    if (id.isEmpty) return null;

    return CanonicalExtractionResult(
      canonicalUrl: 'https://open.spotify.com/$type/$id',
      externalContentId: id,
    );
  }

  // --------------------------------------------------------------------------
  // Instagram
  // --------------------------------------------------------------------------
  CanonicalExtractionResult? _extractInstagram(Uri uri, String host) {
    final bool isInstagram = host == 'instagram.com' ||
        host == 'www.instagram.com';
    if (!isInstagram) return null;

    final List<String> segs = uri.pathSegments;
    if (segs.length < 2) return null;

    final String type = segs[0].toLowerCase();
    if (type != 'p' && type != 'reel' && type != 'reels') return null;

    final String id = _cleanId(segs[1]);
    if (id.isEmpty) return null;

    final String normalizedType = type == 'reels' ? 'reel' : type;

    return CanonicalExtractionResult(
      canonicalUrl: 'https://www.instagram.com/$normalizedType/$id',
      externalContentId: id,
    );
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  /// Removes trailing slashes and query fragments from an extracted ID segment.
  String _cleanId(String raw) {
    return raw.split('/').first.split('?').first.split('#').first.trim();
  }

  /// Returns true if [id] consists solely of digits.
  bool _isNumericId(String id) {
    return id.isNotEmpty && id.runes.every((int r) => r >= 48 && r <= 57);
  }
}
