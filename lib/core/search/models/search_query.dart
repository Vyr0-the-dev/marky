import 'package:equatable/equatable.dart';

/// Immutable representation of a parsed search query.
///
/// Free-text tokens are collected into [freeText].
/// Structured operators (e.g. `tag:foo`) are stored in [operators]
/// as a map from operator key to list of values.
class SearchQuery extends Equatable {
  const SearchQuery({
    this.freeText = const <String>[],
    this.operators = const <String, List<String>>{},
  });

  /// Unstructured free-text tokens entered by the user.
  final List<String> freeText;

  /// Structured operators parsed from the query.
  ///
  /// Keys are normalized to lowercase (e.g. `'tag'`, `'is'`).
  /// Values are lists because the same operator may appear multiple
  /// times (e.g. `tag:foo tag:bar`).
  final Map<String, List<String>> operators;

  /// Whether this query contains no free-text and no operators.
  bool get isEmpty => freeText.isEmpty && operators.isEmpty;

  /// Whether this query has at least one free-text token or operator.
  bool get isNotEmpty => !isEmpty;

  /// Returns the values for a given operator key, or an empty list
  /// if the operator is absent.
  List<String> operatorValues(String key) {
    final normalized = key.toLowerCase();
    return operators[normalized] ?? const <String>[];
  }

  /// Whether the query contains the given operator key.
  bool hasOperator(String key) => operators.containsKey(key.toLowerCase());

  /// Creates a copy of this [SearchQuery] with the given fields replaced.
  SearchQuery copyWith({
    List<String>? freeText,
    Map<String, List<String>>? operators,
  }) {
    return SearchQuery(
      freeText: freeText ?? this.freeText,
      operators: operators ?? this.operators,
    );
  }

  @override
  List<Object?> get props => <Object?>[freeText, operators];
}
