/// Extracts a platform-specific content identifier from a URL.
///
/// Used to collapse "different URL, same content" duplicates during
/// capture.  For example, the same YouTube video can arrive as:
/// - `https://youtube.com/watch?v=dQw4w9WgXcQ`
/// - `https://youtu.be/dQw4w9WgXcQ`
/// - `https://m.youtube.com/watch?v=dQw4w9WgXcQ`
///
/// All three produce the same content ID: `youtube:dQw4w9WgXcQ`.
///
/// Pure function — no I/O.
class ExternalContentIdExtractor {
  const ExternalContentIdExtractor();

  /// Returns `platform:id` or `null` when the URL doesn't match any
  /// known pattern.
  String? extract(String normalizedUrl) {
    final Uri? uri = Uri.tryParse(normalizedUrl);
    if (uri == null) return null;

    final String host = uri.host.toLowerCase();
    final String path = uri.path;

    // ── YouTube ──────────────────────────────────────────────────
    final String? ytId = _extractYouTubeId(host, path, uri.queryParameters);
    if (ytId != null) return 'youtube:$ytId';

    // ── Reddit ───────────────────────────────────────────────────
    final String? redditId = _extractRedditId(host, path);
    if (redditId != null) return 'reddit:$redditId';

    // ── Twitter / X ──────────────────────────────────────────────
    final String? tweetId = _extractTweetId(host, path);
    if (tweetId != null) return 'tweet:$tweetId';

    // ── GitHub ───────────────────────────────────────────────────
    final String? ghId = _extractGitHubId(host, path);
    if (ghId != null) return 'github:$ghId';

    return null;
  }

  // ─── YouTube ──────────────────────────────────────────────────

  String? _extractYouTubeId(
    String host,
    String path,
    Map<String, String> query,
  ) {
    // youtu.be/<id>
    if (host == 'youtu.be') {
      final String id = path.replaceFirst('/', '');
      return id.isNotEmpty ? id : null;
    }

    // youtube.com (or music.youtube.com)
    if (host == 'youtube.com' || host == 'music.youtube.com') {
      // /watch?v=<id>
      final String? v = query['v'];
      if (v != null && v.isNotEmpty) return v;

      // /shorts/<id> or /embed/<id> or /v/<id>
      final RegExpMatch? match =
          RegExp('^/(shorts|embed|v)/([A-Za-z0-9_-]+)').firstMatch(path);
      if (match != null) return match.group(2);
    }

    return null;
  }

  // ─── Reddit ───────────────────────────────────────────────────

  String? _extractRedditId(String host, String path) {
    if (host != 'reddit.com' && host != 'old.reddit.com') return null;

    // /r/<subreddit>/comments/<id>/...
    final RegExpMatch? match =
        RegExp('^/r/[^/]+/comments/([A-Za-z0-9]+)').firstMatch(path);
    return match?.group(1);
  }

  // ─── Twitter / X ──────────────────────────────────────────────

  String? _extractTweetId(String host, String path) {
    if (host != 'twitter.com' && host != 'x.com') return null;

    // /<user>/status/<id>
    final RegExpMatch? match = RegExp(r'^/[^/]+/status/(\d+)').firstMatch(path);
    return match?.group(1);
  }

  // ─── GitHub ───────────────────────────────────────────────────

  String? _extractGitHubId(String host, String path) {
    if (host != 'github.com') return null;

    // /owner/repo(/issues/<n> | /pull/<n> | /commit/<sha>)?
    final RegExpMatch? issueMatch =
        RegExp(r'^/([^/]+)/([^/]+)/issues/(\d+)').firstMatch(path);
    if (issueMatch != null) {
      return '${issueMatch.group(1)}/${issueMatch.group(2)}#${issueMatch.group(3)}';
    }

    final RegExpMatch? prMatch =
        RegExp(r'^/([^/]+)/([^/]+)/pull/(\d+)').firstMatch(path);
    if (prMatch != null) {
      return '${prMatch.group(1)}/${prMatch.group(2)}!${prMatch.group(3)}';
    }

    // Plain repo: /owner/repo
    final RegExpMatch? repoMatch =
        RegExp(r'^/([^/]+)/([^/]+)/?$').firstMatch(path);
    if (repoMatch != null) {
      return '${repoMatch.group(1)}/${repoMatch.group(2)}';
    }

    return null;
  }
}
