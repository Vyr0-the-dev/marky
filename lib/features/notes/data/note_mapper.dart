import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/note_entity.dart';
import 'package:marky/features/notes/domain/note.dart';

abstract final class NoteMapper {
  static Note toDomain(NoteEntity e) => Note(
        id: e.id == Isar.autoIncrement ? null : e.id,
        bookmarkId: e.bookmarkId,
        content: e.content,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  static NoteEntity toEntity(Note n) {
    final NoteEntity entity = NoteEntity(
      bookmarkId: n.bookmarkId,
      content: n.content,
      createdAt: n.createdAt,
      updatedAt: n.updatedAt,
    );
    if (n.id != null) entity.id = n.id!;
    return entity;
  }
}
