import 'package:equatable/equatable.dart';

/// Immutable representation of a single bookmark parsed from a browser
/// export HTML file (Netscape Bookmark File Format).
class ParsedBookmark extends Equatable {
  const ParsedBookmark({
    required this.url,
    this.title,
    this.addDate,
    this.folderPath = const <String>[],
  });

  /// The bookmark URL (raw string from the `HREF` attribute).
  final String url;

  /// The bookmark title (text content of the `<A>` element).
  final String? title;

  /// The parsed `ADD_DATE` timestamp, if present and valid.
  final DateTime? addDate;

  /// The folder hierarchy path, from root to leaf.
  /// Empty when the bookmark sits outside any folder.
  final List<String> folderPath;

  @override
  List<Object?> get props => <Object?>[url, title, addDate, folderPath];
}
