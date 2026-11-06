import 'package:isar/isar.dart';

part 'search_query_entity.g.dart';

@Collection(accessor: 'searchQueries')
class SearchQueryEntity {
  SearchQueryEntity({
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

  Id id = Isar.autoIncrement;

  String query;

  @Index(unique: true, caseSensitive: false)
  String normalizedQuery;

  String? label;

  @Index()
  bool isRecent;

  @Index()
  bool isSaved;

  int useCount;

  DateTime createdAt;

  @Index()
  DateTime lastUsedAt;

  DateTime? savedAt;
}
