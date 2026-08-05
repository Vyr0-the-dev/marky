import 'package:isar/isar.dart';

import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Use case for moving a bookmark into the protected vault.
///
/// Atomically toggles [BookmarkItem.isInVault] to `true` and updates
/// [BookmarkItem.updatedAt] via [BookmarkItemRepository.update].
class MoveBookmarkToVaultUseCase {
  MoveBookmarkToVaultUseCase({
    required BookmarkItemRepository repository,
  }) : _repository = repository;

  final BookmarkItemRepository _repository;

  /// Moves the bookmark with [bookmarkId] into the vault.
  ///
  /// Returns `true` if the bookmark was found and updated, `false` if
  /// no bookmark with the given ID exists.
  Future<bool> execute(Id bookmarkId) async {
    final BookmarkItem? bookmark = await _repository.getById(bookmarkId);

    if (bookmark == null) {
      return false;
    }

    bookmark.isInVault = true;
    bookmark.updatedAt = DateTime.now();

    await _repository.update(bookmark);
    return true;
  }
}
