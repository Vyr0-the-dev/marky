import 'package:isar/isar.dart';

part 'collection.g.dart';

/// A user-defined collection (folder) for organizing bookmarks.
@collection
class BookmarkCollection {
  BookmarkCollection({
    required this.title,
    required this.slug,
    this.description,
    this.icon,
    this.accentColor,
    this.coverMode,
    this.coverImageUrl,
    this.coverLocalPath,
    this.isPinned = false,
    this.isArchived = false,
    this.isSmartCollection = false,
    this.smartRuleJson,
    this.itemCount = 0,
    this.sortMode,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Auto-increment primary key.
  Id id = Isar.autoIncrement;

  /// Display title of the collection.
  String title;

  /// URL-safe unique slug for the collection (e.g. 'research-papers').
  @Index(unique: true)
  String slug;

  /// Optional longer description.
  String? description;

  /// Icon identifier (e.g. Material Icons name).
  String? icon;

  /// Accent hex color code for collection theming.
  String? accentColor;

  /// Cover display mode: 'color', 'image', or 'gradient'.
  String? coverMode;

  /// Remote URL for the cover image.
  String? coverImageUrl;

  /// Local file path for the cover image.
  String? coverLocalPath;

  /// Whether the collection is pinned to the top of the list.
  bool isPinned;

  /// Whether the collection is archived (hidden from main views).
  bool isArchived;

  /// Whether this is a smart collection with auto-fill rules.
  bool isSmartCollection;

  /// JSON-encoded rules for smart collection auto-population.
  String? smartRuleJson;

  /// Cached count of bookmarks in this collection.
  int itemCount;

  /// Default sort mode: 'dateDesc', 'dateAsc', 'title', 'manual'.
  String? sortMode;

  /// When the collection was created.
  DateTime createdAt;

  /// When the collection was last modified.
  DateTime updatedAt;
}
