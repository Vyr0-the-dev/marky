import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/feed/presentation/widgets/bookmark_card.dart';
import 'package:marky/features/tags/presentation/providers/tag_providers.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/tag.dart';

/// Detail screen for a single tag showing all associated bookmarks.
///
/// Accepts [id] as a required constructor parameter for testability (MEM102).
class TagDetailScreen extends ConsumerWidget {
  /// Creates a [TagDetailScreen] for the tag with [id].
  const TagDetailScreen({
    required this.id,
    super.key,
  });

  /// The tag ID to display.
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Tag?> tagAsync = ref.watch(tagByIdProvider(id));
    final AsyncValue<List<BookmarkItem>> bookmarksAsync =
        ref.watch(bookmarksByTagIdProvider(id));

    final Color tagColor = tagAsync.when(
      loading: () => AppColors.accentPrimary,
      error: (_, __) => AppColors.accentPrimary,
      data: (Tag? tag) => _resolveColor(tag?.color),
    );

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.surface1,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: tagAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const Text('Tag', style: AppTypography.sectionTitle),
          data: (Tag? tag) => Row(
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: tagColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                tag?.name ?? 'Tag',
                style: AppTypography.sectionTitle,
              ),
            ],
          ),
        ),
      ),
      body: tagAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (Object error, StackTrace? stackTrace) => const Center(
          child: Text(
            'Failed to load tag',
            style: AppTypography.body,
          ),
        ),
        data: (Tag? tag) {
          if (tag == null) {
            return const Center(
              child: Text(
                'Tag not found',
                style: AppTypography.body,
              ),
            );
          }
          return _BookmarksList(
            bookmarksAsync: bookmarksAsync,
            tagColor: tagColor,
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
}

// ─── Bookmarks list ────────────────────────────────────────────────────

class _BookmarksList extends StatelessWidget {
  const _BookmarksList({
    required this.bookmarksAsync,
    required this.tagColor,
  });

  final AsyncValue<List<BookmarkItem>> bookmarksAsync;
  final Color tagColor;

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
          return _EmptyBookmarksState(tagColor: tagColor);
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
  const _EmptyBookmarksState({required this.tagColor});

  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.bookmark_outline,
            size: 64,
            color: tagColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks with this tag yet',
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tags are assigned when saving or editing bookmarks',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
