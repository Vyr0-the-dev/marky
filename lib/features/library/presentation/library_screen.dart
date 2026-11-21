import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/utils/color_contrast_utils.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/smart_collection_evaluator.dart';
import 'package:marky/features/home/presentation/feed_notifier.dart';
import 'package:marky/features/library/presentation/widgets/collection_editor_sheet.dart';
import 'package:marky/features/library/presentation/widgets/create_collection_sheet.dart';
import 'package:marky/features/library/presentation/widgets/create_tag_sheet.dart';
import 'package:marky/features/library/presentation/widgets/tag_editor_sheet.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/errors/safe_error_details.dart';

/// Library tab — tag directory, collection directory, archive entry.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.libraryTitle ?? 'Library',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        actions: const <Widget>[],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ReadingRoomSpacing.lg,
          ReadingRoomSpacing.md,
          ReadingRoomSpacing.lg,
          88,
        ),
        children: <Widget>[
          _LibraryQuickTools(l10n: l10n),
          const SizedBox(height: ReadingRoomSpacing.lg),
          _SectionHeader(
            title: l10n?.libraryTagsTitle ?? 'Tags',
            tooltip: l10n?.actionAddTag ?? 'Add tag',
            onAdd: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const CreateTagSheet(),
            ),
          ),
          const _TagGrid(),
          const SizedBox(height: ReadingRoomSpacing.xl),
          _SectionHeader(
            title: l10n?.libraryCollectionsTitle ?? 'Collections',
            tooltip: l10n?.actionAddCollection ?? 'Add collection',
            onAdd: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const CreateCollectionSheet(),
            ),
          ),
          const _CollectionList(),
          const SizedBox(height: ReadingRoomSpacing.md),
          const _ArchivedCollectionsSection(),
        ],
      ),
    );
  }
}

// ─── Section header ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.tooltip,
    required this.onAdd,
  });

  final String title;
  final String tooltip;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Text(title, style: theme.textTheme.titleMedium),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.add, size: 20),
          onPressed: onAdd,
          tooltip: tooltip,
        ),
      ],
    );
  }
}

// ─── Tag grid ───────────────────────────────────────────────────

class _TagGrid extends ConsumerWidget {
  const _TagGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Tag>> tagsAsync = ref.watch(tagsProvider);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return tagsAsync.when(
      data: (List<Tag> tags) {
        if (tags.isEmpty) {
          return _InlineLibraryState(
            icon: Icons.sell_outlined,
            message: l10n?.libraryNoTags ?? 'No tags yet. Tap + to create one.',
          );
        }

        return Wrap(
          spacing: ReadingRoomSpacing.sm,
          runSpacing: ReadingRoomSpacing.sm,
          children: tags.map((Tag tag) => _TagChip(tag: tag)).toList(),
        );
      },
      loading: () => _InlineLibraryState(
        icon: Icons.sell_outlined,
        message: l10n?.libraryLoadingTags ?? 'Loading tags...',
      ),
      error: (Object e, _) => _InlineLibraryState(
        icon: Icons.error_outline_rounded,
        message: l10n?.libraryCouldNotLoadTags ?? 'Could not load tags.',
        detail: debugOnlyErrorDetails(e),
        tone: _InlineLibraryStateTone.error,
      ),
    );
  }
}

class _TagChip extends ConsumerWidget {
  const _TagChip({required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TagColorStyle tagStyle = ColorContrastUtils.resolveTagStyle(
      colorArgb: tag.colorArgb,
      context: context,
    );

    return Semantics(
      button: true,
      label: 'Open tag ${tag.name}',
      hint: 'Long press to edit or delete tag.',
      child: GestureDetector(
        onLongPress: () => _openEditor(context),
        child: ActionChip(
          label: _TagChipLabel(tag: tag, textColor: tagStyle.textColor),
          avatar: tag.isPinned
              ? Icon(
                  Icons.push_pin,
                  size: 14,
                  color: tagStyle.textColor,
                )
              : null,
          onPressed: () {
            ref.read(feedNotifierProvider.notifier).setTagId(tag.id);
            context.go(Routes.home);
          },
          backgroundColor: tagStyle.backgroundColor,
          side: BorderSide(color: tagStyle.borderColor, width: 0.5),
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TagEditorSheet(initial: tag),
    );
  }
}

/// Inline label for [_TagChip] that shows the tag name plus a small
/// usage-count badge when the tag has at least one bookmark.
class _TagChipLabel extends StatelessWidget {
  const _TagChipLabel({required this.tag, this.textColor});

  final Tag tag;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    if (tag.usageCount <= 0) {
      return Text(
        tag.name,
        style: textColor != null ? TextStyle(color: textColor) : null,
      );
    }
    final ThemeData theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          tag.name,
          style: textColor != null ? TextStyle(color: textColor) : null,
        ),
        const SizedBox(width: ReadingRoomSpacing.xs),
        Text(
          '${tag.usageCount}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: textColor?.withValues(alpha: 0.8) ??
                theme.colorScheme.onSurfaceVariant,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ─── Collection list ────────────────────────────────────────────

class _CollectionList extends ConsumerWidget {
  const _CollectionList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BookmarkCollection>> collectionsAsync =
        ref.watch(bookmarkCollectionsProvider);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return collectionsAsync.when(
      data: (List<BookmarkCollection> collections) {
        if (collections.isEmpty) {
          return _InlineLibraryState(
            icon: Icons.folder_outlined,
            message: l10n?.libraryNoCollections ??
                'No collections yet. Tap + to create one.',
          );
        }

        return Column(
          children: collections
              .map((BookmarkCollection c) => _CollectionTile(collection: c))
              .toList(),
        );
      },
      loading: () => _InlineLibraryState(
        icon: Icons.folder_outlined,
        message: l10n?.libraryLoadingCollections ?? 'Loading collections...',
      ),
      error: (Object e, _) => _InlineLibraryState(
        icon: Icons.error_outline_rounded,
        message: l10n?.libraryCouldNotLoadCollections ??
            'Could not load collections.',
        detail: debugOnlyErrorDetails(e),
        tone: _InlineLibraryStateTone.error,
      ),
    );
  }
}

class _CollectionTitle extends StatelessWidget {
  const _CollectionTitle({required this.collection});

  final BookmarkCollection collection;

  @override
  Widget build(BuildContext context) {
    if (!collection.isSmart) return Text(collection.title);
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(child: Text(collection.title)),
        const SizedBox(width: ReadingRoomSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ReadingRoomSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            l10n?.librarySmartBadge ?? 'SMART',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectionTile extends ConsumerWidget {
  const _CollectionTile({required this.collection});

  final BookmarkCollection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final Color accent = collection.accentColorArgb != null
        ? Color(collection.accentColorArgb!)
        : theme.colorScheme.primary;

    return Semantics(
      button: true,
      label: 'Open collection ${collection.title}',
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.15),
          child: collection.icon != null
              ? Text(collection.icon!, style: const TextStyle(fontSize: 18))
              : Icon(Icons.folder_outlined, color: accent),
        ),
        title: _CollectionTitle(collection: collection),
        subtitle: Text(
          collection.isSmart
              ? l10n?.libraryLiveSmartCollection ?? 'Live smart collection'
              : l10n?.libraryCollectionItemCount(collection.itemCount) ??
                  '${collection.itemCount} items',
        ),
        trailing: PopupMenuButton<String>(
          tooltip:
              l10n?.libraryCollectionActionsTooltip ?? 'Collection actions',
          onSelected: (String value) => _onAction(context, ref, value),
          itemBuilder: (_) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'edit',
              child: Text(l10n?.actionEdit ?? 'Edit'),
            ),
            PopupMenuItem<String>(
              value: 'archive',
              child: Text(l10n?.actionArchive ?? 'Archive'),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Text(l10n?.actionDelete ?? 'Delete'),
            ),
          ],
        ),
        onTap: () {
          if (collection.isSmart) {
            final SmartCollectionEvaluator evaluator =
                ref.read(smartCollectionEvaluatorProvider);
            final query = evaluator.queryFor(collection);
            if (query == null) return;
            ref.read(feedNotifierProvider.notifier).applyQuery(
                  query,
                  filterLabel: collection.title,
                );
          } else {
            ref
                .read(feedNotifierProvider.notifier)
                .setCollectionId(collection.id);
          }
          context.go(Routes.home);
        },
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    if (collection.id == null) return;
    final BookmarkCollectionRepository repo =
        ref.read(bookmarkCollectionRepositoryProvider);

    switch (action) {
      case 'edit':
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => CollectionEditorSheet(initial: collection),
        );
      case 'archive':
        await repo.save(collection.copyWith(isArchived: true));
      case 'delete':
        final AppLocalizations? l10n = AppLocalizations.of(context);
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) => AlertDialog(
            title: Text(
              l10n?.libraryDeleteCollectionTitle(collection.title) ??
                  'Delete "${collection.title}"?',
            ),
            content: Text(
              l10n?.libraryDeleteCollectionMessage ??
                  'Bookmarks inside will not be deleted.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n?.actionCancel ?? 'Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n?.actionDelete ?? 'Delete'),
              ),
            ],
          ),
        );
        if (confirmed ?? false) {
          await repo.delete(collection.id!);
        }
    }
  }
}

enum _InlineLibraryStateTone { neutral, error }

class _InlineLibraryState extends StatelessWidget {
  const _InlineLibraryState({
    required this.icon,
    required this.message,
    this.detail,
    this.tone = _InlineLibraryStateTone.neutral,
  });

  final IconData icon;
  final String message;
  final String? detail;
  final _InlineLibraryStateTone tone;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = tone == _InlineLibraryStateTone.error
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: ReadingRoomSpacing.sm),
      padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: detail == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: accent),
          const SizedBox(width: ReadingRoomSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (detail != null) ...<Widget>[
                  const SizedBox(height: ReadingRoomSpacing.xs),
                  Text(
                    detail!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryQuickTools extends StatelessWidget {
  const _LibraryQuickTools({required this.l10n});

  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: _QuickToolCard(
            icon: Icons.notifications_active_outlined,
            label: l10n?.remindersAppBarTitle ?? 'Reminders',
            onTap: () => context.push(Routes.reminders),
            theme: theme,
          ),
        ),
        const SizedBox(width: ReadingRoomSpacing.sm),
        Expanded(
          child: _QuickToolCard(
            icon: Icons.bar_chart_rounded,
            label: l10n?.dashboardTitle ?? 'Dashboard',
            onTap: () => context.push(Routes.stats),
            theme: theme,
          ),
        ),
        const SizedBox(width: ReadingRoomSpacing.sm),
        Expanded(
          child: _QuickToolCard(
            icon: Icons.health_and_safety_outlined,
            label: l10n?.brokenLinksShortTitle ?? 'Link Check',
            onTap: () => context.push(Routes.brokenLinks),
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _QuickToolCard extends StatelessWidget {
  const _QuickToolCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ReadingRoomSpacing.sm,
            vertical: ReadingRoomSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(height: ReadingRoomSpacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchivedCollectionsSection extends ConsumerWidget {
  const _ArchivedCollectionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BookmarkCollection>> allAsync =
        ref.watch(bookmarkCollectionsWithArchivedProvider);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return allAsync.maybeWhen(
      data: (List<BookmarkCollection> all) {
        final List<BookmarkCollection> archived =
            all.where((BookmarkCollection c) => c.isArchived).toList();
        if (archived.isEmpty) return const SizedBox.shrink();

        return ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          shape: const Border(),
          collapsedShape: const Border(),
          leading: const Icon(Icons.archive_outlined, size: 20),
          title: Text(
            '${l10n?.filterArchived ?? 'Archived'} (${archived.length})',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          children: archived.map((BookmarkCollection c) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.folder_outlined),
              title: Text(c.title),
              trailing: TextButton(
                onPressed: () async {
                  await ref
                      .read(bookmarkCollectionRepositoryProvider)
                      .save(c.copyWith(isArchived: false));
                },
                child: Text(l10n?.actionUnarchive ?? 'Unarchive'),
              ),
            );
          }).toList(),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
