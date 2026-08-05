import 'package:meta/meta.dart';

/// Immutable value object representing the result of AI keyword extraction
/// and category assignment.
///
/// All fields are non-null with sensible defaults to simplify downstream
/// consumers. An empty keywords list and null category are valid states
/// when the source bookmark has insufficient text.
@immutable
class KeywordExtractionResult {
  const KeywordExtractionResult({
    required this.keywords,
    this.category,
  });

  /// Extracted keywords sorted by relevance (descending frequency).
  final List<String> keywords;

  /// Suggested category derived from domain mapping or content type.
  final String? category;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeywordExtractionResult &&
          other.runtimeType == runtimeType &&
          other.category == category &&
          _listEquals(other.keywords, keywords);

  @override
  int get hashCode => Object.hash(
        category,
        Object.hashAll(keywords),
      );

  @override
  String toString() =>
      'KeywordExtractionResult(keywords: $keywords, category: $category)';
}

/// Local helper for deep list equality.
bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
