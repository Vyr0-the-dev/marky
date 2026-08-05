import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/collections/presentation/providers/collection_providers.dart';
import 'package:marky/features/collections/presentation/widgets/collection_assignment_sheet.dart';
import 'package:marky/features/feed/presentation/providers/feed_providers.dart';
import 'package:marky/features/notes/presentation/providers/note_providers.dart';
import 'package:marky/features/reminders/presentation/widgets/reminder_bottom_sheet.dart';
import 'package:marky/features/tags/presentation/providers/tag_providers.dart';
import 'package:marky/features/tags/presentation/widgets/tag_assignment_sheet.dart';
import 'package:marky/features/vault/domain/use_cases/move_bookmark_to_vault_use_case.dart';
import 'package:marky/features/vault/domain/use_cases/remove_bookmark_from_vault_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/note.dart';
import 'package:marky/shared/models/tag.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen bookmark detail screen with hero image, metadata, and actions.
///
/// Watches [bookmarkByIdProvider] for the given [id] and renders a premium
/// detail view with loading, error, not-found, and data states.
class BookmarkDetailScreen extends ConsumerWidget {
  /// Creates the [BookmarkDetailScreen] for the bookmark with [id].
  const BookmarkDetailScreen({
    required this.id,
    super.key,
  });

  /// The bookmark ID to display.
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<BookmarkItem?> bookmarkAsync =
        ref.watch(bookmarkByIdProvider(id));

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.surface1,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: <Widget>[
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return bookmarkAsync.when(
                data: (BookmarkItem? bookmark) {
                  if (bookmark == null) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.alarm),
                    tooltip: 'Set reminder',
                    color: AppColors.textSecondary,
                    onPressed: () => ReminderBottomSheet.show(
                      context,
                      bookmarkId: bookmark.id,
                      bookmarkTitle: bookmark.title ??
                          Uri.tryParse(bookmark.originalUrl)?.host ??
                          bookmark.originalUrl,
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: bookmarkAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (Object error, StackTrace? stackTrace) => const Center(
          child: Text(
            'Failed to load bookmark',
            style: AppTypography.body,
          ),
        ),
        data: (BookmarkItem? bookmark) {
          if (bookmark == null) {
            return const Center(
              child: Text(
                'Bookmark not found',
                style: AppTypography.body,
              ),
            );
          }
          return _BookmarkDetailContent(bookmark: bookmark);
        },
      ),
    );
  }
}

// ── Invalid ID screen ─────────────────────────────────────────────────

// _InvalidIdScreen removed — ID validation now happens in the router
// before BookmarkDetailScreen is instantiated.

// ─── Detail content ────────────────────────────────────────────────────

class _BookmarkDetailContent extends ConsumerWidget {
  const _BookmarkDetailContent({required this.bookmark});

  final BookmarkItem bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String domain = _extractDomain(bookmark.originalUrl);

    // Prefer locally cached thumbnail, then remote hero image, then remote thumbnail.
    final String? localPath = bookmark.localThumbnailPath;
    final String? remoteUrl = bookmark.heroImageUrl ?? bookmark.thumbnailUrl;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Hero image ──────────────────────────────────────────
          AspectRatio(
            aspectRatio: 16 / 9,
            child: localPath != null && localPath.isNotEmpty
                ? _LocalImageFadeIn(path: localPath)
                : remoteUrl != null && remoteUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: remoteUrl,
                        fit: BoxFit.cover,
                        placeholder: (BuildContext context, String url) =>
                            const _ImagePlaceholder(),
                        errorWidget: (BuildContext context, String url,
                                Object error) =>
                            const _ImagePlaceholder(),
                      )
                    : const _ImagePlaceholder(),
          ),

          // ── Text content ────────────────────────────────────────
          Padding(
            padding: AppShapes.screenPaddingInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Title
                Text(
                  bookmark.title ?? domain,
                  style: AppTypography.sectionTitle,
                ),
                const SizedBox(height: 12),

                // Domain row
                Row(
                  children: <Widget>[
                    _buildFavicon(bookmark, domain),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        domain,
                        style: AppTypography.metadata,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.yMMMd().format(bookmark.createdAt),
                      style: AppTypography.metadata,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                if (bookmark.description != null &&
                    bookmark.description!.isNotEmpty)
                  Text(
                    bookmark.description!,
                    style: AppTypography.body,
                  )
                else if (bookmark.snippet != null &&
                    bookmark.snippet!.isNotEmpty)
                  Text(
                    bookmark.snippet!,
                    style: AppTypography.body,
                  ),
                const SizedBox(height: 16),

                // AI Summary
                _buildAiSummarySection(bookmark),
                const SizedBox(height: 16),

                // Metadata chips
                _buildMetadataChips(bookmark),
                const SizedBox(height: 24),

                // Tags section
                _buildTagsSection(context, ref),
                const SizedBox(height: 24),

                // Collections section
                _buildCollectionsSection(context, ref),
                const SizedBox(height: 24),

                // Notes section
                _buildNotesSection(context, ref),
                const SizedBox(height: 24),

                // Related Items
                _buildRelatedItemsSection(context, ref, bookmark),
                const SizedBox(height: 24),

                // Action row
                _buildActionRow(context, ref, bookmark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _extractDomain(String url) {
    try {
      final Uri uri = Uri.parse(url);
      if (uri.host.isNotEmpty) {
        return uri.host;
      }
    } catch (_) {
      // Fallback to raw URL on parse failure.
    }
    return url;
  }

  Widget _buildFavicon(BookmarkItem bookmark, String domain) {
    final String? localPath = bookmark.localFaviconPath;
    final String? remoteUrl = bookmark.faviconUrl;

    // Skip SVG favicons — fall through to monogram.
    if (remoteUrl != null && remoteUrl.toLowerCase().endsWith('.svg')) {
      return _DomainMonogram(domain: domain);
    }

    if (localPath != null && localPath.isNotEmpty) {
      return _LocalFaviconFadeIn(path: localPath);
    }

    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: remoteUrl,
        width: 20,
        height: 20,
        placeholder: (BuildContext context, String url) =>
            _DomainMonogram(domain: domain),
        errorWidget: (BuildContext context, String url, Object error) =>
            _DomainMonogram(domain: domain),
      );
    }

    return _DomainMonogram(domain: domain);
  }

  Widget _buildMetadataChips(BookmarkItem bookmark) {
    final List<String> chips = <String>[
      if (bookmark.contentType != null && bookmark.contentType!.isNotEmpty)
        bookmark.contentType!,
      if (bookmark.sourceType != null && bookmark.sourceType!.isNotEmpty)
        bookmark.sourceType!,
      if (bookmark.author != null && bookmark.author!.isNotEmpty)
        bookmark.author!,
      if (bookmark.publisher != null && bookmark.publisher!.isNotEmpty)
        bookmark.publisher!,
    ];

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((String label) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(AppShapes.radiusMini),
          ),
          child: Text(
            label,
            style: AppTypography.metadata.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionRow(BuildContext context, WidgetRef ref, BookmarkItem bookmark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _ActionButton(
          icon: Icons.open_in_new,
          label: 'Open',
          onPressed: () async {
            final Uri? uri = Uri.tryParse(bookmark.originalUrl);
            if (uri != null) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        ),
        _ActionButton(
          icon: bookmark.isFavorite ? Icons.star : Icons.star_border,
          label: 'Favorite',
          color: bookmark.isFavorite ? AppColors.accentPrimary : null,
          onPressed: () {
            // TODO: Wire to repository via use-case in a later slice.
          },
        ),
        _ActionButton(
          icon: bookmark.isInVault ? Icons.lock_open_outlined : Icons.lock_outline,
          label: bookmark.isInVault ? 'Remove from vault' : 'Move to vault',
          color: bookmark.isInVault ? AppColors.accentPrimary : null,
          onPressed: () async {
            if (bookmark.isInVault) {
              final RemoveBookmarkFromVaultUseCase useCase =
                  ref.read(removeBookmarkFromVaultUseCaseProvider);
              final bool success = await useCase.execute(bookmark.id);
              if (success && context.mounted) {
                ref.invalidate(bookmarkByIdProvider(bookmark.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Removed from vault')),
                );
              }
            } else {
              final MoveBookmarkToVaultUseCase useCase =
                  ref.read(moveBookmarkToVaultUseCaseProvider);
              final bool success = await useCase.execute(bookmark.id);
              if (success && context.mounted) {
                ref.invalidate(bookmarkByIdProvider(bookmark.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Moved to vault')),
                );
              }
            }
          },
        ),
        _ActionButton(
          icon: Icons.share_outlined,
          label: 'Share',
          onPressed: () async {
            await Share.share(bookmark.originalUrl);
          },
        ),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context, WidgetRef ref) {
    final List<int> tagIds = bookmark.tagIds ?? <int>[];
    final AsyncValue<List<Tag>> tagsAsync = ref.watch(tagListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Tags',
              style: AppTypography.sectionTitle.copyWith(fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () => _openTagAssignmentSheet(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add tag'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentPrimary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        tagsAsync.when(
          data: (List<Tag> allTags) {
            if (tagIds.isEmpty) {
              return Text(
                'No tags assigned',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.textTertiary,
                ),
              );
            }
            final List<Tag> matched = <Tag>[
              for (final int id in tagIds)
                allTags.firstWhere(
                  (Tag t) => t.id == id,
                  orElse: () => Tag(
                    name: 'Unknown',
                    slug: 'unknown',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                ),
            ];
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: matched.map((Tag tag) {
                return _DetailTagChip(
                  tag: tag,
                  onTap: () => context.go(
                    Routes.tagDetail.replaceAll(':id', tag.id.toString()),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildCollectionsSection(BuildContext context, WidgetRef ref) {
    final List<int> collectionIds = bookmark.collectionIds ?? <int>[];
    final AsyncValue<List<BookmarkCollection>> collectionsAsync =
        ref.watch(collectionListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Collections',
              style: AppTypography.sectionTitle.copyWith(fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () => _openCollectionAssignmentSheet(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add to collection'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentPrimary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        collectionsAsync.when(
          data: (List<BookmarkCollection> allCollections) {
            if (collectionIds.isEmpty) {
              return Text(
                'Not in any collection',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.textTertiary,
                ),
              );
            }
            final List<BookmarkCollection> matched = <BookmarkCollection>[
              for (final int id in collectionIds)
                allCollections.firstWhere(
                  (BookmarkCollection c) => c.id == id,
                  orElse: () => BookmarkCollection(
                    title: 'Unknown',
                    slug: 'unknown',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                ),
            ];
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: matched.map((BookmarkCollection collection) {
                return _DetailCollectionChip(
                  collection: collection,
                  onTap: () => context.go(
                    Routes.collectionDetail
                        .replaceAll(':id', collection.id.toString()),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Note>> notesAsync =
        ref.watch(notesByBookmarkIdProvider(bookmark.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Notes',
              style: AppTypography.sectionTitle.copyWith(fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () async {
                final bool? changed = await context.push<bool>(
                  '${Routes.noteEdit}?bookmarkId=${bookmark.id}',
                );
                if (changed ?? false) {
                  ref.invalidate(notesByBookmarkIdProvider(bookmark.id));
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add note'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentPrimary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        notesAsync.when(
          data: (List<Note> notes) {
            if (notes.isEmpty) {
              return Text(
                'No notes yet',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.textTertiary,
                ),
              );
            }
            return Column(
              children: notes.map((Note note) {
                return _NoteCard(
                  note: note,
                  bookmarkId: bookmark.id,
                  onTap: () async {
                    final bool? changed = await context.push<bool>(
                      '${Routes.noteEditWithId.replaceAll(':id', note.id.toString())}?bookmarkId=${bookmark.id}',
                    );
                    if (changed ?? false) {
                      ref.invalidate(notesByBookmarkIdProvider(bookmark.id));
                    }
                  },
                );
              }).toList(),
            );
          },
          loading: () => const SizedBox(
            height: 48,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => Text(
            'Failed to load notes',
            style: AppTypography.metadata.copyWith(
              color: AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openTagAssignmentSheet(BuildContext context) async {
    await TagAssignmentSheet.show(
      context,
      bookmarkId: bookmark.id,
      initialTagIds: bookmark.tagIds ?? <int>[],
    );
  }

  Future<void> _openCollectionAssignmentSheet(BuildContext context) async {
    await CollectionAssignmentSheet.show(
      context,
      bookmarkId: bookmark.id,
      initialCollectionIds: bookmark.collectionIds ?? <int>[],
    );
  }

  // ── AI Summary section ────────────────────────────────────────────────

  Widget _buildAiSummarySection(BookmarkItem bookmark) {
    final String? summary = bookmark.aiSummary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: AppColors.accentPrimary.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Text(
              'AI Summary',
              style: AppTypography.sectionTitle.copyWith(
                fontSize: 14,
                color: AppColors.accentPrimary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (summary != null && summary.isNotEmpty)
          Text(
            summary,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Text(
            'No summary available',
            style: AppTypography.metadata.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  // ── Related Items section ─────────────────────────────────────────────

  Widget _buildRelatedItemsSection(
    BuildContext context,
    WidgetRef ref,
    BookmarkItem bookmark,
  ) {
    final bool aiEnabled;
    try {
      aiEnabled = ref.watch(appSettingsProvider).aiEnabled;
    } catch (_) {
      // If settings can't be loaded (e.g. in widget tests without Isar),
      // collapse the section gracefully.
      return const SizedBox.shrink();
    }

    if (!aiEnabled) {
      return const SizedBox.shrink();
    }

    final AsyncValue<List<BookmarkItem>> relatedAsync =
        ref.watch(relatedItemsProvider(bookmark.id));

    return relatedAsync.when(
      data: (List<BookmarkItem> related) {
        if (related.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Related',
              style: AppTypography.sectionTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: related.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) {
                  final BookmarkItem item = related[index];
                  return _RelatedBookmarkCard(
                    bookmark: item,
                    onTap: () => context.go(
                      Routes.bookmarkDetail.replaceAll(':id', item.id.toString()),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ─── Related bookmark card ─────────────────────────────────────────────

class _RelatedBookmarkCard extends StatelessWidget {
  const _RelatedBookmarkCard({
    required this.bookmark,
    this.onTap,
  });

  final BookmarkItem bookmark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String domain = _extractDomain(bookmark.originalUrl);
    final String? localPath = bookmark.localThumbnailPath;
    final String? remoteUrl = bookmark.thumbnailUrl ?? bookmark.heroImageUrl;

    return Material(
      color: AppColors.surface2,
      borderRadius: BorderRadius.circular(AppShapes.radiusMini),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusMini),
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppShapes.radiusMini),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: localPath != null && localPath.isNotEmpty
                      ? Image.file(
                          File(localPath),
                          fit: BoxFit.cover,
                        )
                      : remoteUrl != null && remoteUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: remoteUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const _ImagePlaceholder(),
                              errorWidget: (_, __, ___) =>
                                  const _ImagePlaceholder(),
                            )
                          : const _ImagePlaceholder(),
                ),
              ),
              // Title & domain
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      bookmark.title ?? domain,
                      style: AppTypography.metadata.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      domain,
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractDomain(String url) {
    try {
      final Uri uri = Uri.parse(url);
      if (uri.host.isNotEmpty) {
        return uri.host;
      }
    } catch (_) {
      // Fallback to raw URL on parse failure.
    }
    return url;
  }
}

// ─── Action button widget ──────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppShapes.radiusMini),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: color ?? AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.metadata.copyWith(
                color: color ?? AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Image placeholder ─────────────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surface3,
      child: Center(
        child: Icon(
          Icons.image,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

// ─── Local image fade-in ───────────────────────────────────────────────

class _LocalImageFadeIn extends StatelessWidget {
  const _LocalImageFadeIn({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool wasSynchronouslyLoaded,
      ) {
        final bool isLoaded = wasSynchronouslyLoaded || frame != null;
        return AnimatedOpacity(
          opacity: isLoaded ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
    );
  }
}

// ─── Domain monogram ───────────────────────────────────────────────────

class _DomainMonogram extends StatelessWidget {
  const _DomainMonogram({required this.domain});

  final String domain;

  @override
  Widget build(BuildContext context) {
    final String letter =
        domain.isNotEmpty ? domain[0].toUpperCase() : '?';

    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: AppColors.surface3,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          height: 1,
        ),
      ),
    );
  }
}

// ─── Local favicon fade-in ─────────────────────────────────────────────

class _LocalFaviconFadeIn extends StatelessWidget {
  const _LocalFaviconFadeIn({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      width: 20,
      height: 20,
      fit: BoxFit.cover,
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool wasSynchronouslyLoaded,
      ) {
        final bool isLoaded = wasSynchronouslyLoaded || frame != null;
        return AnimatedOpacity(
          opacity: isLoaded ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
    );
  }
}

// ─── Detail tag chip ───────────────────────────────────────────────────

class _DetailTagChip extends StatelessWidget {
  const _DetailTagChip({
    required this.tag,
    this.onTap,
  });

  final Tag tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color tagColor = _resolveColor(tag.color);

    return Material(
      color: tagColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tagColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                tag.name,
                style: AppTypography.metadata.copyWith(
                  color: tagColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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

// ─── Detail collection chip ────────────────────────────────────────────

class _DetailCollectionChip extends StatelessWidget {
  const _DetailCollectionChip({
    required this.collection,
    this.onTap,
  });

  final BookmarkCollection collection;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _resolveColor(collection.accentColor);
    final IconData? iconData = _resolveIcon(collection.icon);

    return Material(
      color: accentColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                iconData ?? Icons.folder,
                size: 14,
                color: accentColor,
              ),
              const SizedBox(width: 6),
              Text(
                collection.title,
                style: AppTypography.metadata.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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

// ─── Note card widget ────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.bookmarkId,
    this.onTap,
  });

  final Note note;
  final int bookmarkId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final DateTime displayDate = note.updatedAt;

    return Material(
      color: AppColors.surface2,
      borderRadius: BorderRadius.circular(AppShapes.radiusMini),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusMini),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                note.content,
                style: AppTypography.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat.yMMMd().add_jm().format(displayDate),
                style: AppTypography.metadata.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
