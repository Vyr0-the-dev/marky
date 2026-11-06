import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/automation_rule_entity.dart';
import 'package:marky/core/database/entities/backup_meta_entity.dart';
import 'package:marky/core/database/entities/bookmark_entity.dart';
import 'package:marky/core/database/entities/collection_entity.dart';
import 'package:marky/core/database/entities/note_entity.dart';
import 'package:marky/core/database/entities/reminder_entity.dart';
import 'package:marky/core/database/entities/search_query_entity.dart';
import 'package:marky/core/database/entities/tag_entity.dart';

/// Single source of truth for opening the Marky v2 Isar database.
///
/// Why a thin static class instead of a service class:
/// - Schema list is a compile-time constant; nothing about it is
///   instance-scoped.
/// - The repository layer (Tur 2) takes the [Isar] handle directly;
///   wrapping it in a service would just add indirection.
/// - Tests call [open] with a temp directory and a unique [name] for
///   isolation, then close manually. No global singleton state.
///
/// During the strangler-fig phase the database name is intentionally
/// distinct from legacy Marky's `marky` so the two coexist on disk:
/// uninstalling the app still nukes both, but a hot-restart between
/// v1 and v2 builds doesn't corrupt either.
abstract final class MarkyDatabase {
  /// Default database name. Overridden in tests for isolation.
  static const String defaultName = 'marky_v2';
  static const int schemaVersion = 1;
  static const List<String> schemaNames = <String>[
    'BookmarkEntity',
    'TagEntity',
    'CollectionEntity',
    'ReminderEntity',
    'AutomationRuleEntity',
    'BackupMetaEntity',
    'NoteEntity',
    'SearchQueryEntity',
  ];

  /// All Isar collections registered for the v2 schema.
  ///
  /// Keep this list in sync with the entity files in
  /// `lib/v2/core/database/entities/`. Adding a new entity is a
  /// three-step ritual: create the file, add the schema here, run
  /// `dart run build_runner build`.
  ///
  /// The list is intentionally a concrete [List] (not a [Set]) so
  /// the order is stable for snapshot tests and the cold-start
  /// benchmark.
  static const List<CollectionSchema<dynamic>> schemas =
      <CollectionSchema<dynamic>>[
    BookmarkEntitySchema,
    TagEntitySchema,
    CollectionEntitySchema,
    ReminderEntitySchema,
    AutomationRuleEntitySchema,
    BackupMetaEntitySchema,
    NoteEntitySchema,
    SearchQueryEntitySchema,
  ];

  /// Opens the v2 database at [directory].
  ///
  /// [name] is the Isar instance name; tests override it to avoid
  /// colliding when multiple tests open Isar in the same temp
  /// directory. [inspector] enables the Isar Inspector during
  /// development; we leave it off by default to match release builds
  /// in tests.
  static Future<Isar> open({
    required String directory,
    String name = defaultName,
    bool inspector = false,
  }) {
    return Isar.open(
      schemas,
      directory: directory,
      name: name,
      inspector: inspector,
    );
  }
}
