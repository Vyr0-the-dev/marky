import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/collections/presentation/providers/collection_providers.dart';
import 'package:marky/features/collections/presentation/widgets/create_collection_sheet.dart';
import 'package:marky/shared/models/collection.dart';

/// Bottom sheet for assigning collections to a bookmark.
///
/// Displays all existing collections as selectable cards. Toggling a card
/// immediately adds or removes the collection from the bookmark via
/// [CollectionAssignmentNotifier]. A "Create new collection" button opens
/// [CreateCollectionSheet].
class CollectionAssignmentSheet extends ConsumerStatefulWidget {
  /// Creates a [CollectionAssignmentSheet].
  const CollectionAssignmentSheet({
    required this.bookmarkId,
    required this.initialCollectionIds,
    super.key,
  });

  /// The ID of the bookmark being organized.
  final int bookmarkId;

  /// The collection IDs currently assigned to the bookmark.
  final List<int> initialCollectionIds;

  /// Shows the sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required int bookmarkId,
    required List<int> initialCollectionIds,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: AppShapes.bottomSheetShape,
      isScrollControlled: true,
      builder: (BuildContext ctx) => CollectionAssignmentSheet(
        bookmarkId: bookmarkId,
        initialCollectionIds: initialCollectionIds,
      ),
    );
  }

  @override
  ConsumerState<CollectionAssignmentSheet> createState() =>
      _CollectionAssignmentSheetState();
}

class _CollectionAssignmentSheetState
    extends ConsumerState<CollectionAssignmentSheet> {
  late Set<int> _selectedCollectionIds;

  @override
  void initState() {
    super.initState();
    _selectedCollectionIds = Set<int>.from(widget.initialCollectionIds);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<BookmarkCollection>> collectionsAsync =
        ref.watch(collectionManagerNotifierProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Drag handle ─────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Title ───────────────────────────────────────────────
          const Padding(
            padding: AppShapes.horizontalScreenPadding,
            child: Text(
              'Assign Collections',
              style: AppTypography.sectionTitle,
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: AppShapes.horizontalScreenPadding,
            child: Text(
              'Select collections to organize this bookmark',
              style: AppTypography.metadata,
            ),
          ),
          const SizedBox(height: 16),

          // ── Collection list ─────────────────────────────────────
          Flexible(
            child: collectionsAsync.when(
              data: (List<BookmarkCollection> collections) {
                if (collections.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildCollectionList(collections);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    color: AppColors.accentPrimary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (Object error, StackTrace? stackTrace) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Failed to load collections',
                    style: AppTypography.body,
                  ),
                ),
              ),
            ),
          ),

          // ── Create new collection button ────────────────────────
          Padding(
            padding: AppShapes.horizontalScreenPadding,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _openCreateCollectionSheet(context),
                icon: const Icon(
                  Icons.add,
                  size: 18,
                  color: AppColors.accentPrimary,
                ),
                label: Text(
                  'Create New Collection',
                  style: AppTypography.label
                      .copyWith(color: AppColors.accentPrimary),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppShapes.radiusStandard),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCollectionList(List<BookmarkCollection> collections) {
    return ListView.builder(
      shrinkWrap: true,
      padding: AppShapes.horizontalScreenPadding,
      itemCount: collections.length,
      itemBuilder: (BuildContext context, int index) {
        final BookmarkCollection collection = collections[index];
        final bool isSelected = _selectedCollectionIds.contains(collection.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _CollectionCard(
            collection: collection,
            isSelected: isSelected,
            onTap: () => _toggleCollection(collection.id, isSelected),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.folder_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 12),
            Text(
              'No collections yet',
              style: AppTypography.cardTitle,
            ),
            SizedBox(height: 4),
            Text(
              'Create your first collection to get started',
              style: AppTypography.metadata,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleCollection(
    int collectionId,
    bool currentlySelected,
  ) async {
    final notifier =
        ref.read(collectionAssignmentNotifierProvider.notifier);

    setState(() {
      if (currentlySelected) {
        _selectedCollectionIds.remove(collectionId);
      } else {
        _selectedCollectionIds.add(collectionId);
      }
    });

    if (currentlySelected) {
      await notifier.removeCollection(widget.bookmarkId, collectionId);
    } else {
      await notifier.addCollection(widget.bookmarkId, collectionId);
    }
  }

  Future<void> _openCreateCollectionSheet(BuildContext context) async {
    await CreateCollectionSheet.show(context);
    // Refresh collection list after creation.
    await ref.read(collectionManagerNotifierProvider.notifier).load();
  }
}

/// A selectable card displaying a collection with icon, color, and title.
class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.collection,
    required this.isSelected,
    required this.onTap,
  });

  final BookmarkCollection collection;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _resolveColor(collection.accentColor);
    final IconData? iconData = _resolveIcon(collection.icon);

    return Material(
      color: isSelected
          ? accentColor.withValues(alpha: 0.12)
          : AppColors.surface2,
      borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: <Widget>[
              // ── Icon / Color circle ─────────────────────────────
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppShapes.radiusMini),
                ),
                child: Icon(
                  iconData ?? Icons.folder,
                  size: 20,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 12),

              // ── Title & count ───────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      collection.title,
                      style: AppTypography.cardTitle.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${collection.itemCount} item${collection.itemCount == 1 ? '' : 's'}',
                      style: AppTypography.metadata,
                    ),
                  ],
                ),
              ),

              // ── Checkbox ────────────────────────────────────────
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                  activeColor: accentColor,
                  checkColor: AppColors.base,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(
                    color: isSelected ? accentColor : AppColors.border,
                    width: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Parses a hex color string or falls back to the default accent.
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

  /// Resolves an icon from its code-point string.
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
