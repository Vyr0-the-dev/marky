import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/tags/presentation/providers/tag_providers.dart';
import 'package:marky/features/tags/presentation/widgets/create_tag_sheet.dart';
import 'package:marky/features/tags/presentation/widgets/tag_chip.dart';
import 'package:marky/shared/models/tag.dart';

/// Bottom sheet for assigning tags to a bookmark.
///
/// Displays all existing tags as selectable chips. Toggling a chip
/// immediately adds or removes the tag from the bookmark via
/// [TagAssignmentNotifier]. A "Create new tag" button opens
/// [CreateTagSheet].
class TagAssignmentSheet extends ConsumerStatefulWidget {
  /// Creates a [TagAssignmentSheet].
  const TagAssignmentSheet({
    required this.bookmarkId,
    required this.initialTagIds,
    super.key,
  });

  /// The ID of the bookmark being tagged.
  final int bookmarkId;

  /// The tag IDs currently assigned to the bookmark.
  final List<int> initialTagIds;

  /// Shows the sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required int bookmarkId,
    required List<int> initialTagIds,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: AppShapes.bottomSheetShape,
      isScrollControlled: true,
      builder: (BuildContext ctx) => TagAssignmentSheet(
        bookmarkId: bookmarkId,
        initialTagIds: initialTagIds,
      ),
    );
  }

  @override
  ConsumerState<TagAssignmentSheet> createState() =>
      _TagAssignmentSheetState();
}

class _TagAssignmentSheetState extends ConsumerState<TagAssignmentSheet> {
  late Set<int> _selectedTagIds;

  @override
  void initState() {
    super.initState();
    _selectedTagIds = Set<int>.from(widget.initialTagIds);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Tag>> tagsAsync =
        ref.watch(tagManagerNotifierProvider);

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
              'Assign Tags',
              style: AppTypography.sectionTitle,
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: AppShapes.horizontalScreenPadding,
            child: Text(
              'Select tags to organize this bookmark',
              style: AppTypography.metadata,
            ),
          ),
          const SizedBox(height: 16),

          // ── Tag list ────────────────────────────────────────────
          Flexible(
            child: tagsAsync.when(
              data: (List<Tag> tags) {
                if (tags.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildTagList(tags);
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
                    'Failed to load tags',
                    style: AppTypography.body,
                  ),
                ),
              ),
            ),
          ),

          // ── Create new tag button ───────────────────────────────
          Padding(
            padding: AppShapes.horizontalScreenPadding,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _openCreateTagSheet(context),
                icon: const Icon(
                  Icons.add,
                  size: 18,
                  color: AppColors.accentPrimary,
                ),
                label: Text(
                  'Create New Tag',
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

  Widget _buildTagList(List<Tag> tags) {
    return ListView.builder(
      shrinkWrap: true,
      padding: AppShapes.horizontalScreenPadding,
      itemCount: tags.length,
      itemBuilder: (BuildContext context, int index) {
        final Tag tag = tags[index];
        final bool isSelected = _selectedTagIds.contains(tag.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TagChip(
            tag: tag,
            isSelected: isSelected,
            showCheckbox: true,
            onTap: () => _toggleTag(tag.id, isSelected),
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
              Icons.label_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 12),
            Text(
              'No tags yet',
              style: AppTypography.cardTitle,
            ),
            SizedBox(height: 4),
            Text(
              'Create your first tag to get started',
              style: AppTypography.metadata,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleTag(int tagId, bool currentlySelected) async {
    final notifier = ref.read(tagAssignmentNotifierProvider.notifier);

    setState(() {
      if (currentlySelected) {
        _selectedTagIds.remove(tagId);
      } else {
        _selectedTagIds.add(tagId);
      }
    });

    if (currentlySelected) {
      await notifier.removeTag(widget.bookmarkId, tagId);
    } else {
      await notifier.addTag(widget.bookmarkId, tagId);
    }
  }

  Future<void> _openCreateTagSheet(BuildContext context) async {
    await CreateTagSheet.show(context);
    // Refresh tag list after creation.
    await ref.read(tagManagerNotifierProvider.notifier).load();
  }
}
