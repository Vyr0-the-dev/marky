/* Browser bookmark export fixtures for integration testing.
 *
 * All fixtures follow the Netscape Bookmark File Format
 * (https://wiki.mozilla.org/Bookmarks/Firemarks).
 */

/// Chrome-style export with nested folders and metadata attributes.
const String kChromeExportHtml = '''
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
        <DT><A HREF="https://github.com" ADD_DATE="1609459201" ICON="data:image/png;base64,iVBORw0KGgo=">GitHub</A>
        <DT><A HREF="https://stackoverflow.com" ADD_DATE="1609459202" ICON="data:image/png;base64,iVBORw0KGgo=">Stack Overflow</A>
    </DL><p>
    <DT><H3 ADD_DATE="1609459200" LAST_MODIFIED="1609459200">Other Bookmarks</H3>
    <DL><p>
        <DT><A HREF="https://news.ycombinator.com" ADD_DATE="1609459203">Hacker News</A>
        <DT><H3 ADD_DATE="1609459204" LAST_MODIFIED="1609459204">Nested Folder</H3>
        <DL><p>
            <DT><A HREF="https://flutter.dev" ADD_DATE="1609459205">Flutter</A>
        </DL><p>
    </DL><p>
</DL><p>
''';

/// Firefox-style export with PERSONAL_TOOLBAR_FOLDER and ICON_URI attributes.
const String kFirefoxExportHtml = '''
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
        <DT><A HREF="https://mozilla.org" ADD_DATE="1609459201" LAST_MODIFIED="1609459201" ICON_URI="fake-icon-uri">Mozilla</A>
    </DL><p>
    <DT><H3 ADD_DATE="1609459200" LAST_MODIFIED="1609459200">Dev</H3>
    <DL><p>
        <DT><A HREF="https://developer.mozilla.org" ADD_DATE="1609459202" LAST_MODIFIED="1609459202" ICON_URI="fake-icon-uri">MDN Web Docs</A>
        <DT><A HREF="https://pub.dev" ADD_DATE="1609459203" LAST_MODIFIED="1609459203">Dart Packages</A>
    </DL><p>
    <DT><H3 ADD_DATE="1609459200" LAST_MODIFIED="1609459200">News &amp; Blogs</H3>
    <DL><p>
        <DT><A HREF="https://reddit.com" ADD_DATE="1609459204">Reddit</A>
    </DL><p>
</DL><p>
''';

/// Malformed HTML with unclosed tags and broken structure.
const String kMalformedHtml = '''
<DL><p>
    <DT><H3 ADD_DATE="1">Broken Folder
    <DL><p>
        <DT><A HREF="https://a.com" ADD_DATE="2">A
        <DT><A HREF="https://b.com" ADD_DATE="3">B</A>
    <!-- missing </DL> -->
<!-- missing </DL> -->
''';

/// Empty bookmarks file (doctype but no bookmarks).
const String kEmptyBookmarksHtml = '''
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
</DL><p>
''';

/// HTML with no bookmark structure at all.
const String kNoBookmarksHtml = '<html><body><h1>No bookmarks here</h1></body></html>';

/// Large batch fixture: 50 flat bookmarks for stress testing.
String generateLargeBatchHtml({int count = 50}) {
  final StringBuffer buffer = StringBuffer('<DL><p>\n');
  for (int i = 0; i < count; i++) {
    buffer.writeln(
      '    <DT><A HREF="https://example.com/$i" ADD_DATE="${1609459200 + i}">Bookmark $i</A>',
    );
  }
  buffer.writeln('</DL><p>');
  return buffer.toString();
}

/// Fixture with special characters in folder names that need slugification.
const String kSpecialCharsFolderHtml = '''
<DL><p>
    <DT><H3 ADD_DATE="1">Dev &amp; Tools</H3>
    <DL><p>
        <DT><A HREF="https://github.com" ADD_DATE="2">GitHub</A>
    </DL><p>
    <DT><H3 ADD_DATE="3">News — Hot!</H3>
    <DL><p>
        <DT><A HREF="https://news.ycombinator.com" ADD_DATE="4">HN</A>
    </DL><p>
    <DT><H3 ADD_DATE="5">   Spaces   </H3>
    <DL><p>
        <DT><A HREF="https://example.com" ADD_DATE="6">Example</A>
    </DL><p>
</DL><p>
''';
