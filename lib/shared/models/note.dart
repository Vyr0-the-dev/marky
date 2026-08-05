import 'package:isar/isar.dart';

part 'note.g.dart';

/// A note attached to a bookmark for additional context or thoughts.
@collection
class Note {
  Note({
    required this.bookmarkId,
    required this.content,
    this.contentFormat = 'plain',
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.colorLabel,
  });

  /// Auto-increment primary key.
  Id id = Isar.autoIncrement;

  /// Reference to the parent bookmark this note belongs to.
  @Index()
  int bookmarkId;

  /// Note content text.
  String content;

  /// Format of the content: 'plain', 'markdown', or 'rich'.
  String contentFormat;

  /// When the note was created.
  DateTime createdAt;

  /// When the note was last modified.
  DateTime updatedAt;

  /// Whether the note is pinned within its bookmark.
  bool isPinned;

  /// Optional color label for visual categorization.
  String? colorLabel;
}
