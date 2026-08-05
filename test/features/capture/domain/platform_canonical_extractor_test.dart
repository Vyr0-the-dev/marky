import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/capture/domain/services/canonical_extractors/platform_canonical_extractor.dart';

void main() {
  late PlatformCanonicalExtractor extractor;

  setUp(() {
    extractor = PlatformCanonicalExtractor.instance;
  });

  group('YouTube', () {
    test('youtu.be short link', () {
      final result = extractor.extract('https://youtu.be/dQw4w9WgXcQ');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
      expect(result.externalContentId, 'dQw4w9WgXcQ');
    });

    test('youtu.be short link with trailing query params', () {
      final result = extractor.extract(
          'https://youtu.be/dQw4w9WgXcQ?si=abc123');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
      expect(result.externalContentId, 'dQw4w9WgXcQ');
    });

    test('youtube.com/watch?v=ID', () {
      final result =
          extractor.extract('https://www.youtube.com/watch?v=abc123DEF45');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.youtube.com/watch?v=abc123DEF45');
      expect(result.externalContentId, 'abc123DEF45');
    });

    test('youtube.com/watch with extra params', () {
      final result = extractor.extract(
          'https://youtube.com/watch?v=abc123&feature=related&t=30s');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.youtube.com/watch?v=abc123');
      expect(result.externalContentId, 'abc123');
    });

    test('youtube.com/shorts/ID', () {
      final result =
          extractor.extract('https://youtube.com/shorts/ShortsId01');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.youtube.com/shorts/ShortsId01');
      expect(result.externalContentId, 'ShortsId01');
    });

    test('m.youtube.com/shorts/ID', () {
      final result =
          extractor.extract('https://m.youtube.com/shorts/ShortsId01');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.youtube.com/shorts/ShortsId01');
      expect(result.externalContentId, 'ShortsId01');
    });

    test('youtube.com/playlist?list=ID', () {
      final result = extractor.extract(
          'https://www.youtube.com/playlist?list=PLabc123def456');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.youtube.com/playlist?list=PLabc123def456');
      expect(result.externalContentId, 'PLabc123def456');
    });

    test('music.youtube.com/watch?v=ID', () {
      final result = extractor.extract(
          'https://music.youtube.com/watch?v=MusicVideo01');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.youtube.com/watch?v=MusicVideo01');
      expect(result.externalContentId, 'MusicVideo01');
    });
  });

  group('X / Twitter', () {
    test('x.com username/status/ID', () {
      final result = extractor.extract(
          'https://x.com/elonmusk/status/1234567890123456789');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://x.com/i/web/status/1234567890123456789');
      expect(result.externalContentId, '1234567890123456789');
    });

    test('twitter.com username/status/ID', () {
      final result = extractor.extract(
          'https://twitter.com/elonmusk/status/9876543210987654321');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://x.com/i/web/status/9876543210987654321');
      expect(result.externalContentId, '9876543210987654321');
    });

    test('mobile.twitter.com username/status/ID', () {
      final result = extractor.extract(
          'https://mobile.twitter.com/nasa/status/1111111111111111111');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://x.com/i/web/status/1111111111111111111');
      expect(result.externalContentId, '1111111111111111111');
    });

    test('x.com/i/web/status/ID', () {
      final result =
          extractor.extract('https://x.com/i/web/status/2222222222222222222');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://x.com/i/web/status/2222222222222222222');
      expect(result.externalContentId, '2222222222222222222');
    });

    test('twitter.com URL without status ID returns null', () {
      final result =
          extractor.extract('https://twitter.com/elonmusk');
      expect(result, isNull);
    });

    test('x.com non-numeric status ID returns null', () {
      final result = extractor.extract(
          'https://x.com/elonmusk/status/abc');
      expect(result, isNull);
    });
  });

  group('Reddit', () {
    test('reddit.com/r/sub/comments/ID/title', () {
      final result = extractor.extract(
          'https://www.reddit.com/r/flutterdev/comments/1abc2def/my_post_title/');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.reddit.com/comments/1abc2def');
      expect(result.externalContentId, '1abc2def');
    });

    test('old.reddit.com/r/sub/comments/ID', () {
      final result = extractor.extract(
          'https://old.reddit.com/r/programming/comments/xyz789ab/');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.reddit.com/comments/xyz789ab');
      expect(result.externalContentId, 'xyz789ab');
    });

    test('redd.it short link', () {
      final result = extractor.extract('https://redd.it/1a2b3c4');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.reddit.com/comments/1a2b3c4');
      expect(result.externalContentId, '1a2b3c4');
    });

    test('reddit.com without comments path returns null', () {
      final result =
          extractor.extract('https://www.reddit.com/r/flutterdev/');
      expect(result, isNull);
    });
  });

  group('Amazon', () {
    test('amazon.com/dp/ASIN', () {
      final result = extractor.extract(
          'https://www.amazon.com/dp/B08N5WRWNW');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.amazon.com/dp/B08N5WRWNW');
      expect(result.externalContentId, 'B08N5WRWNW');
    });

    test('amazon.co.uk/gp/product/ASIN', () {
      final result = extractor.extract(
          'https://www.amazon.co.uk/gp/product/B08N5WRWNW');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.amazon.com/dp/B08N5WRWNW');
      expect(result.externalContentId, 'B08N5WRWNW');
    });

    test('amazon.de/gp/aw/d/ASIN', () {
      final result = extractor.extract(
          'https://www.amazon.de/gp/aw/d/B08N5WRWNW');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.amazon.com/dp/B08N5WRWNW');
      expect(result.externalContentId, 'B08N5WRWNW');
    });

    test('amazon.com without ASIN returns null', () {
      final result =
          extractor.extract('https://www.amazon.com/gp/product/');
      expect(result, isNull);
    });

    test('amazon.com with non-10-char ID returns null', () {
      final result =
          extractor.extract('https://www.amazon.com/dp/ABC123');
      expect(result, isNull);
    });

    test('amazon.fr/dp/ASIN canonicalizes to amazon.com', () {
      final result = extractor.extract(
          'https://www.amazon.fr/dp/B09V3KXJPB');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.amazon.com/dp/B09V3KXJPB');
      expect(result.externalContentId, 'B09V3KXJPB');
    });
  });

  group('Medium', () {
    test('medium.com/@user/post-id', () {
      final result = extractor.extract(
          'https://medium.com/@john_doe/my-awesome-post-123abc');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://medium.com/@john_doe/my-awesome-post-123abc');
      expect(result.externalContentId, 'my-awesome-post-123abc');
    });

    test('medium.com/p/post-id', () {
      final result =
          extractor.extract('https://medium.com/p/abc123-def456');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://medium.com/p/abc123-def456');
      expect(result.externalContentId, 'abc123-def456');
    });

    test('subdomain.medium.com/@user/post-id', () {
      final result = extractor.extract(
          'https://towardsdatascience.medium.com/@alice/ml-article-789');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://towardsdatascience.medium.com/@alice/ml-article-789');
      expect(result.externalContentId, 'ml-article-789');
    });

    test('medium.com without post ID returns null', () {
      final result = extractor.extract('https://medium.com/@john_doe');
      expect(result, isNull);
    });
  });

  group('Spotify', () {
    test('open.spotify.com/track/ID', () {
      final result = extractor.extract(
          'https://open.spotify.com/track/4uLU6hMCjMI75M1A2tKUQC');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://open.spotify.com/track/4uLU6hMCjMI75M1A2tKUQC');
      expect(result.externalContentId, '4uLU6hMCjMI75M1A2tKUQC');
    });

    test('open.spotify.com/album/ID', () {
      final result = extractor.extract(
          'https://open.spotify.com/album/1DFixLWuPkv3KT3TnV35m3');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://open.spotify.com/album/1DFixLWuPkv3KT3TnV35m3');
      expect(result.externalContentId, '1DFixLWuPkv3KT3TnV35m3');
    });

    test('open.spotify.com/playlist/ID', () {
      final result = extractor.extract(
          'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M');
      expect(result.externalContentId, '37i9dQZF1DXcBWIGoYBM5M');
    });

    test('open.spotify.com/episode/ID', () {
      final result = extractor.extract(
          'https://open.spotify.com/episode/5cfLsN6upLm8YYQKUU1V2Q');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://open.spotify.com/episode/5cfLsN6upLm8YYQKUU1V2Q');
      expect(result.externalContentId, '5cfLsN6upLm8YYQKUU1V2Q');
    });

    test('open.spotify.com root returns null', () {
      final result = extractor.extract('https://open.spotify.com/');
      expect(result, isNull);
    });
  });

  group('Instagram', () {
    test('instagram.com/p/ID', () {
      final result = extractor.extract(
          'https://www.instagram.com/p/ABC123xyz/');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.instagram.com/p/ABC123xyz');
      expect(result.externalContentId, 'ABC123xyz');
    });

    test('instagram.com/reel/ID', () {
      final result = extractor.extract(
          'https://www.instagram.com/reel/ReelID99/');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.instagram.com/reel/ReelID99');
      expect(result.externalContentId, 'ReelID99');
    });

    test('instagram.com/reels/ID normalizes to reel', () {
      final result = extractor.extract(
          'https://www.instagram.com/reels/ReelsId1/');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.instagram.com/reel/ReelsId1');
      expect(result.externalContentId, 'ReelsId1');
    });

    test('instagram.com without post path returns null', () {
      final result =
          extractor.extract('https://www.instagram.com/nasa/');
      expect(result, isNull);
    });
  });

  group('Negative cases', () {
    test('empty string returns null', () {
      expect(extractor.extract(''), isNull);
    });

    test('unknown domain returns null', () {
      expect(extractor.extract('https://example.com/page'), isNull);
    });

    test('GitHub URL returns null (must not over-normalize)', () {
      expect(
          extractor.extract(
              'https://github.com/flutter/flutter/pull/123456'),
          isNull);
    });

    test('malformed URL returns null', () {
      expect(extractor.extract('ht!tp://[::1'), isNull);
    });

    test('null input — not applicable in Dart, but empty handled', () {
      // Dart non-nullable strings cannot be null; empty is covered above.
      expect(extractor.extract(''), isNull);
    });
  });

  group('Edge cases', () {
    test('URL with no scheme', () {
      final result =
          extractor.extract('youtu.be/dQw4w9WgXcQ');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
    });

    test('URL with fragment', () {
      final result = extractor.extract(
          'https://youtu.be/dQw4w9WgXcQ#t=30');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
      expect(result.externalContentId, 'dQw4w9WgXcQ');
    });

    test('trailing slash in path segment', () {
      final result = extractor.extract(
          'https://www.youtube.com/shorts/ShortsId01/');
      expect(result, isNotNull);
      expect(result!.externalContentId, 'ShortsId01');
    });

    test('uppercase host', () {
      final result = extractor.extract(
          'https://YOUTU.BE/dQw4w9WgXcQ');
      expect(result, isNotNull);
      expect(result!.canonicalUrl,
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
    });
  });
}
