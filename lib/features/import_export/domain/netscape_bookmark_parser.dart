import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// Represents a single bookmark extracted from an HTML bookmark export
/// (Netscape Bookmark format used by Chrome, Firefox, Safari, Pocket, etc.).
class NetscapeBookmarkEntry {
  const NetscapeBookmarkEntry({
    required this.url,
    required this.title,
    this.folder,
    this.tags = const <String>[],
    this.createdAt,
    this.iconUrl,
  });

  final String url;
  final String title;
  final String? folder;
  final List<String> tags;
  final DateTime? createdAt;
  final String? iconUrl;
}

/// Parses Netscape Bookmark HTML files exported by major web browsers.
class NetscapeBookmarkParser {
  const NetscapeBookmarkParser();

  List<NetscapeBookmarkEntry> parse(String htmlContent) {
    if (htmlContent.trim().isEmpty) return <NetscapeBookmarkEntry>[];

    final dom.Document doc = html_parser.parse(htmlContent);
    final List<NetscapeBookmarkEntry> results = <NetscapeBookmarkEntry>[];

    _traverse(doc.body, currentFolder: null, results: results);

    // Fallback: If strict traversal found nothing, pick up all anchor elements
    if (results.isEmpty) {
      final List<dom.Element> allAnchors = doc.querySelectorAll('a[href]');
      for (final dom.Element a in allAnchors) {
        final String? href = a.attributes['href']?.trim();
        if (href == null || href.isEmpty || !href.startsWith('http')) continue;
        results.add(_entryFromAnchor(a, folder: null));
      }
    }

    return results;
  }

  void _traverse(
    dom.Element? element, {
    required String? currentFolder,
    required List<NetscapeBookmarkEntry> results,
  }) {
    if (element == null) return;

    for (final dom.Node node in element.nodes) {
      if (node is! dom.Element) continue;

      final String tag = node.localName?.toLowerCase() ?? '';

      if (tag == 'dt') {
        final dom.Element? h3 = node.querySelector('h3');
        if (h3 != null) {
          final String folderName = h3.text.trim();
          final String effectiveFolder =
              folderName.isNotEmpty ? folderName : (currentFolder ?? '');
          final dom.Element? dl = node.querySelector('dl') ??
              _findNextSiblingElement(node, 'dl');
          if (dl != null) {
            _traverse(
              dl,
              currentFolder:
                  effectiveFolder.isNotEmpty ? effectiveFolder : null,
              results: results,
            );
          }
          continue;
        }

        final dom.Element? a = node.querySelector('a[href]');
        if (a != null) {
          final String? href = a.attributes['href']?.trim();
          if (href != null && href.isNotEmpty && href.startsWith('http')) {
            results.add(_entryFromAnchor(a, folder: currentFolder));
          }
        }
      } else if (tag == 'dl') {
        _traverse(node, currentFolder: currentFolder, results: results);
      } else if (tag == 'a' && node.attributes.containsKey('href')) {
        final String? href = node.attributes['href']?.trim();
        if (href != null && href.isNotEmpty && href.startsWith('http')) {
          results.add(_entryFromAnchor(node, folder: currentFolder));
        }
      } else {
        _traverse(node, currentFolder: currentFolder, results: results);
      }
    }
  }

  dom.Element? _findNextSiblingElement(dom.Element element, String tag) {
    dom.Element? next = element.nextElementSibling;
    while (next != null) {
      if (next.localName?.toLowerCase() == tag) {
        return next;
      }
      next = next.nextElementSibling;
    }
    return null;
  }

  NetscapeBookmarkEntry _entryFromAnchor(
    dom.Element a, {
    required String? folder,
  }) {
    final String url = a.attributes['href']!.trim();
    final String text = a.text.trim();
    final String title = text.isNotEmpty ? text : url;

    final String? tagsAttr = a.attributes['tags'];
    final List<String> tags = tagsAttr != null && tagsAttr.isNotEmpty
        ? tagsAttr
            .split(',')
            .map((String s) => s.trim())
            .where((String s) => s.isNotEmpty)
            .toList()
        : <String>[];

    DateTime? createdAt;
    final String? addDate = a.attributes['add_date'];
    if (addDate != null && addDate.isNotEmpty) {
      final int? seconds = int.tryParse(addDate);
      if (seconds != null && seconds > 0) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }

    final String? icon = a.attributes['icon'];

    return NetscapeBookmarkEntry(
      url: url,
      title: title,
      folder: folder,
      tags: tags,
      createdAt: createdAt,
      iconUrl: icon,
    );
  }
}
