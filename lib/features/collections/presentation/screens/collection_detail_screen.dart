import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/collections/presentation/providers/collection_providers.dart';
import 'package:marky/features/collections/presentation/widgets/create_collection_sheet.dart';
import 'package:marky/features/feed/presentation/widgets/bookmark_card.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';

/// Detail screen for a single collection showing all associated bookmarks.
///
/// Accepts [id] as a required constructor parameter for testability (MEM102).
class CollectionDetailScreen extends ConsumerWidget {
  /// Creates a [CollectionDetailScreen] for the collection with [id].
  const CollectionDetailScreen({
    required this.id,
    super.key,
  });

  /// The collection ID to display.
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<BookmarkCollection?> collectionAsync =
        ref.watch(collectionByIdProvider(id));
    final AsyncValue<List<BookmarkItem>> bookmarksAsync =
        ref.watch(bookmarksByCollectionIdProvider(id));

    final Color accentColor = collectionAsync.when(
      loading: () => AppColors.accentPrimary,
      error: (_, __) => AppColors.accentPrimary,
      data: (BookmarkCollection? c) => _resolveColor(c?.accentColor),
    );

    final IconData? iconData = collectionAsync.when(
      loading: () => null,
      error: (_, __) => null,
      data: (BookmarkCollection? c) => _resolveIcon(c?.icon),
    );

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.surface1,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: collectionAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) =>
              const Text('Collection', style: AppTypography.sectionTitle),
          data: (BookmarkCollection? c) => Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppShapes.radiusMini),
                ),
                child: Icon(
                  iconData ?? Icons.folder,
                  size: 18,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c?.title ?? 'Collection',
                  style: AppTypography.sectionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          collectionAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (BookmarkCollection? c) {
              if (c == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => CreateCollectionSheet.show(context, collection: c),
              );
            },
          ),
        ],
      ),
      body: collectionAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (Object error, StackTrace? stackTrace) => const Center(
          child: Text(
            'Failed to load collection',
            style: AppTypography.body,
          ),
        ),
        data: (BookmarkCollection? collection) {
          if (collection == null) {
            return const Center(
              child: Text(
                'Collection not found',
                style: AppTypography.body,
              ),
            );
          }
          return _BookmarksList(
            bookmarksAsync: bookmarksAsync,
            accentColor: accentColor,
          );
        },
      ),
    );
  }

  Color _resolveColor(String? hex) {
    if (hex == null || hex.isEmpty) {
      return AppColors.accentPrimary;
    }
    try {
      final String sanitized = hex.replaceAll('#', '');
      if (sanitized.length == 6) {
        return Color(int.parse('FF$sanitized', radix: 16));
      }
      if (sanitized.length == 8) {
        return Color(int.parse(sanitized, radix: 16));
      }
    } catch (_) {
      // Fall through to default.
    }
    return AppColors.accentPrimary;
  }

  IconData? _resolveIcon(String? iconCode) {
    if (iconCode == null || iconCode.isEmpty) {
      return null;
    }
    try {
      return IconData(
        int.parse(iconCode),
        fontFamily: 'MaterialIcons',
      );
    } catch (_) {
      return null;
    }
  }
}

// ─── Bookmarks list ────────────────────────────────────────────────────

class _BookmarksList extends StatelessWidget {
  const _BookmarksList({
    required this.bookmarksAsync,
    required this.accentColor,
  });

  final AsyncValue<List<BookmarkItem>> bookmarksAsync;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return bookmarksAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (Object error, StackTrace? stackTrace) => const Center(
        child: Text(
          'Failed to load bookmarks',
          style: AppTypography.body,
        ),
      ),
      data: (List<BookmarkItem> bookmarks) {
        if (bookmarks.isEmpty) {
          return _EmptyBookmarksState(accentColor: accentColor);
        }

        return ListView.separated(
          padding: AppShapes.screenPaddingInsets,
          itemCount: bookmarks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) {
            final BookmarkItem bookmark = bookmarks[index];
            return BookmarkCard(
              bookmark: bookmark,
              onTap: () => context.go(
                Routes.bookmarkDetail.replaceAll(':id', bookmark.id.toString()),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Empty bookmarks state ─────────────────────────────────────────────

class _EmptyBookmarksState extends StatelessWidget {
  const _EmptyBookmarksState({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: accentColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks in this collection yet',
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add bookmarks to this collection when saving or editing',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
