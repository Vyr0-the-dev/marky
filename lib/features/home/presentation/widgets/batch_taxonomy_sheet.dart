import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/home/presentation/feed_notifier.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/l10n/app_localizations.dart';

enum BatchTaxonomyMode { tags, collections }

/// Bottom sheet for applying tags or manual collections to a batch of selected
/// bookmarks. Supports tri-state selection so partial memberships are preserved
/// unless explicitly toggled.
class BatchTaxonomySheet extends ConsumerStatefulWidget {
  const BatchTaxonomySheet({
    required this.mode,
    required this.selectedBookmarkIds,
    super.key,
  });

  final BatchTaxonomyMode mode;
  final Set<int> selectedBookmarkIds;

  static Future<int?> show(
    BuildContext context, {
    required BatchTaxonomyMode mode,
    required Set<int> selectedBookmarkIds,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BatchTaxonomySheet(
        mode: mode,
        selectedBookmarkIds: selectedBookmarkIds,
      ),
    );
  }

  @override
  ConsumerState<BatchTaxonomySheet> createState() => _BatchTaxonomySheetState();
}

class _BatchTaxonomySheetState extends ConsumerState<BatchTaxonomySheet> {
  List<Bookmark> _bookmarks = const <Bookmark>[];
  bool _loadingBookmarks = true;
  bool _saving = false;

  /// Explicit overrides chosen by the user:
  /// - `true`: add this id to all selected bookmarks
  /// - `false`: remove this id from all selected bookmarks
  /// Absent key: keep original per-bookmark membership unchanged.
  final Map<int, bool> _overrides = <int, bool>{};

  @override
  void initState() {
    super.initState();
    unawaited(_loadSelectedBookmarks());
  }

  Future<void> _loadSelectedBookmarks() async {
    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    final List<Bookmark> loaded =
        await repo.getByIds(widget.selectedBookmarkIds.toList());
    if (!mounted) return;
    setState(() {
      _bookmarks = loaded;
      _loadingBookmarks = false;
    });
  }

  bool? _checkboxValueFor(int itemId) {
    if (_overrides.containsKey(itemId)) {
      return _overrides[itemId];
    }
    if (_bookmarks.isEmpty) return false;
    int matches = 0;
    for (final Bookmark b in _bookmarks) {
      final List<int> ids = widget.mode == BatchTaxonomyMode.tags
          ? b.tagIds
          : b.collectionIds;
      if (ids.contains(itemId)) matches++;
    }
    if (matches == 0) return false;
    if (matches == _bookmarks.length) return true;
    return null;
  }

  void _toggleItem(int itemId) {
    final bool? current = _checkboxValueFor(itemId);
    setState(() {
      // false or indeterminate -> add to all (true); true -> remove from all (false).
      _overrides[itemId] = current != true;
    });
  }

  Future<void> _apply() async {
    if (_saving || _bookmarks.isEmpty) return;
    if (_overrides.isEmpty) {
      Navigator.of(context).pop(0);
      return;
    }

    setState(() => _saving = true);
    try {
      final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
      final List<Bookmark> updated = <Bookmark>[];
      for (final Bookmark b in _bookmarks) {
        final Set<int> currentIds = Set<int>.of(
          widget.mode == BatchTaxonomyMode.tags ? b.tagIds : b.collectionIds,
        );
        for (final MapEntry<int, bool> entry in _overrides.entries) {
          if (entry.value) {
            currentIds.add(entry.key);
          } else {
            currentIds.remove(entry.key);
          }
        }
        final List<int> nextIds = currentIds.toList()..sort();
        updated.add(
          widget.mode == BatchTaxonomyMode.tags
              ? b.copyWith(tagIds: nextIds)
              : b.copyWith(collectionIds: nextIds),
        );
      }

      await repo.saveAll(updated);
      if (widget.mode == BatchTaxonomyMode.tags) {
        await ref.read(tagRepositoryProvider).recomputeAllUsageCounts();
      } else {
        await ref
            .read(bookmarkCollectionRepositoryProvider)
            .recomputeAllItemCounts();
      }
      ref.read(feedNotifierProvider.notifier).exitSelectionMode();
      if (mounted) {
        Navigator.of(context).pop(updated.length);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final int count = widget.selectedBookmarkIds.length;
    final String title = widget.mode == BatchTaxonomyMode.tags
        ? (l10n?.batchTagSheetTitle(count) ?? 'Tag $count bookmarks')
        : (l10n?.batchCollectionSheetTitle(count) ??
            'Add $count bookmarks to collections');

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ReadingRoomSpacing.lg,
                ReadingRoomSpacing.lg,
                ReadingRoomSpacing.md,
                ReadingRoomSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: l10n?.actionClose ?? 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: _loadingBookmarks
                  ? const Padding(
                      padding: EdgeInsets.all(ReadingRoomSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : widget.mode == BatchTaxonomyMode.tags
                      ? _buildTagList(context)
                      : _buildCollectionList(context),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(ReadingRoomSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed:
                        _saving ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n?.actionCancel ?? 'Cancel'),
                  ),
                  const SizedBox(width: ReadingRoomSpacing.sm),
                  FilledButton(
                    onPressed:
                        _saving || _loadingBookmarks ? null : _apply,
                    child: Text(l10n?.actionSave ?? 'Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagList(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final AsyncValue<List<Tag>> tagsAsync = ref.watch(tagsProvider);
    return tagsAsync.when(
      data: (List<Tag> tags) {
        if (tags.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(ReadingRoomSpacing.xl),
            child: Text(
              l10n?.libraryNoTags ?? 'No tags yet.',
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: tags.length,
          itemBuilder: (BuildContext context, int index) {
            final Tag tag = tags[index];
            final int? id = tag.id;
            if (id == null) return const SizedBox.shrink();
            return CheckboxListTile(
              tristate: true,
              value: _checkboxValueFor(id),
              onChanged: (_) => _toggleItem(id),
              title: Text(tag.name),
              secondary: Icon(
                Icons.label_outline_rounded,
                color: tag.colorArgb != null
                    ? Color(tag.colorArgb!)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(ReadingRoomSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.xl),
        child: Text(
          l10n?.libraryCouldNotLoadTags ?? 'Could not load tags.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCollectionList(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final AsyncValue<List<BookmarkCollection>> collectionsAsync =
        ref.watch(bookmarkCollectionsProvider);
    return collectionsAsync.when(
      data: (List<BookmarkCollection> collections) {
        final List<BookmarkCollection> manual = collections
            .where((BookmarkCollection c) => !c.isSmart && c.id != null)
            .toList(growable: false);
        if (manual.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(ReadingRoomSpacing.xl),
            child: Text(
              l10n?.libraryNoCollections ?? 'No collections yet.',
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: manual.length,
          itemBuilder: (BuildContext context, int index) {
            final BookmarkCollection col = manual[index];
            final int id = col.id!;
            return CheckboxListTile(
              tristate: true,
              value: _checkboxValueFor(id),
              onChanged: (_) => _toggleItem(id),
              title: Text(col.title),
              secondary: Icon(
                Icons.folder_outlined,
                color: col.accentColorArgb != null
                    ? Color(col.accentColorArgb!)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(ReadingRoomSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.xl),
        child: Text(
          l10n?.libraryCouldNotLoadCollections ?? 'Could not load collections.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
