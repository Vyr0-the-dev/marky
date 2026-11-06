import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/home/presentation/feed_notifier.dart';
import 'package:marky/features/notes/data/note_providers.dart';
import 'package:marky/features/notes/domain/note.dart';
import 'package:marky/features/notes/domain/note_repository.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/reminders/presentation/create_reminder_sheet.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/errors/safe_error_details.dart';
import 'package:marky/shared/widgets/marky_error_state.dart';
import 'package:marky/shared/widgets/marky_loading_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full detail view for a single bookmark.
///
/// Receives the bookmark [id] from the route parameter, subscribes
/// to [bookmarkByIdProvider] so background scraping and edits push
/// live updates, and auto-pops when the bookmark is deleted.
class DetailScreen extends ConsumerWidget {
  const DetailScreen({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final AsyncValue<Bookmark?> async = ref.watch(bookmarkByIdProvider(id));

    return async.when(
      data: (Bookmark? bookmark) {
        if (bookmark == null) {
          // Bookmark was deleted while this screen was open.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.of(context).maybePop();
          });
          return Scaffold(
            body: Center(
              child: Text(l10n?.detailBookmarkDeleted ?? 'Bookmark deleted'),
            ),
          );
        }
        return _DetailBody(bookmark: bookmark);
      },
      loading: () => const Scaffold(body: MarkyLoadingState()),
      error: (Object error, _) => Scaffold(
        appBar: AppBar(),
        body: MarkyErrorState(
          title: l10n?.detailCouldNotLoadBookmark ?? 'Could not load bookmark',
          body: l10n?.errorGenericTitle ?? 'Something went wrong',
          detail: debugOnlyErrorDetails(error),
          onRetry: () => ref.invalidate(bookmarkByIdProvider(id)),
        ),
      ),
    );
  }
}

// ─── Body ───────────────────────────────────────────────────────

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // ── Hero image app bar ──────────────────────────────
          _HeroAppBar(bookmark: bookmark),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ReadingRoomSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: ReadingRoomSpacing.lg),

                  // ── Title ────────────────────────────────────
                  Text(
                    bookmark.displayTitle,
                    style: theme.textTheme.headlineSmall,
                  ),

                  const SizedBox(height: ReadingRoomSpacing.sm),

                  // ── Domain + source chip ─────────────────────
                  _DomainRow(bookmark: bookmark),

                  // ── Description ──────────────────────────────
                  if (bookmark.description != null &&
                      bookmark.description!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: ReadingRoomSpacing.lg),
                    Text(
                      bookmark.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],

                  // ── Actions ──────────────────────────────────
                  const SizedBox(height: ReadingRoomSpacing.xl),
                  _ActionsRow(bookmark: bookmark),

                  // ── Metadata block ───────────────────────────
                  const SizedBox(height: ReadingRoomSpacing.xl),
                  _MetadataBlock(bookmark: bookmark),

                  // ── Tags ─────────────────────────────────────
                  const SizedBox(height: ReadingRoomSpacing.xl),
                  _TagsSection(bookmark: bookmark),

                  // ── Collections ──────────────────────────────
                  const SizedBox(height: ReadingRoomSpacing.xl),
                  _CollectionsSection(bookmark: bookmark),

                  // ── Notes ────────────────────────────────────
                  const SizedBox(height: ReadingRoomSpacing.xl),
                  _NotesSection(bookmark: bookmark),

                  // ── Reminders ────────────────────────────────
                  const SizedBox(height: ReadingRoomSpacing.xl),
                  _RemindersSection(bookmark: bookmark),

                  const SizedBox(height: ReadingRoomSpacing.huge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero app bar ───────────────────────────────────────────────

class _HeroAppBar extends StatelessWidget {
  const _HeroAppBar({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = bookmark.heroImageUrl ?? bookmark.faviconUrl;
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    if (!hasImage) {
      return SliverAppBar(
        pinned: true,
        expandedHeight: 0,
        backgroundColor: theme.colorScheme.surface,
      );
    }

    return SliverAppBar(
      pinned: true,
      expandedHeight: 220,
      backgroundColor: theme.colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
              onTap: () => _openImagePreview(context, imageUrl, bookmark),
              child: ColoredBox(
                color: Colors.black,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  semanticLabel:
                      l10n?.detailPreviewImageLabel(bookmark.displayTitle) ??
                          'Preview image for ${bookmark.displayTitle}',
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withValues(alpha: 0.38),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.34),
                    ],
                    stops: const <double>[0, 0.22, 0.72, 1],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImagePreview(
    BuildContext context,
    String imageUrl,
    Bookmark bookmark,
  ) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: InteractiveViewer(
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      semanticLabel: l10n?.detailPreviewImageLabel(
                              bookmark.displayTitle) ??
                          'Preview image for ${bookmark.displayTitle}',
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white70,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: l10n?.actionClose ?? 'Close',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Domain row ─────────────────────────────────────────────────

class _DomainRow extends ConsumerWidget {
  const _DomainRow({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final String domain = bookmark.normalizedHost ?? '';

    return Row(
      children: <Widget>[
        if (domain.isNotEmpty) ...<Widget>[
          Icon(Icons.language,
              size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: ReadingRoomSpacing.xs),
          // Tap the domain to jump back to the feed filtered by host —
          // a "show me everything else from this site" shortcut.
          Semantics(
            button: true,
            label: l10n?.detailFilterByDomainLabel(domain) ??
                'Filter by domain $domain',
            child: ExcludeSemantics(
              child: InkWell(
                onTap: () => _filterByHost(context, ref, domain),
                borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    domain,
                    style: ReadingRoomTextStyles.metadata(context).copyWith(
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.dotted,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: ReadingRoomSpacing.md),
        ],
        Text(
          _formatContentType(bookmark.contentType.name),
          style: ReadingRoomTextStyles.metadata(context),
        ),
        if (bookmark.scrapingStatus ==
            BookmarkScrapingStatus.processing) ...<Widget>[
          const SizedBox(width: ReadingRoomSpacing.sm),
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  void _filterByHost(BuildContext context, WidgetRef ref, String host) {
    ref.read(feedNotifierProvider.notifier).setHost(host);
    context.go(Routes.home);
  }

  static String _formatContentType(String raw) {
    if (raw.isEmpty) return '';
    return raw[0].toUpperCase() + raw.substring(1);
  }
}

// ─── Actions row ────────────────────────────────────────────────

class _ActionsRow extends ConsumerWidget {
  const _ActionsRow({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    final List<_ActionChip> actions = <_ActionChip>[
      _ActionChip(
        icon: Icons.open_in_browser,
        label: l10n?.actionOpen ?? 'Open',
        onTap: () => _openInBrowser(context),
      ),
      _ActionChip(
        icon: Icons.copy,
        label: l10n?.actionCopy ?? 'Copy',
        onTap: () => _copyUrl(context),
      ),
      _ActionChip(
        icon: Icons.edit_outlined,
        label: l10n?.actionEdit ?? 'Edit',
        onTap: () => _editTitleAndDescription(context, ref),
      ),
      _ActionChip(
        icon: Icons.refresh_rounded,
        label: l10n?.detailActionRefetch ?? 'Refetch',
        onTap: () => _refetchMetadata(context, ref),
      ),
      _ActionChip(
        icon: bookmark.isFavorite ? Icons.favorite : Icons.favorite_outline,
        label: bookmark.isFavorite
            ? l10n?.detailActionUnfavorite ?? 'Unfav'
            : l10n?.labelFavorite ?? 'Favorite',
        onTap: () =>
            _toggle(ref, (Bookmark b) => b.copyWith(isFavorite: !b.isFavorite)),
      ),
      _ActionChip(
        icon: bookmark.isArchived ? Icons.unarchive : Icons.archive_outlined,
        label: bookmark.isArchived
            ? l10n?.detailActionUnarchive ?? 'Unarchive'
            : l10n?.actionArchive ?? 'Archive',
        onTap: () =>
            _toggle(ref, (Bookmark b) => b.copyWith(isArchived: !b.isArchived)),
      ),
      _ActionChip(
        icon:
            bookmark.isRead ? Icons.visibility_off : Icons.check_circle_outline,
        label: bookmark.isRead
            ? l10n?.detailActionUnread ?? 'Unread'
            : l10n?.detailActionRead ?? 'Read',
        onTap: () => _toggleRead(ref),
      ),
      _ActionChip(
        icon: bookmark.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
        label: bookmark.isPinned
            ? l10n?.detailActionUnpin ?? 'Unpin'
            : l10n?.detailActionPin ?? 'Pin',
        onTap: () =>
            _toggle(ref, (Bookmark b) => b.copyWith(isPinned: !b.isPinned)),
      ),
      _ActionChip(
        icon: Icons.share_outlined,
        label: l10n?.actionShare ?? 'Share',
        onTap: _share,
      ),
      _ActionChip(
        icon: Icons.delete_outline,
        label: l10n?.actionDelete ?? 'Delete',
        color: theme.colorScheme.error,
        onTap: () => _delete(context, ref),
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double itemWidth =
            constraints.maxWidth >= 360 ? (constraints.maxWidth - 16) / 3 : 112;
        return Wrap(
          spacing: ReadingRoomSpacing.sm,
          runSpacing: ReadingRoomSpacing.sm,
          children: actions
              .map(
                (_ActionChip action) => SizedBox(
                  width: itemWidth,
                  child: action,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Future<void> _openInBrowser(BuildContext context) async {
    final Uri? uri =
        Uri.tryParse(bookmark.canonicalUrl ?? bookmark.originalUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _copyUrl(BuildContext context) {
    final String url = bookmark.canonicalUrl ?? bookmark.originalUrl;
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.detailLinkCopied ?? 'Link copied',
          ),
        ),
      );
  }

  Future<void> _editTitleAndDescription(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final String initialTitle = bookmark.title?.trim() ?? '';
    final TextEditingController titleController = TextEditingController(
      text: initialTitle.isNotEmpty ? initialTitle : bookmark.displayTitle,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: bookmark.description ?? '',
    );
    try {
      final AppLocalizations? l10n = AppLocalizations.of(context);
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: Text(l10n?.actionEdit ?? 'Edit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: l10n?.captureTitleLabel ?? 'Title',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: ReadingRoomSpacing.md),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n?.detailDescriptionLabel ?? 'Description',
                  ),
                  minLines: 3,
                  maxLines: 6,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n?.actionCancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n?.actionSave ?? 'Save'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ref.read(bookmarkRepositoryProvider).save(
            bookmark.copyWith(
              title: titleController.text.trim(),
              description: descriptionController.text.trim(),
            ),
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.snackbarBookmarkUpdated ??
                  'Bookmark updated',
            ),
          ),
        );
    } finally {
      titleController.dispose();
      descriptionController.dispose();
    }
  }

  Future<void> _share() async {
    final String url = bookmark.canonicalUrl ?? bookmark.originalUrl;
    final String? title = bookmark.title;
    await Share.share(
      url,
      subject: title,
    );
  }

  Future<void> _refetchMetadata(BuildContext context, WidgetRef ref) async {
    if (bookmark.id == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context)?.detailRefetchingMetadata ??
                    'Refetching metadata…')),
      );
    await ref.read(scrapingOrchestratorProvider).enrich(bookmark.id!);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context)?.detailMetadataRefreshed ??
                    'Metadata refreshed')),
      );
  }

  Future<void> _toggle(
    WidgetRef ref,
    Bookmark Function(Bookmark) transform,
  ) async {
    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    await repo.save(transform(bookmark));
  }

  Future<void> _toggleRead(WidgetRef ref) async {
    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    await repo.save(bookmark.copyWith(isRead: !bookmark.isRead));
    final AppSettings settings = ref.read(appSettingsProvider);
    final UnreadReminderCadence cadence = settings.unreadReminderCadence;
    if (cadence != UnreadReminderCadence.off) {
      try {
        await ref.read(unreadReminderSchedulerProvider).sync(
              cadence,
              weekday: settings.unreadReminderWeekday,
              hour: settings.unreadReminderHour,
              minute: settings.unreadReminderMinute,
            );
      } on Object {
        return;
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.dialogDeleteTitle ?? 'Delete bookmark?',
        ),
        content: Text(
          AppLocalizations.of(context)?.detailDeleteMessage ??
              'This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context)?.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(context)?.actionDelete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (bookmark.id == null) return;
    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    await repo.delete(bookmark.id!);
    // Stream will emit null → screen auto-pops.
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color effectiveColor = color ?? theme.colorScheme.onSurface;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReadingRoomRadii.chip),
          side: BorderSide(
            color: effectiveColor.withValues(alpha: 0.32),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ReadingRoomSpacing.sm,
              vertical: ReadingRoomSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 18, color: effectiveColor),
                const SizedBox(width: ReadingRoomSpacing.xs),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: effectiveColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Metadata block ─────────────────────────────────────────────

class _MetadataBlock extends StatelessWidget {
  const _MetadataBlock({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle metaStyle = ReadingRoomTextStyles.metadata(context);
    final TextStyle valueStyle = theme.textTheme.bodySmall!;
    final AppLocalizations? l10n = AppLocalizations.of(context);

    final List<_MetaRow> rows = <_MetaRow>[
      if (bookmark.author != null)
        _MetaRow(l10n?.detailMetaAuthor ?? 'Author', bookmark.author!),
      if (bookmark.siteName != null)
        _MetaRow(l10n?.detailMetaSite ?? 'Site', bookmark.siteName!),
      if (bookmark.publisher != null)
        _MetaRow(l10n?.detailMetaPublisher ?? 'Publisher', bookmark.publisher!),
      if (bookmark.canonicalUrl != null)
        _MetaRow(
            l10n?.detailMetaCanonical ?? 'Canonical', bookmark.canonicalUrl!),
      _MetaRow(
          l10n?.detailMetaSaved ?? 'Saved', _formatDate(bookmark.createdAt)),
      if (bookmark.publishDate != null)
        _MetaRow(l10n?.detailMetaPublished ?? 'Published',
            _formatDate(bookmark.publishDate)),
      if (bookmark.lastOpenedAt != null)
        _MetaRow(l10n?.detailMetaLastOpened ?? 'Last opened',
            _formatDate(bookmark.lastOpenedAt)),
      _MetaRow(
        l10n?.detailMetaOpened ?? 'Opened',
        l10n?.detailOpenedTimes(bookmark.openCount) ??
            '${bookmark.openCount} times',
      ),
      _MetaRow(l10n?.detailMetaSource ?? 'Source', bookmark.sourceType.name),
      _MetaRow(l10n?.detailMetaType ?? 'Type', bookmark.contentType.name),
      _MetaRow(
        l10n?.detailMetaScraping ?? 'Scraping',
        bookmark.scrapingStatus.name,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ReadingRoomSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n?.detailMetadataTitle ?? 'Metadata',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: ReadingRoomSpacing.sm),
          ...rows.map((_MetaRow r) => Padding(
                padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 90,
                      child: Text(r.label, style: metaStyle),
                    ),
                    Expanded(
                      child: Text(
                        r.value,
                        style: valueStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '–';
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
        '${_pad(dt.hour)}:${_pad(dt.minute)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}

class _MetaRow {
  const _MetaRow(this.label, this.value);
  final String label;
  final String value;
}

// ─── Reminders section ──────────────────────────────────────────

class _RemindersSection extends ConsumerWidget {
  const _RemindersSection({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    if (bookmark.id == null) return const SizedBox.shrink();

    final AsyncValue<List<Reminder>> remindersAsync =
        ref.watch(remindersForBookmarkProvider(bookmark.id!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              l10n?.detailRemindersTitle ?? 'Reminders',
              style: theme.textTheme.titleSmall,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_alarm, size: 20),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => CreateReminderSheet(
                  bookmarkId: bookmark.id!,
                  bookmarkTitle: bookmark.displayTitle,
                ),
              ),
              tooltip: l10n?.detailAddReminderTooltip ?? 'Add reminder',
            ),
          ],
        ),
        remindersAsync.when(
          data: (List<Reminder> reminders) {
            if (reminders.isEmpty) {
              return Text(
                l10n?.detailNoReminders ?? 'No reminders set.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }

            return Column(
              children: reminders
                  .map((Reminder r) => _ReminderTile(reminder: r))
                  .toList(),
            );
          },
          loading: () => const SizedBox(
            height: 32,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (Object e, _) => Text(
            l10n?.detailInlineError(e) ?? 'Error: $e',
          ),
        ),
      ],
    );
  }
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final bool past = reminder.effectiveFireAt.isBefore(DateTime.now());

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        past ? Icons.alarm_off : Icons.alarm,
        size: 18,
        color: past
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.primary,
      ),
      title: Text(
        _formatDate(reminder.effectiveFireAt),
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Text(
        reminder.status.name,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: reminder.isActive
          ? IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () => _cancel(ref),
              tooltip: l10n?.actionCancel ?? 'Cancel',
            )
          : null,
    );
  }

  Future<void> _cancel(WidgetRef ref) async {
    if (reminder.id == null) return;
    await ref.read(reminderSchedulerProvider).cancelReminder(reminder.id!);
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
        '${_pad(dt.hour)}:${_pad(dt.minute)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}

// ─── Tags section ───────────────────────────────────────────────

class _TagsSection extends ConsumerWidget {
  const _TagsSection({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              l10n?.tagsTitle ?? 'Tags',
              style: theme.textTheme.titleSmall,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              tooltip: l10n?.actionAddTag ?? 'Add tag',
              onPressed: () => _showAddTagSheet(context, ref),
            ),
          ],
        ),
        if (bookmark.tagIds.isNotEmpty) ...<Widget>[
          const SizedBox(height: ReadingRoomSpacing.sm),
          _TagChipsEditable(
            bookmark: bookmark,
          ),
        ] else
          Text(
            l10n?.detailTagsEmpty ?? 'Tap + to add tags',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Future<void> _showAddTagSheet(BuildContext context, WidgetRef ref) async {
    final List<Tag> allTags = await ref.read(tagRepositoryProvider).getAll();
    final Set<int> current = bookmark.tagIds.toSet();
    final List<Tag> available = allTags
        .where((Tag t) => t.id != null && !current.contains(t.id))
        .toList();

    if (!context.mounted) return;
    final AppLocalizations? l10n = AppLocalizations.of(context);

    final int? selectedTagId = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext ctx) => ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
            child: Text(
              l10n?.detailAddTagTitle ?? 'Add tag',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          if (available.isEmpty)
            Padding(
              padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
              child: Text(
                l10n?.detailAllTagsAlreadyAdded ?? 'All tags already added.',
              ),
            ),
          ...available.map((Tag tag) => ListTile(
                title: Text(tag.name),
                leading: tag.colorArgb != null
                    ? CircleAvatar(
                        radius: 10,
                        backgroundColor: Color(tag.colorArgb!),
                      )
                    : null,
                onTap: () => Navigator.of(ctx).pop(tag.id),
              )),
        ],
      ),
    );

    if (selectedTagId == null) return;

    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    await repo.save(bookmark.copyWith(
      tagIds: <int>[...bookmark.tagIds, selectedTagId],
    ));
    await ref.read(tagRepositoryProvider).incrementUsageCount(selectedTagId);
  }
}

// ─── Editable tag chips (with delete) ───────────────────────────

class _TagChipsEditable extends ConsumerWidget {
  const _TagChipsEditable({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: ReadingRoomSpacing.sm,
      runSpacing: ReadingRoomSpacing.xs,
      children: bookmark.tagIds.map((int id) {
        final AsyncValue<Tag?> tagAsync = ref.watch(tagByIdProvider(id));
        return tagAsync.when(
          data: (Tag? tag) {
            if (tag == null) return const SizedBox.shrink();
            final Color? c =
                tag.colorArgb != null ? Color(tag.colorArgb!) : null;
            return InputChip(
              label: Text(tag.name),
              backgroundColor: c?.withValues(alpha: 0.15),
              side: c != null
                  ? BorderSide(color: c.withValues(alpha: 0.4))
                  : null,
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => _removeTag(ref, id),
            );
          },
          loading: () => const Chip(label: Text('…')),
          error: (_, __) => Chip(
            label: Text(l10n?.detailMissingTagLabel(id) ?? 'Tag #$id'),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _removeTag(WidgetRef ref, int tagId) async {
    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    final List<int> updated =
        bookmark.tagIds.where((int id) => id != tagId).toList();
    await repo.save(bookmark.copyWith(tagIds: updated));
    await ref.read(tagRepositoryProvider).decrementUsageCount(tagId);
  }
}

// ─── Collections section ────────────────────────────────────────

class _CollectionsSection extends ConsumerWidget {
  const _CollectionsSection({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              l10n?.collectionsTitle ?? 'Collections',
              style: theme.textTheme.titleSmall,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              tooltip: l10n?.detailAddToCollectionTitle ?? 'Add to collection',
              onPressed: () => _showAddCollectionSheet(context, ref),
            ),
          ],
        ),
        if (bookmark.collectionIds.isNotEmpty) ...<Widget>[
          const SizedBox(height: ReadingRoomSpacing.sm),
          _CollectionChipsEditable(bookmark: bookmark),
        ] else
          Text(
            l10n?.detailCollectionsEmpty ?? 'Tap + to add to a collection',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Future<void> _showAddCollectionSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final List<BookmarkCollection> all =
        await ref.read(bookmarkCollectionRepositoryProvider).getAll();
    final Set<int> current = bookmark.collectionIds.toSet();
    final List<BookmarkCollection> available = all
        .where(
            (BookmarkCollection c) => c.id != null && !current.contains(c.id))
        .toList();

    if (!context.mounted) return;
    final AppLocalizations? l10n = AppLocalizations.of(context);

    final int? selectedId = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext ctx) => ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
            child: Text(
              l10n?.detailAddToCollectionTitle ?? 'Add to collection',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          if (available.isEmpty)
            Padding(
              padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
              child: Text(
                l10n?.detailNoCollectionsLeft ??
                    'No collections left to add to.',
              ),
            ),
          ...available.map((BookmarkCollection c) => ListTile(
                leading: c.accentColorArgb != null
                    ? CircleAvatar(
                        radius: 10,
                        backgroundColor: Color(c.accentColorArgb!),
                      )
                    : const Icon(Icons.folder_outlined),
                title: Text(c.title),
                subtitle: Text(
                  l10n?.libraryCollectionItemCount(c.itemCount) ??
                      '${c.itemCount} items',
                ),
                onTap: () => Navigator.of(ctx).pop(c.id),
              )),
        ],
      ),
    );

    if (selectedId == null) return;

    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    await repo.save(bookmark.copyWith(
      collectionIds: <int>[...bookmark.collectionIds, selectedId],
    ));
    await ref
        .read(bookmarkCollectionRepositoryProvider)
        .incrementItemCount(selectedId);
  }
}

// ─── Editable collection chips (with delete) ────────────────────

class _CollectionChipsEditable extends ConsumerWidget {
  const _CollectionChipsEditable({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: ReadingRoomSpacing.sm,
      runSpacing: ReadingRoomSpacing.xs,
      children: bookmark.collectionIds.map((int id) {
        final AsyncValue<BookmarkCollection?> async =
            ref.watch(bookmarkCollectionByIdProvider(id));
        return async.when(
          data: (BookmarkCollection? c) {
            if (c == null) return const SizedBox.shrink();
            final Color? accent =
                c.accentColorArgb != null ? Color(c.accentColorArgb!) : null;
            return InputChip(
              avatar: const Icon(Icons.folder_outlined, size: 14),
              label: Text(c.title),
              backgroundColor: accent?.withValues(alpha: 0.15),
              side: accent != null
                  ? BorderSide(color: accent.withValues(alpha: 0.4))
                  : null,
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => _remove(ref, id),
            );
          },
          loading: () => const Chip(label: Text('…')),
          error: (_, __) => Chip(
            label: Text(
              l10n?.detailMissingCollectionLabel(id) ?? 'Collection #$id',
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _remove(WidgetRef ref, int collectionId) async {
    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    final List<int> updated =
        bookmark.collectionIds.where((int id) => id != collectionId).toList();
    await repo.save(bookmark.copyWith(collectionIds: updated));
    await ref
        .read(bookmarkCollectionRepositoryProvider)
        .decrementItemCount(collectionId);
  }
}

// ─── Notes section ──────────────────────────────────────────────

/// Multi-note timeline for a bookmark.
///
/// Each note is its own timestamped entry — distinct from
/// `Bookmark.inlineNotes` (a single legacy string we still respect
/// for back-compat). When a legacy string is present we surface a
/// "Convert to note" CTA; once converted, the legacy field is
/// cleared and the note joins the timeline.
class _NotesSection extends ConsumerWidget {
  const _NotesSection({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    if (bookmark.id == null) return const SizedBox.shrink();

    final AsyncValue<List<Note>> notesAsync =
        ref.watch(notesByBookmarkProvider(bookmark.id!));
    final bool hasLegacyNote =
        bookmark.inlineNotes != null && bookmark.inlineNotes!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              l10n?.detailNotesTitle ?? 'Notes',
              style: theme.textTheme.titleSmall,
            ),
            notesAsync.maybeWhen(
              data: (List<Note> notes) => notes.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(
                        left: ReadingRoomSpacing.xs,
                      ),
                      child: Text(
                        '${notes.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              tooltip: l10n?.detailAddNoteTooltip ?? 'Add note',
              onPressed: () => _addNote(context, ref),
            ),
          ],
        ),
        if (hasLegacyNote) ...<Widget>[
          const SizedBox(height: ReadingRoomSpacing.sm),
          _LegacyNoteBanner(
            bookmark: bookmark,
            onConvert: () => _convertLegacy(context, ref),
          ),
        ],
        const SizedBox(height: ReadingRoomSpacing.sm),
        notesAsync.when(
          data: (List<Note> notes) {
            if (notes.isEmpty && !hasLegacyNote) {
              return Text(
                l10n?.detailNoNotes ?? 'Tap + to add a personal note.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < notes.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: ReadingRoomSpacing.sm),
                  _NoteCard(
                    note: notes[i],
                    onEdit: () => _editNote(context, ref, notes[i]),
                    onDelete: () => _deleteNote(context, ref, notes[i]),
                  ),
                ],
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: ReadingRoomSpacing.md),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (Object e, _) => Text(
            l10n?.detailCouldNotLoadNotes(e) ?? 'Could not load notes: $e',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    if (bookmark.id == null) return;
    final String? content = await _promptForNote(
      context,
      title: AppLocalizations.of(context)?.detailAddNoteTitle ?? 'Add note',
      initial: '',
    );
    if (content == null || content.trim().isEmpty) return;
    await ref
        .read(noteRepositoryProvider)
        .createForBookmark(bookmark.id!, content);
  }

  Future<void> _editNote(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final String? content = await _promptForNote(
      context,
      title: AppLocalizations.of(context)?.detailEditNoteTitle ?? 'Edit note',
      initial: note.content,
    );
    if (content == null) return;
    final String trimmed = content.trim();
    if (trimmed.isEmpty || trimmed == note.content) return;
    await ref
        .read(noteRepositoryProvider)
        .save(note.copyWith(content: trimmed));
  }

  Future<void> _deleteNote(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    if (note.id == null) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.detailDeleteNoteTitle ??
              'Delete this note?',
        ),
        content: Text(
          AppLocalizations.of(context)?.dialogDeleteMessage ??
              'This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context)?.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(context)?.actionDelete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(noteRepositoryProvider).delete(note.id!);
  }

  /// Migrates the legacy single-string note into a proper Note row,
  /// then clears the bookmark's `inlineNotes` field. Idempotent —
  /// safe if called twice (the second call is a no-op).
  Future<void> _convertLegacy(BuildContext context, WidgetRef ref) async {
    final String? legacy = bookmark.inlineNotes?.trim();
    if (legacy == null || legacy.isEmpty || bookmark.id == null) return;

    final NoteRepository notes = ref.read(noteRepositoryProvider);
    await notes.createForBookmark(bookmark.id!, legacy);

    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    await repo.save(bookmark.copyWith(inlineNotes: ''));
  }

  /// Shared modal sheet for both add + edit flows. Returns the
  /// (untrimmed) text the user typed, or null on cancel.
  Future<String?> _promptForNote(
    BuildContext context, {
    required String title,
    required String initial,
  }) {
    final TextEditingController ctrl = TextEditingController(text: initial);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.only(
          left: ReadingRoomSpacing.lg,
          right: ReadingRoomSpacing.lg,
          top: ReadingRoomSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + ReadingRoomSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: ReadingRoomSpacing.md),
            TextField(
              controller: ctrl,
              maxLines: 6,
              minLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n?.detailNoteHint ?? 'Type your note…',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(l10n?.actionCancel ?? 'Cancel'),
                  ),
                ),
                const SizedBox(width: ReadingRoomSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(ctrl.text),
                    child: Text(l10n?.actionSave ?? 'Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).whenComplete(ctrl.dispose);
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ReadingRoomSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            note.content,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: ReadingRoomSpacing.xs),
          Row(
            children: <Widget>[
              Text(
                _relativeTime(note.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (note.isEdited) ...<Widget>[
                const SizedBox(width: ReadingRoomSpacing.sm),
                Text(
                  l10n?.detailNoteEdited ?? '· edited',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16),
                tooltip: l10n?.actionEdit ?? 'Edit',
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16),
                tooltip: l10n?.actionDelete ?? 'Delete',
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Lightweight relative timestamp — same format the rest of the
  /// detail screen uses, kept inline to avoid pulling a date package.
  static String _relativeTime(DateTime ts) {
    final Duration delta = DateTime.now().difference(ts);
    if (delta.inMinutes < 1) return 'just now';
    if (delta.inMinutes < 60) return '${delta.inMinutes}m ago';
    if (delta.inHours < 24) return '${delta.inHours}h ago';
    if (delta.inDays < 7) return '${delta.inDays}d ago';
    final int weeks = delta.inDays ~/ 7;
    if (weeks < 5) return '${weeks}w ago';
    final int months = delta.inDays ~/ 30;
    if (months < 12) return '${months}mo ago';
    final int years = delta.inDays ~/ 365;
    return '${years}y ago';
  }
}

class _LegacyNoteBanner extends StatelessWidget {
  const _LegacyNoteBanner({
    required this.bookmark,
    required this.onConvert,
  });

  final Bookmark bookmark;
  final VoidCallback onConvert;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ReadingRoomSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.history_edu_outlined,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: ReadingRoomSpacing.xs),
              Text(
                l10n?.detailLegacyNote ?? 'Legacy note',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: ReadingRoomSpacing.xs),
          Text(
            bookmark.inlineNotes!.trim(),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: ReadingRoomSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onConvert,
              icon: const Icon(Icons.upgrade, size: 16),
              label: Text(l10n?.detailConvertToNote ?? 'Convert to note'),
            ),
          ),
        ],
      ),
    );
  }
}
