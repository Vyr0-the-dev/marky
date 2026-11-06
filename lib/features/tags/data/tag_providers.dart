import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/core/database/database_providers.dart';
import 'package:marky/features/tags/data/isar_tag_repository.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

/// Live [TagRepository] wired to the v2 Isar instance.
final Provider<TagRepository> tagRepositoryProvider =
    Provider<TagRepository>((Ref ref) {
  return IsarTagRepository(ref.watch(markyIsarProvider));
});

/// Reactive list of all tags. Auto-disposes when no widget is
/// listening; the underlying Isar query handle is closed in step.
final AutoDisposeStreamProvider<List<Tag>> tagsProvider =
    StreamProvider.autoDispose<List<Tag>>((Ref ref) {
  return ref.watch(tagRepositoryProvider).watchAll();
});

/// Reactive single-tag provider for the editor.
final AutoDisposeStreamProviderFamily<Tag?, int> tagByIdProvider =
    StreamProvider.autoDispose.family<Tag?, int>((Ref ref, int id) {
  return ref.watch(tagRepositoryProvider).watchById(id);
});
