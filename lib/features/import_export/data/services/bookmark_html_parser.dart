import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:marky/features/import_export/domain/models/parsed_bookmark.dart';

/// Parses Netscape Bookmark File Format HTML into a list of [ParsedBookmark].
///
/// This parser walks the DOM looking for `<A HREF="...">` elements nested
/// inside `<DL>` structures and tracks the folder hierarchy via `<H3>` tags.
///
/// The parser is defensive: it returns an empty list for empty, malformed,
/// or unparseable input and never throws.
class BookmarkHtmlParser {
  const BookmarkHtmlParser();

  /// Parses [html] and returns all bookmarks found.
  ///
  /// Returns an empty list when:
  /// - [html] is empty or only whitespace
  /// - the HTML cannot be parsed
  /// - no bookmark `<A>` elements are found
  List<ParsedBookmark> parse(String html) {
    if (html.trim().isEmpty) {
      return <ParsedBookmark>[];
    }

    try {
      final Document document = html_parser.parse(html);
      final List<ParsedBookmark> bookmarks = <ParsedBookmark>[];
      final List<String> folderStack = <String>[];

      _walk(document.body, folderStack, bookmarks);

      return bookmarks;
    } on Object {
      return <ParsedBookmark>[];
    }
  }

  void _walk(
    Element? element,
    List<String> folderStack,
    List<ParsedBookmark> out,
  ) {
    if (element == null) {
      return;
    }

    // A <DL> introduces a new scope. Its direct children are <DT> elements
    // that may contain <H3> (folder header) or <A> (bookmark).
    if (element.localName == 'dl') {
      for (final Node child in element.nodes) {
        if (child is! Element) {
          continue;
        }

        if (child.localName == 'dt') {
          _processDt(child, folderStack, out);
        } else if (child.localName == 'dl') {
          // Handle malformed HTML where <DL> may be a direct child of <DL>
          // without an intervening <DT>.
          _walk(child, folderStack, out);
        }
      }
      return;
    }

    // For non-<DL> elements, recurse into children.
    for (final Node child in element.nodes) {
      if (child is Element) {
        _walk(child, folderStack, out);
      }
    }
  }

  void _processDt(
    Element dt,
    List<String> folderStack,
    List<ParsedBookmark> out,
  ) {
    Element? h3;
    Element? dl;
    Element? anchor;

    for (final Node child in dt.nodes) {
      if (child is! Element) {
        continue;
      }

      final String tag = child.localName ?? '';
      if (tag == 'h3') {
        h3 = child;
      } else if (tag == 'dl') {
        dl = child;
      } else if (tag == 'a') {
        anchor = child;
      }
    }

    // Folder header: push name, recurse into its <DL>, then pop.
    if (h3 != null && dl != null) {
      final String folderName = _extractText(h3);
      folderStack.add(folderName);
      _walk(dl, folderStack, out);
      folderStack.removeLast();
      return;
    }

    // Bookmark: extract URL, title, addDate.
    if (anchor != null) {
      final String? href = anchor.attributes['href'];
      if (href == null || href.isEmpty) {
        return;
      }

      final String title = _extractText(anchor);
      final DateTime? addDate = _parseAddDate(anchor.attributes['add_date']);

      out.add(
        ParsedBookmark(
          url: href,
          title: title.isEmpty ? null : title,
          addDate: addDate,
          folderPath: List<String>.unmodifiable(<String>[...folderStack]),
        ),
      );
      return;
    }

    // A <DT> with only a nested <DL> (no <H3>) — recurse defensively.
    if (dl != null) {
      _walk(dl, folderStack, out);
    }
  }

  String _extractText(Element element) {
    return element.text.trim();
  }

  DateTime? _parseAddDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final int? seconds = int.tryParse(raw);
    if (seconds == null) {
      return null;
    }

    try {
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    } on Object {
      return null;
    }
  }
}
