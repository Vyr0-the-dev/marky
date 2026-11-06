import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/import_export/data/services/bookmark_html_parser.dart';
import 'package:marky/features/import_export/domain/models/import_result.dart';
import 'package:marky/features/import_export/domain/models/parsed_bookmark.dart';

void main() {
  const BookmarkHtmlParser parser = BookmarkHtmlParser();

  group('BookmarkHtmlParser', () {
    test('returns empty list for empty string', () {
      final List<ParsedBookmark> result = parser.parse('');
      expect(result, isEmpty);
    });

    test('returns empty list for whitespace-only string', () {
      final List<ParsedBookmark> result = parser.parse('   \n\t  ');
      expect(result, isEmpty);
    });

    test('returns empty list for HTML with no bookmarks', () {
      const String html = '<html><body><h1>No bookmarks here</h1></body></html>';
      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, isEmpty);
    });

    test('parses a single flat bookmark', () {
      const String html = '''
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
    <DT><A HREF="https://flutter.dev" ADD_DATE="1609459200">Flutter</A>
</DL><p>
''';    

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(1));
      expect(result.first.url, 'https://flutter.dev');
      expect(result.first.title, 'Flutter');
      expect(result.first.addDate, DateTime.fromMillisecondsSinceEpoch(1609459200 * 1000));
      expect(result.first.folderPath, isEmpty);
    });

    test('parses multiple flat bookmarks', () {
      const String html = '''
<DL><p>
    <DT><A HREF="https://a.com" ADD_DATE="1">A</A>
    <DT><A HREF="https://b.com" ADD_DATE="2">B</A>
    <DT><A HREF="https://c.com" ADD_DATE="3">C</A>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(3));
      expect(result[0].url, 'https://a.com');
      expect(result[1].url, 'https://b.com');
      expect(result[2].url, 'https://c.com');
    });

    test('parses bookmarks inside a single folder', () {
      const String html = '''
<DL><p>
    <DT><H3 ADD_DATE="1609459200">Dev</H3>
    <DL><p>
        <DT><A HREF="https://flutter.dev" ADD_DATE="1609459201">Flutter</A>
        <DT><A HREF="https://dart.dev" ADD_DATE="1609459202">Dart</A>
    </DL><p>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(2));
      expect(result.first.folderPath, <String>['Dev']);
      expect(result.first.title, 'Flutter');
      expect(result[1].folderPath, <String>['Dev']);
      expect(result[1].title, 'Dart');
    });

    test('parses nested folders', () {
      const String html = '''
<DL><p>
    <DT><H3 ADD_DATE="1">Languages</H3>
    <DL><p>
        <DT><H3 ADD_DATE="2">Mobile</H3>
        <DL><p>
            <DT><A HREF="https://flutter.dev" ADD_DATE="3">Flutter</A>
        </DL><p>
    </DL><p>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(1));
      expect(result.first.folderPath, <String>['Languages', 'Mobile']);
    });

    test('handles bookmarks outside any folder', () {
      const String html = '''
<DL><p>
    <DT><A HREF="https://root.com" ADD_DATE="1">Root</A>
    <DT><H3 ADD_DATE="2">Folder</H3>
    <DL><p>
        <DT><A HREF="https://inside.com" ADD_DATE="3">Inside</A>
    </DL><p>
    <DT><A HREF="https://root2.com" ADD_DATE="4">Root 2</A>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(3));
      expect(result[0].folderPath, isEmpty);
      expect(result[0].title, 'Root');
      expect(result[1].folderPath, <String>['Folder']);
      expect(result[1].title, 'Inside');
      expect(result[2].folderPath, isEmpty);
      expect(result[2].title, 'Root 2');
    });

    test('handles missing titles', () {
      const String html = '''
<DL><p>
    <DT><A HREF="https://notitle.com" ADD_DATE="1"></A>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(1));
      expect(result.first.url, 'https://notitle.com');
      expect(result.first.title, isNull);
    });

    test('handles missing ADD_DATE', () {
      const String html = '''
<DL><p>
    <DT><A HREF="https://nodate.com">No Date</A>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(1));
      expect(result.first.addDate, isNull);
      expect(result.first.title, 'No Date');
    });

    test('handles invalid ADD_DATE gracefully', () {
      const String html = '''
<DL><p>
    <DT><A HREF="https://bad.com" ADD_DATE="not-a-number">Bad Date</A>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(1));
      expect(result.first.addDate, isNull);
    });

    test('skips bookmarks with empty or missing HREF', () {
      const String html = '''
<DL><p>
    <DT><A HREF="" ADD_DATE="1">Empty HREF</A>
    <DT><A ADD_DATE="2">Missing HREF</A>
    <DT><A HREF="https://valid.com" ADD_DATE="3">Valid</A>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(1));
      expect(result.first.url, 'https://valid.com');
    });

    test('handles deeply nested folders (>10 levels)', () {
      final StringBuffer html = StringBuffer('<DL><p>');
      for (int i = 0; i < 12; i++) {
        html.writeln('<DT><H3 ADD_DATE="$i">Level$i</H3>');
        html.writeln('<DL><p>');
      }
      html.writeln('<DT><A HREF="https://deep.com" ADD_DATE="99">Deep</A>');
      for (int i = 0; i < 12; i++) {
        html.writeln('</DL><p>');
      }

      final List<ParsedBookmark> result = parser.parse(html.toString());
      expect(result, hasLength(1));
      expect(
        result.first.folderPath,
        List<String>.generate(12, (int i) => 'Level$i'),
      );
    });

    test('handles empty folder names', () {
      const String html = '''
<DL><p>
    <DT><H3 ADD_DATE="1"></H3>
    <DL><p>
        <DT><A HREF="https://in-empty.com" ADD_DATE="2">In Empty</A>
    </DL><p>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(1));
      expect(result.first.folderPath, <String>['']);
    });

    test('handles unclosed tags gracefully', () {
      const String html = '''
<DL><p>
    <DT><H3 ADD_DATE="1">Folder</H3>
    <DL><p>
        <DT><A HREF="https://a.com" ADD_DATE="2">A
        <DT><A HREF="https://b.com" ADD_DATE="3">B</A>
    </DL><p>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(2));
      expect(result[0].url, 'https://a.com');
      expect(result[1].url, 'https://b.com');
    });

    test('handles missing DL closings', () {
      const String html = '''
<DL><p>
    <DT><H3 ADD_DATE="1">Folder</H3>
    <DL><p>
        <DT><A HREF="https://a.com" ADD_DATE="2">A</A>
    <!-- missing </DL> -->
<!-- missing </DL> -->
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(1));
      expect(result.first.folderPath, <String>['Folder']);
    });

    test('captures invalid HREF values as strings', () {
      const String html = '''
<DL><p>
    <DT><A HREF="javascript:void(0)" ADD_DATE="1">JS</A>
    <DT><A HREF="about:blank" ADD_DATE="2">About</A>
    <DT><A HREF="not-a-url" ADD_DATE="3">Bad</A>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(3));
      expect(result[0].url, 'javascript:void(0)');
      expect(result[1].url, 'about:blank');
      expect(result[2].url, 'not-a-url');
    });

    test('parses Chrome-style export', () {
      const String html = '''
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
    <DT><H3 ADD_DATE="1609459200" LAST_MODIFIED="1609459200">Bookmarks Bar</H3>
    <DL><p>
        <DT><A HREF="https://github.com" ADD_DATE="1609459201" ICON="...">GitHub</A>
        <DT><A HREF="https://stackoverflow.com" ADD_DATE="1609459202" ICON="...">Stack Overflow</A>
    </DL><p>
    <DT><H3 ADD_DATE="1609459200" LAST_MODIFIED="1609459200">Other Bookmarks</H3>
    <DL><p>
        <DT><A HREF="https://news.ycombinator.com" ADD_DATE="1609459203">Hacker News</A>
    </DL><p>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(3));
      expect(result[0].url, 'https://github.com');
      expect(result[0].folderPath, <String>['Bookmarks Bar']);
      expect(result[1].url, 'https://stackoverflow.com');
      expect(result[1].folderPath, <String>['Bookmarks Bar']);
      expect(result[2].url, 'https://news.ycombinator.com');
      expect(result[2].folderPath, <String>['Other Bookmarks']);
    });

    test('parses Firefox-style export', () {
      const String html = '''
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks Menu</H1>
<DL><p>
    <DT><H3 ADD_DATE="1609459200" LAST_MODIFIED="1609459200" PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Toolbar</H3>
    <DL><p>
        <DT><A HREF="https://mozilla.org" ADD_DATE="1609459201" LAST_MODIFIED="1609459201">Mozilla</A>
    </DL><p>
    <DT><H3 ADD_DATE="1609459200" LAST_MODIFIED="1609459200">Dev</H3>
    <DL><p>
        <DT><A HREF="https://developer.mozilla.org" ADD_DATE="1609459202" LAST_MODIFIED="1609459202" ICON_URI="...">MDN</A>
    </DL><p>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(2));
      expect(result[0].url, 'https://mozilla.org');
      expect(result[0].folderPath, <String>['Bookmarks Toolbar']);
      expect(result[1].url, 'https://developer.mozilla.org');
      expect(result[1].folderPath, <String>['Dev']);
    });

    test('handles malformed HTML without crashing', () {
      const String html = '<<<>>>not html<<<>>>><A HREF="x">y</A>';
      final List<ParsedBookmark> result = parser.parse(html);
      // The html package is lenient and may still extract the anchor.
      expect(result, isNotNull);
    });

    test('produces unmodifiable folderPath lists', () {
      const String html = '''
<DL><p>
    <DT><H3 ADD_DATE="1">Folder</H3>
    <DL><p>
        <DT><A HREF="https://a.com" ADD_DATE="2">A</A>
    </DL><p>
</DL><p>
''';

      final List<ParsedBookmark> result = parser.parse(html);
      expect(result, hasLength(1));
      expect(
        () => result.first.folderPath.add('mutated'),
        throwsUnsupportedError,
      );
    });

    test('ParsedBookmark equality works', () {
      const ParsedBookmark a = ParsedBookmark(
        url: 'https://a.com',
        title: 'A',
        folderPath: <String>['F'],
      );
      const ParsedBookmark b = ParsedBookmark(
        url: 'https://a.com',
        title: 'A',
        folderPath: <String>['F'],
      );
      const ParsedBookmark c = ParsedBookmark(
        url: 'https://b.com',
        title: 'A',
        folderPath: <String>['F'],
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('ImportResult equality works', () {
      const ImportResult a = ImportResult(
        totalFound: 10,
        imported: 5,
        duplicatesSkipped: 3,
        failed: 2,
        failureReasons: <String>['err'],
        elapsed: Duration(seconds: 1),
      );
      const ImportResult b = ImportResult(
        totalFound: 10,
        imported: 5,
        duplicatesSkipped: 3,
        failed: 2,
        failureReasons: <String>['err'],
        elapsed: Duration(seconds: 1),
      );
      const ImportResult c = ImportResult(
        totalFound: 10,
        imported: 5,
        duplicatesSkipped: 3,
        failed: 2,
        failureReasons: <String>['err'],
        elapsed: Duration(seconds: 2),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}
