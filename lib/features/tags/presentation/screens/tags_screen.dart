import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/tags/presentation/providers/tag_providers.dart';
import 'package:marky/features/tags/presentation/widgets/create_tag_sheet.dart';
import 'package:marky/shared/models/tag.dart';

/// Full-screen tag manager showing all tags with search, create, edit, and delete.
///
/// Watches [tagManagerNotifierProvider] for live CRUD state.
class TagsScreen extends ConsumerStatefulWidget {
  /// Creates a [TagsScreen].
  const TagsScreen({super.key});

  @override
  ConsumerState<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends ConsumerState<TagsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Tag>> tagsAsync =
        ref.watch(tagManagerNotifierProvider);

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
            hintText: 'Search tags…',
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
      body: tagsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (Object error, StackTrace? stackTrace) => _ErrorState(
          onRetry: () =>
              ref.read(tagManagerNotifierProvider.notifier).load(),
        ),
        data: (List<Tag> tags) {
          final List<Tag> filtered = _filterTags(tags, _searchQuery);

          if (filtered.isEmpty && _searchQuery.isEmpty) {
            return const _EmptyState();
          }

          if (filtered.isEmpty) {
            return Center(
              child: Text(
                'No tags matching "$_searchQuery"',
                style: AppTypography.body,
              ),
            );
          }

          return ListView.separated(
            padding: AppShapes.screenPaddingInsets,
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              final Tag tag = filtered[index];
              return _TagListTile(
                tag: tag,
                onTap: () => context.go(Routes.tagDetail.replaceAll(':id', tag.id.toString())),
                onEdit: () => CreateTagSheet.show(context, tag: tag),
                onDelete: tag.isSystemTag
                    ? null
                    : () => _confirmDelete(context, ref, tag),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateTagSheet.show(context),
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.textPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Tag> _filterTags(List<Tag> tags, String query) {
    if (query.isEmpty) return tags;
    return tags
        .where(
          (Tag tag) =>
              tag.name.toLowerCase().contains(query) ||
              tag.slug.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Tag tag,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: Text(
          'Delete "${tag.name}"?',
          style: AppTypography.sectionTitle,
        ),
        content: const Text(
          'This will remove the tag from all bookmarks. This action cannot be undone.',
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
      await ref.read(tagManagerNotifierProvider.notifier).delete(tag.id);
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
            Icons.label_outline,
            size: 64,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tags yet',
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first tag to organize bookmarks',
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
            'Failed to load tags',
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

// ─── Tag list tile ─────────────────────────────────────────────────────

class _TagListTile extends StatelessWidget {
  const _TagListTile({
    required this.tag,
    required this.onTap,
    required this.onEdit,
    this.onDelete,
  });

  final Tag tag;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final Color tagColor = _resolveColor(tag.color);

    return Dismissible(
      key: ValueKey<int>(tag.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
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
        if (onDelete == null) return false;
        onDelete!();
        return false; // Deletion is handled by the callback.
      },
      child: Material(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
        child: InkWell(
          onTap: onTap,
          onLongPress: onEdit,
          borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: tagColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        tag.name,
                        style: AppTypography.cardTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tag.usageCount} bookmark${tag.usageCount == 1 ? '' : 's'}',
                        style: AppTypography.metadata,
                      ),
                    ],
                  ),
                ),
                if (!tag.isSystemTag)
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
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
