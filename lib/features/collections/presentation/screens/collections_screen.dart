import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/collections/presentation/providers/collection_providers.dart';
import 'package:marky/features/collections/presentation/widgets/create_collection_sheet.dart';
import 'package:marky/shared/models/collection.dart';

/// Full-screen collection manager showing all collections in a responsive grid.
///
/// Watches [collectionManagerNotifierProvider] for live CRUD state.
/// Supports search filtering, pinned-first sorting, swipe-to-delete, and
/// tap-to-detail navigation.
class CollectionsScreen extends ConsumerStatefulWidget {
  /// Creates a [CollectionsScreen].
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<BookmarkCollection>> collectionsAsync =
        ref.watch(collectionManagerNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.surface1,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: TextField(
          controller: _searchController,
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search collections…',
            hintStyle:
                AppTypography.body.copyWith(color: AppColors.textTertiary),
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textTertiary,
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textTertiary,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
          onChanged: (String value) {
            setState(() => _searchQuery = value.trim().toLowerCase());
          },
        ),
      ),
      body: collectionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (Object error, StackTrace? stackTrace) => _ErrorState(
          onRetry: () =>
              ref.read(collectionManagerNotifierProvider.notifier).load(),
        ),
        data: (List<BookmarkCollection> collections) {
          final List<BookmarkCollection> sorted = _sortCollections(collections);
          final List<BookmarkCollection> filtered =
              _filterCollections(sorted, _searchQuery);

          if (filtered.isEmpty && _searchQuery.isEmpty) {
            return const _EmptyState();
          }

          if (filtered.isEmpty) {
            return Center(
              child: Text(
                'No collections matching "$_searchQuery"',
                style: AppTypography.body,
              ),
            );
          }

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int crossAxisCount =
                  constraints.maxWidth > 600 ? 3 : 2;

              return GridView.builder(
                padding: AppShapes.screenPaddingInsets,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppShapes.gridCrossAxisSpacing,
                  mainAxisSpacing: AppShapes.gridMainAxisSpacing,
                  childAspectRatio: 0.85,
                ),
                itemCount: filtered.length,
                itemBuilder: (BuildContext context, int index) {
                  final BookmarkCollection collection = filtered[index];
                  return _CollectionGridCard(
                    collection: collection,
                    onTap: () => context.go(
                      Routes.collectionDetail
                          .replaceAll(':id', collection.id.toString()),
                    ),
                    onDelete: () => _confirmDelete(context, ref, collection),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateCollectionSheet.show(context),
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.textPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Sorts collections with pinned items first, then by updatedAt descending.
  List<BookmarkCollection> _sortCollections(
      List<BookmarkCollection> collections) {
    return List<BookmarkCollection>.from(collections)
      ..sort((BookmarkCollection a, BookmarkCollection b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
  }

  List<BookmarkCollection> _filterCollections(
    List<BookmarkCollection> collections,
    String query,
  ) {
    if (query.isEmpty) return collections;
    return collections
        .where(
          (BookmarkCollection c) =>
              c.title.toLowerCase().contains(query) ||
              (c.description?.toLowerCase().contains(query) ?? false) ||
              c.slug.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BookmarkCollection collection,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: Text(
          'Delete "${collection.title}"?',
          style: AppTypography.sectionTitle,
        ),
        content: const Text(
          'This will remove the collection and unlink all bookmarks. This action cannot be undone.',
          style: AppTypography.body,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.label
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: AppTypography.label.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref
          .read(collectionManagerNotifierProvider.notifier)
          .delete(collection.id);
    }
  }
}

// ─── Empty state ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.folder_outlined,
            size: 64,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No collections yet',
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first collection to organize bookmarks',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

// ─── Error state ───────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.danger,
          ),
          const SizedBox(height: 12),
          const Text(
            'Failed to load collections',
            style: AppTypography.body,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── Collection grid card ──────────────────────────────────────────────

class _CollectionGridCard extends StatelessWidget {
  const _CollectionGridCard({
    required this.collection,
    required this.onTap,
    required this.onDelete,
  });

  final BookmarkCollection collection;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _resolveColor(collection.accentColor);
    final IconData? iconData = _resolveIcon(collection.icon);
    final bool hasCoverImage = collection.coverImageUrl != null &&
        collection.coverImageUrl!.isNotEmpty;

    return Dismissible(
      key: ValueKey<int>(collection.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: AppColors.textPrimary,
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Material(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── Cover area ──────────────────────────────────────
              Expanded(
                flex: 3,
                child: _buildCover(accentColor, iconData, hasCoverImage),
              ),

              // ── Info area ───────────────────────────────────────
              Expanded(
                flex: 2,
                child: Padding(
                  padding: AppShapes.cardPaddingInsets,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (collection.isPinned)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.push_pin,
                                size: 14,
                                color: accentColor,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              collection.title,
                              style: AppTypography.cardTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${collection.itemCount} item${collection.itemCount == 1 ? '' : 's'}',
                        style: AppTypography.metadata,
                      ),
                      if (collection.description != null &&
                          collection.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            collection.description!,
                            style: AppTypography.metadata,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(Color accentColor, IconData? iconData, bool hasCoverImage) {
    if (hasCoverImage) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          image: DecorationImage(
            image: NetworkImage(collection.coverImageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
      ),
      child: Center(
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
          ),
          child: Icon(
            iconData ?? Icons.folder,
            size: 24,
            color: accentColor,
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
