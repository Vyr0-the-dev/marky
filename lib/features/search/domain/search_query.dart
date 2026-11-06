import 'package:flutter/foundation.dart';

@immutable
class SearchQuery {
  const SearchQuery({
    this.id,
    required this.query,
    required this.normalizedQuery,
    this.label,
    this.isRecent = true,
    this.isSaved = false,
    this.useCount = 0,
    required this.createdAt,
    required this.lastUsedAt,
    this.savedAt,
  });

  final int? id;
  final String query;
  final String normalizedQuery;
  final String? label;
  final bool isRecent;
  final bool isSaved;
  final int useCount;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final DateTime? savedAt;

  String get displayLabel =>
      (label?.trim().isNotEmpty ?? false) ? label!.trim() : query;

  SearchQuery copyWith({
    int? id,
    String? query,
    String? normalizedQuery,
    String? label,
    bool? isRecent,
    bool? isSaved,
    int? useCount,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    DateTime? savedAt,
  }) {
    return SearchQuery(
      id: id ?? this.id,
      query: query ?? this.query,
      normalizedQuery: normalizedQuery ?? this.normalizedQuery,
      label: label ?? this.label,
      isRecent: isRecent ?? this.isRecent,
      isSaved: isSaved ?? this.isSaved,
      useCount: useCount ?? this.useCount,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  static String normalize(String query) {
    return query.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchQuery &&
        other.id == id &&
        other.query == query &&
        other.normalizedQuery == normalizedQuery &&
        other.label == label &&
        other.isRecent == isRecent &&
        other.isSaved == isSaved &&
        other.useCount == useCount &&
        other.createdAt == createdAt &&
        other.lastUsedAt == lastUsedAt &&
        other.savedAt == savedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        query,
        normalizedQuery,
        label,
        isRecent,
        isSaved,
        useCount,
        createdAt,
        lastUsedAt,
        savedAt,
      );
}
