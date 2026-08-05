import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/isar_service.dart';
import 'package:marky/shared/models/app_settings.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/note.dart';
import 'package:marky/shared/models/reminder.dart';
import 'package:marky/shared/models/tag.dart';

/// Async provider that bootstraps the Isar database during app startup.
///
/// Consumers should watch this provider with [AsyncValue] handling:
///
/// ```dart
/// final asyncIsar = ref.watch(isarProvider);
/// asyncIsar.when(
///   data: (isar) => ...,
///   loading: () => ...,
///   error: (err, stack) => ...,
/// );
/// ```
///
/// The provider caches the opened [Isar] instance for the lifetime of the
/// [ProviderScope].
final FutureProvider<Isar> isarProvider = FutureProvider<Isar>(
  (Ref ref) async => IsarService.instance.open(
    schemas: <CollectionSchema<dynamic>>[
      AppSettingsSchema,
      TagSchema,
      BookmarkItemSchema,
      BookmarkCollectionSchema,
      NoteSchema,
      ReminderSchema,
    ],
  ),
);
