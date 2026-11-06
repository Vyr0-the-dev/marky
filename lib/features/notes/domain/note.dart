import 'package:flutter/foundation.dart';

/// Immutable domain model for a per-bookmark note.
///
/// Notes are timeline entries — multiple per bookmark, ordered by
/// [createdAt]. Counterpart to `NoteEntity`; the repository's mapper
/// is the only place both halves co-exist.
@immutable
class Note {
  const Note({
    this.id,
    required this.bookmarkId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// `null` until persisted.
  final int? id;

  final int bookmarkId;

  /// Free-form text content. UI is responsible for trimming and
  /// rendering — the model stores exactly what the user typed.
  final String content;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// True for a note that has been saved-then-edited (its
  /// [updatedAt] differs from [createdAt] by more than the 100ms
  /// jitter window we allow for "same write transaction" timestamp
  /// drift).  Used by the UI to render a small "edited" pill.
  bool get isEdited =>
      updatedAt.difference(createdAt).inMilliseconds.abs() > 100;

  Note copyWith({
    int? id,
    int? bookmarkId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      bookmarkId: bookmarkId ?? this.bookmarkId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.id == id &&
        other.bookmarkId == bookmarkId &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, bookmarkId, content, createdAt, updatedAt);

  @override
  String toString() =>
      'Note(id: $id, bookmarkId: $bookmarkId, len: ${content.length})';
}
