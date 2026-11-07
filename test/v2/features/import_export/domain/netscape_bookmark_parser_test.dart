import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/import_export/domain/netscape_bookmark_parser.dart';

void main() {
  group('NetscapeBookmarkParser', () {
    const NetscapeBookmarkParser parser = NetscapeBookmarkParser();

    test('parses empty or blank input returning empty list', () {
      expect(parser.parse(''), isEmpty);
      expect(parser.parse('   '), isEmpty);
    });

    test('parses standard Netscape bookmark file with folders and tags', () {
      const String html = '''
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
    <DT><H3 ADD_DATE="1600000000">Development</H3>
    <DL><p>
        <DT><A HREF="https://flutter.dev" ADD_DATE="1609459200" TAGS="flutter,dart">Flutter - Build apps</A>
        <DT><A HREF="https://dart.dev" ADD_DATE="1609459200">Dart Programming Language</A>
    </DL><p>
    <DT><A HREF="https://news.ycombinator.com" ADD_DATE="1609459300" TAGS="tech,news">Hacker News</A>
</DL><p>
''';

      final List<NetscapeBookmarkEntry> entries = parser.parse(html);
      expect(entries.length, 3);

      final NetscapeBookmarkEntry first = entries[0];
      expect(first.url, 'https://flutter.dev');
      expect(first.title, 'Flutter - Build apps');
      expect(first.folder, 'Development');
      expect(first.tags, <String>['flutter', 'dart']);
      expect(first.createdAt, DateTime.fromMillisecondsSinceEpoch(1609459200 * 1000));

      final NetscapeBookmarkEntry second = entries[1];
      expect(second.url, 'https://dart.dev');
      expect(second.folder, 'Development');
      expect(second.tags, isEmpty);

      final NetscapeBookmarkEntry third = entries[2];
      expect(third.url, 'https://news.ycombinator.com');
      expect(third.folder, isNull);
      expect(third.tags, <String>['tech', 'news']);
    });

    test('fallbacks to flat query selector if hierarchical dl/dt structure is absent', () {
      const String html = '''
<html>
  <body>
    <p>Saved links:</p>
    <a href="https://example.com/one">Example One</a>
    <a href="https://example.com/two">Example Two</a>
  </body>
</html>
''';

      final List<NetscapeBookmarkEntry> entries = parser.parse(html);
      expect(entries.length, 2);
      expect(entries[0].url, 'https://example.com/one');
      expect(entries[0].title, 'Example One');
      expect(entries[1].url, 'https://example.com/two');
      expect(entries[1].title, 'Example Two');
    });
  });
}
