import 'package:marky/core/database/enums/bookmark_content_type.dart';

/// Detects the [BookmarkContentType] from a normalised URL.
///
/// Pure function — no I/O.  Uses host- and path-pattern matching
/// only; does **not** fetch the URL.  The scraper may later upgrade
/// the content type once it has OG metadata.
class ContentTypeDetector {
  const ContentTypeDetector();

  /// Returns the best-guess content type for [normalizedUrl].
  ///
  /// Falls back to [BookmarkContentType.unknown] when the URL doesn't
  /// match any known pattern.
  BookmarkContentType detect(String normalizedUrl) {
    final Uri? uri = Uri.tryParse(normalizedUrl);
    if (uri == null) return BookmarkContentType.unknown;

    final String host = uri.host.toLowerCase();
    final String path = uri.path.toLowerCase();

    // ── Video platforms ──────────────────────────────────────────
    if (_matchesHost(host, _videoHosts) || _isDirectVideo(path)) {
      return BookmarkContentType.video;
    }

    // ── Discussion platforms ─────────────────────────────────────
    if (_matchesHost(host, _discussionHosts)) {
      return BookmarkContentType.discussion;
    }

    // ── Code platforms ───────────────────────────────────────────
    if (_matchesHost(host, _codeHosts)) return BookmarkContentType.code;

    // ── Audio platforms ──────────────────────────────────────────
    if (_matchesHost(host, _audioHosts)) return BookmarkContentType.audio;

    // ── Product / e-commerce platforms ───────────────────────────
    if (_matchesHost(host, _productHosts)) return BookmarkContentType.product;

    // ── Direct image URLs ────────────────────────────────────────
    if (_isDirectImage(path)) return BookmarkContentType.image;

    // ── Document URLs ────────────────────────────────────────────
    if (_isDocument(path)) return BookmarkContentType.document;

    // ── Image hosting platforms ──────────────────────────────────
    if (_matchesHost(host, _imageHosts)) return BookmarkContentType.image;

    return BookmarkContentType.unknown;
  }

  // ─── Internal helpers ──────────────────────────────────────────

  bool _matchesHost(String host, List<String> patterns) {
    for (final String pattern in patterns) {
      if (host == pattern || host.endsWith('.$pattern')) return true;
    }
    return false;
  }

  bool _isDirectVideo(String path) {
    return path.endsWith('.mp4') ||
        path.endsWith('.webm') ||
        path.endsWith('.m3u8') ||
        path.endsWith('.mov') ||
        path.endsWith('.mkv');
  }

  bool _isDirectImage(String path) {
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.gif') ||
        path.endsWith('.webp') ||
        path.endsWith('.svg') ||
        path.endsWith('.bmp');
  }

  bool _isDocument(String path) {
    return path.endsWith('.pdf') ||
        path.endsWith('.doc') ||
        path.endsWith('.docx') ||
        path.endsWith('.pptx') ||
        path.endsWith('.xlsx');
  }

  // ─── Host patterns ────────────────────────────────────────────

  static const List<String> _videoHosts = <String>[
    'youtube.com',
    'youtu.be',
    'vimeo.com',
    'twitch.tv',
    'dailymotion.com',
    'streamable.com',
    'rumble.com',
    'tiktok.com',
  ];

  static const List<String> _discussionHosts = <String>[
    'reddit.com',
    'old.reddit.com',
    'twitter.com',
    'x.com',
    'nitter.net',
    'news.ycombinator.com',
    'lobste.rs',
    'lemmy.world',
  ];

  static const List<String> _codeHosts = <String>[
    'github.com',
    'gitlab.com',
    'bitbucket.org',
    'codeberg.org',
    'gist.github.com',
    'pub.dev',
    'npmjs.com',
    'crates.io',
    'pypi.org',
    'stackoverflow.com',
  ];

  static const List<String> _audioHosts = <String>[
    'open.spotify.com',
    'soundcloud.com',
    'podcasts.apple.com',
    'music.youtube.com',
    'overcast.fm',
    'pocketcasts.com',
  ];

  static const List<String> _productHosts = <String>[
    'amazon.com',
    'amazon.co.uk',
    'amazon.de',
    'amazon.co.jp',
    'ebay.com',
    'etsy.com',
    'aliexpress.com',
    'shopify.com',
    'trendyol.com',
    'hepsiburada.com',
    'n11.com',
  ];

  static const List<String> _imageHosts = <String>[
    'imgur.com',
    'flickr.com',
    'unsplash.com',
    'pexels.com',
    'giphy.com',
    'deviantart.com',
  ];
}
