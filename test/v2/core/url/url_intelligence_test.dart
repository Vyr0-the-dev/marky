import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/url/content_type_detector.dart';
import 'package:marky/core/url/external_content_id_extractor.dart';
import 'package:marky/core/url/url_hasher.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════
  //  UrlHasher
  // ═══════════════════════════════════════════════════════════════

  group('UrlHasher', () {
    const UrlHasher hasher = UrlHasher();

    test('produces 64-char lowercase hex SHA-256', () {
      final String h = hasher.hash('https://example.com/page');
      expect(h.length, 64);
      expect(h, matches(RegExp(r'^[a-f0-9]{64}$')));
    });

    test('same input produces same hash', () {
      const String url = 'https://youtube.com/watch?v=abc';
      expect(hasher.hash(url), hasher.hash(url));
    });

    test('different input produces different hash', () {
      expect(
        hasher.hash('https://example.com/a'),
        isNot(hasher.hash('https://example.com/b')),
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  //  ContentTypeDetector
  // ═══════════════════════════════════════════════════════════════

  group('ContentTypeDetector', () {
    const ContentTypeDetector detector = ContentTypeDetector();

    test('YouTube → video', () {
      expect(
        detector.detect('https://youtube.com/watch?v=abc'),
        BookmarkContentType.video,
      );
    });

    test('youtu.be → video', () {
      expect(
        detector.detect('https://youtu.be/abc'),
        BookmarkContentType.video,
      );
    });

    test('Vimeo → video', () {
      expect(
        detector.detect('https://vimeo.com/12345'),
        BookmarkContentType.video,
      );
    });

    test('Twitch → video', () {
      expect(
        detector.detect('https://twitch.tv/channel'),
        BookmarkContentType.video,
      );
    });

    test('Reddit → discussion', () {
      expect(
        detector.detect('https://reddit.com/r/flutter/comments/abc/title'),
        BookmarkContentType.discussion,
      );
    });

    test('Twitter → discussion', () {
      expect(
        detector.detect('https://twitter.com/user/status/123'),
        BookmarkContentType.discussion,
      );
    });

    test('x.com → discussion', () {
      expect(
        detector.detect('https://x.com/user/status/123'),
        BookmarkContentType.discussion,
      );
    });

    test('Hacker News → discussion', () {
      expect(
        detector.detect('https://news.ycombinator.com/item?id=123'),
        BookmarkContentType.discussion,
      );
    });

    test('GitHub → code', () {
      expect(
        detector.detect('https://github.com/flutter/flutter'),
        BookmarkContentType.code,
      );
    });

    test('StackOverflow → code', () {
      expect(
        detector.detect('https://stackoverflow.com/questions/123'),
        BookmarkContentType.code,
      );
    });

    test('pub.dev → code', () {
      expect(
        detector.detect('https://pub.dev/packages/riverpod'),
        BookmarkContentType.code,
      );
    });

    test('Spotify → audio', () {
      expect(
        detector.detect('https://open.spotify.com/track/abc'),
        BookmarkContentType.audio,
      );
    });

    test('Amazon → product', () {
      expect(
        detector.detect('https://amazon.com/dp/B08N5WRWNW'),
        BookmarkContentType.product,
      );
    });

    test('direct .jpg → image', () {
      expect(
        detector.detect('https://example.com/photo.jpg'),
        BookmarkContentType.image,
      );
    });

    test('direct .png → image', () {
      expect(
        detector.detect('https://example.com/image.png'),
        BookmarkContentType.image,
      );
    });

    test('.pdf → document', () {
      expect(
        detector.detect('https://example.com/paper.pdf'),
        BookmarkContentType.document,
      );
    });

    test('Imgur → image', () {
      expect(
        detector.detect('https://imgur.com/a/abc123'),
        BookmarkContentType.image,
      );
    });

    test('unknown domain → unknown', () {
      expect(
        detector.detect('https://example.com/some-article'),
        BookmarkContentType.unknown,
      );
    });

    test('music.youtube.com → video (not audio)', () {
      // music.youtube.com is under _videoHosts currently
      expect(
        detector.detect('https://music.youtube.com/watch?v=abc'),
        BookmarkContentType.video,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  //  ExternalContentIdExtractor
  // ═══════════════════════════════════════════════════════════════

  group('ExternalContentIdExtractor', () {
    const ExternalContentIdExtractor extractor = ExternalContentIdExtractor();

    // ── YouTube ──────────────────────────────────────────────────

    test('YouTube /watch?v= extracts video id', () {
      expect(
        extractor.extract('https://youtube.com/watch?v=dQw4w9WgXcQ'),
        'youtube:dQw4w9WgXcQ',
      );
    });

    test('youtu.be short link extracts video id', () {
      expect(
        extractor.extract('https://youtu.be/dQw4w9WgXcQ'),
        'youtube:dQw4w9WgXcQ',
      );
    });

    test('YouTube /shorts/ extracts video id', () {
      expect(
        extractor.extract('https://youtube.com/shorts/abc123'),
        'youtube:abc123',
      );
    });

    test('YouTube /embed/ extracts video id', () {
      expect(
        extractor.extract('https://youtube.com/embed/abc123'),
        'youtube:abc123',
      );
    });

    test('music.youtube.com /watch?v= extracts video id', () {
      expect(
        extractor.extract('https://music.youtube.com/watch?v=abc123'),
        'youtube:abc123',
      );
    });

    // ── Reddit ───────────────────────────────────────────────────

    test('Reddit post extracts post id', () {
      expect(
        extractor.extract(
          'https://reddit.com/r/flutter/comments/abc123/my_post',
        ),
        'reddit:abc123',
      );
    });

    test('old.reddit.com extracts post id', () {
      expect(
        extractor.extract(
          'https://old.reddit.com/r/dart/comments/xyz789/title',
        ),
        'reddit:xyz789',
      );
    });

    test('Reddit home page returns null', () {
      expect(
        extractor.extract('https://reddit.com/'),
        isNull,
      );
    });

    // ── Twitter / X ──────────────────────────────────────────────

    test('Twitter status extracts tweet id', () {
      expect(
        extractor.extract('https://twitter.com/user/status/1234567890'),
        'tweet:1234567890',
      );
    });

    test('x.com status extracts tweet id', () {
      expect(
        extractor.extract('https://x.com/elonmusk/status/9876543210'),
        'tweet:9876543210',
      );
    });

    test('Twitter profile returns null', () {
      expect(
        extractor.extract('https://twitter.com/user'),
        isNull,
      );
    });

    // ── GitHub ───────────────────────────────────────────────────

    test('GitHub repo extracts owner/repo', () {
      expect(
        extractor.extract('https://github.com/flutter/flutter'),
        'github:flutter/flutter',
      );
    });

    test('GitHub issue extracts owner/repo#number', () {
      expect(
        extractor.extract('https://github.com/flutter/flutter/issues/12345'),
        'github:flutter/flutter#12345',
      );
    });

    test('GitHub PR extracts owner/repo!number', () {
      expect(
        extractor.extract('https://github.com/flutter/flutter/pull/999'),
        'github:flutter/flutter!999',
      );
    });

    // ── Unknown ──────────────────────────────────────────────────

    test('unknown domain returns null', () {
      expect(
        extractor.extract('https://example.com/page'),
        isNull,
      );
    });
  });
}
