import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/utils/l10n_extension.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/notes/data/note_providers.dart';
import 'package:marky/features/reader/data/article_extractor_service.dart';
import 'package:marky/features/reader/data/reader_preferences_provider.dart';
import 'package:marky/features/reader/domain/article_content.dart';
import 'package:marky/features/reader/presentation/reader_providers.dart';
import 'package:marky/features/widgets/data/widget_providers.dart';
import 'package:marky/features/widgets/domain/widget_feed_snapshot_service.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/widgets/bookmark_image.dart';
import 'package:url_launcher/url_launcher.dart';

/// Immersive, distraction-free reader mode for articles and long-form bookmarks.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    required this.bookmark,
    super.key,
  });

  final Bookmark bookmark;

  static Route<void> route(Bookmark bookmark) {
    return MaterialPageRoute<void>(
      builder: (BuildContext _) => ReaderScreen(bookmark: bookmark),
    );
  }

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  double _readingProgress = 0;
  bool _markedReadInSession = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _markedReadInSession = widget.bookmark.isRead;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double max = _scrollController.position.maxScrollExtent;
    if (max <= 0) {
      if (_readingProgress != 1.0) {
        setState(() => _readingProgress = 1.0);
      }
      return;
    }
    final double current = _scrollController.offset.clamp(0.0, max);
    final double next = (current / max).clamp(0.0, 1.0);
    if ((next - _readingProgress).abs() > 0.01) {
      setState(() => _readingProgress = next);
    }
  }

  ReaderThemeMode _effectiveTheme(
    BuildContext context,
    ReaderPreferences prefs,
  ) {
    if (prefs.themeMode != null) return prefs.themeMode!;
    return Theme.of(context).brightness == Brightness.dark
        ? ReaderThemeMode.dark
        : ReaderThemeMode.light;
  }

  TextStyle _getTextStyle(
    ReaderThemeMode theme,
    ReaderPreferences prefs, {
    double? size,
    FontWeight? weight,
    double? height,
    FontStyle? fontStyle,
  }) {
    final double effectiveSize = size ?? prefs.fontSize;
    final double effectiveHeight = height ?? prefs.lineHeight;
    return switch (prefs.fontFamily) {
      ReaderFontFamily.serif => GoogleFonts.sourceSerif4(
          fontSize: effectiveSize,
          fontWeight: weight ?? FontWeight.normal,
          height: effectiveHeight,
          fontStyle: fontStyle,
          color: theme.text,
        ),
      ReaderFontFamily.sans => GoogleFonts.inter(
          fontSize: effectiveSize,
          fontWeight: weight ?? FontWeight.normal,
          height: effectiveHeight,
          fontStyle: fontStyle,
          color: theme.text,
        ),
    };
  }

  Widget _buildSelectionContextMenu(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    final List<ContextMenuButtonItem> items =
        List<ContextMenuButtonItem>.of(editableTextState.contextMenuButtonItems);
    final TextEditingValue value = editableTextState.textEditingValue;
    final TextSelection selection = value.selection;
    final String selected = selection.isValid && !selection.isCollapsed
        ? selection.textInside(value.text).trim()
        : '';

    if (selected.isNotEmpty && widget.bookmark.id != null) {
      items.insert(
        0,
        ContextMenuButtonItem(
          label: context.l10n.readerSaveHighlightAsNote,
          onPressed: () {
            ContextMenuController.removeAny();
            unawaited(_saveHighlightAsNote(selected));
          },
        ),
      );
    }

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: items,
    );
  }

  Future<void> _saveHighlightAsNote(String quote) async {
    final int? bookmarkId = widget.bookmark.id;
    if (bookmarkId == null || quote.trim().isEmpty) return;
    try {
      await ref
          .read(noteRepositoryProvider)
          .createForBookmark(bookmarkId, '> ${quote.trim()}');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.readerHighlightSaved)),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.detailInlineError(e.toString()))),
        );
    }
  }

  Future<void> _markFinished({required bool alsoArchive}) async {
    final int? bookmarkId = widget.bookmark.id;
    if (bookmarkId == null) return;
    final Bookmark current =
        await ref.read(bookmarkRepositoryProvider).getById(bookmarkId) ??
            widget.bookmark;
    await ref.read(bookmarkRepositoryProvider).save(
          current.copyWith(
            isRead: true,
            isArchived: alsoArchive || current.isArchived,
          ),
        );
    unawaited(_refreshWidgetBestEffort());
    if (!mounted) return;
    setState(() => _markedReadInSession = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            alsoArchive
                ? context.l10n.snackbarBookmarkArchived
                : context.l10n.readerMarkedAsRead,
          ),
        ),
      );
    if (alsoArchive) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _refreshWidgetBestEffort() async {
    try {
      final WidgetFeedSnapshotService service =
          await ref.read(widgetFeedSnapshotServiceProvider.future);
      await service.refresh();
    } on Object {
      // Best-effort home widget refresh.
    }
  }

  void _showAppearanceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Consumer(
          builder: (BuildContext ctx, WidgetRef sheetRef, _) {
            final ReaderPreferences prefs =
                sheetRef.watch(readerPreferencesProvider);
            final ReaderThemeMode themeMode = _effectiveTheme(ctx, prefs);
            final ReaderPreferencesNotifier notifier =
                sheetRef.read(readerPreferencesProvider.notifier);

            return Container(
              padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
              decoration: BoxDecoration(
                color: themeMode.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(ReadingRoomRadii.sheet),
                ),
                border: Border(top: BorderSide(color: themeMode.border)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(
                          bottom: ReadingRoomSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: themeMode.subtext.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          ctx.l10n.readerFontAndThemeTooltip,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: themeMode.text,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: themeMode.text,
                          ),
                          tooltip: ctx.l10n.actionClose,
                          onPressed: () => Navigator.of(ctx).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: ReadingRoomSpacing.lg),

                    // ── Theme Selector ────────────────────────
                    Row(
                      children:
                          ReaderThemeMode.values.map((ReaderThemeMode mode) {
                        final bool isSelected = themeMode == mode;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => unawaited(notifier.setThemeMode(mode)),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: mode.background,
                                  borderRadius: BorderRadius.circular(
                                    ReadingRoomRadii.standard,
                                  ),
                                  border: Border.all(
                                    color:
                                        isSelected ? mode.accent : mode.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _themeName(ctx, mode),
                                    style: TextStyle(
                                      color: mode.text,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: ReadingRoomSpacing.lg),

                    // ── Font Selector ─────────────────────────
                    Row(
                      children:
                          ReaderFontFamily.values.map((ReaderFontFamily font) {
                        final bool isSelected = prefs.fontFamily == font;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? themeMode.accent.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: isSelected
                                      ? themeMode.accent
                                      : themeMode.border,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () =>
                                  unawaited(notifier.setFontFamily(font)),
                              child: Text(
                                _fontLabel(ctx, font),
                                style: TextStyle(
                                  color: themeMode.text,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: ReadingRoomSpacing.lg),

                    // ── Font Size Controls ────────────────────
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.format_size_rounded,
                          size: 18,
                          color: themeMode.subtext,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: themeMode.text,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: prefs.fontSize,
                            min: 14,
                            max: 26,
                            divisions: 6,
                            activeColor: themeMode.accent,
                            inactiveColor: themeMode.border,
                            onChanged: (double val) =>
                                unawaited(notifier.setFontSize(val)),
                          ),
                        ),
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: themeMode.text,
                          ),
                        ),
                      ],
                    ),

                    // ── Line Spacing Controls ─────────────────
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.format_line_spacing_rounded,
                          size: 18,
                          color: themeMode.subtext,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ctx.l10n.readerLineSpacing,
                          style: TextStyle(
                            fontSize: 12,
                            color: themeMode.subtext,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: prefs.lineHeight,
                            min: 1.4,
                            max: 2,
                            divisions: 6,
                            activeColor: themeMode.accent,
                            inactiveColor: themeMode.border,
                            onChanged: (double val) =>
                                unawaited(notifier.setLineHeight(val)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Bookmark bookmark = widget.bookmark;
    final ReaderPreferences prefs = ref.watch(readerPreferencesProvider);
    final ReaderThemeMode themeMode = _effectiveTheme(context, prefs);
    final AsyncValue<ArticleContent> articleAsync =
        ref.watch(readerArticleProvider(bookmark));

    return Scaffold(
      backgroundColor: themeMode.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ── Top Reading Progress Bar ───────────────────
            LinearProgressIndicator(
              value: _readingProgress,
              minHeight: 2.5,
              backgroundColor: themeMode.border,
              valueColor: AlwaysStoppedAnimation<Color>(themeMode.accent),
            ),

            // ── Custom App Bar ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ReadingRoomSpacing.md,
                vertical: ReadingRoomSpacing.xs,
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: themeMode.text),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                  const Spacer(),
                  articleAsync.when(
                    data: (ArticleContent article) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: themeMode.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: themeMode.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: themeMode.subtext,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n
                                .readingTimeMinutes(article.readingTimeMinutes),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: themeMode.subtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Icon(Icons.refresh_rounded, color: themeMode.text),
                    tooltip: context.l10n.readerRefreshTooltip,
                    onPressed: () {
                      unawaited(
                        ref
                            .read(readerArticleProvider(bookmark).notifier)
                            .refresh(),
                      );
                    },
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.text_fields_rounded, color: themeMode.text),
                    tooltip: context.l10n.readerFontAndThemeTooltip,
                    onPressed: _showAppearanceSheet,
                  ),
                ],
              ),
            ),

            // ── Article Body ──────────────────────────────
            Expanded(
              child: articleAsync.when(
                data: (ArticleContent article) =>
                    _buildArticleScroll(article, themeMode, prefs),
                loading: () => _buildLoadingState(themeMode),
                error: (Object err, _) => _buildErrorState(err, themeMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ReaderThemeMode themeMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: themeMode.accent,
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.lg),
            Text(
              context.l10n.readerLoadingTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: themeMode.text,
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.xs),
            Text(
              context.l10n.readerLoadingSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: themeMode.subtext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, ReaderThemeMode themeMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: themeMode.accent,
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
            Text(
              context.l10n.readerErrorTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeMode.text,
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.sm),
            Text(
              context.l10n.readerErrorSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: themeMode.subtext),
            ),
            const SizedBox(height: ReadingRoomSpacing.lg),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: themeMode.accent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                unawaited(
                  ref
                      .read(readerArticleProvider(widget.bookmark).notifier)
                      .refresh(),
                );
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.l10n.readerRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleScroll(
    ArticleContent article,
    ReaderThemeMode themeMode,
    ReaderPreferences prefs,
  ) {
    final AppLocalizations l10n = context.l10n;
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: ReadingRoomSpacing.xl,
        vertical: ReadingRoomSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Fallback notice banner if article couldn't be fully fetched
          if (article.isFallback) ...<Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ReadingRoomSpacing.md),
              margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
              decoration: BoxDecoration(
                color: themeMode.surface,
                borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
                border: Border.all(color: themeMode.border),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: themeMode.accent,
                  ),
                  const SizedBox(width: ReadingRoomSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.readerFallbackNotice,
                      style: TextStyle(
                        fontSize: 12,
                        color: themeMode.subtext,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Domain / Site Name
          if (article.siteName != null && article.siteName!.isNotEmpty)
            Text(
              article.siteName!.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: themeMode.accent,
              ),
            ),
          const SizedBox(height: ReadingRoomSpacing.sm),

          // Article Title
          SelectableText(
            article.title,
            contextMenuBuilder: _buildSelectionContextMenu,
            style: _getTextStyle(
              themeMode,
              prefs,
              size: prefs.fontSize * 1.45,
              weight: FontWeight.bold,
              height: 1.28,
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.md),

          // Author & Date
          Row(
            children: <Widget>[
              if (article.author != null &&
                  article.author!.isNotEmpty) ...<Widget>[
                Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: themeMode.subtext,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    article.author!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: themeMode.subtext,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (article.publishDate != null) ...<Widget>[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: themeMode.subtext,
                ),
                const SizedBox(width: 4),
                Text(
                  '${article.publishDate!.day}.${article.publishDate!.month}.${article.publishDate!.year}',
                  style: TextStyle(
                    fontSize: 13,
                    color: themeMode.subtext,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: ReadingRoomSpacing.lg),

          // Hero Image (local cached thumbnail first, then network)
          if ((widget.bookmark.heroImageLocalPath?.isNotEmpty ?? false) ||
              (article.heroImageUrl != null &&
                  article.heroImageUrl!.isNotEmpty)) ...<Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
              child: BookmarkImage(
                localPath: widget.bookmark.heroImageLocalPath,
                imageUrl: article.heroImageUrl,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.xl),
          ],

          // Render Rich Article Blocks (or localized fallback notice when empty)
          if (article.blocks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
              child: Text(
                l10n.readerFallbackEmptyBody,
                style: _getTextStyle(themeMode, prefs),
              ),
            )
          else
            ...article.blocks.map(
              (ArticleBlock b) => _buildBlock(b, themeMode, prefs),
            ),

          const SizedBox(height: ReadingRoomSpacing.xl),

          // End-of-article completion actions
          if (widget.bookmark.id != null) ...<Widget>[
            _buildEndOfArticleCard(themeMode, l10n),
            const SizedBox(height: ReadingRoomSpacing.lg),
          ],

          // Bottom Open in Web action
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: themeMode.text,
                side: BorderSide(color: themeMode.border),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                final String url =
                    widget.bookmark.canonicalUrl ?? widget.bookmark.originalUrl;
                final Uri? uri = Uri.tryParse(url);
                if (uri != null) {
                  unawaited(
                    launchUrl(uri, mode: LaunchMode.externalApplication),
                  );
                }
              },
              icon: const Icon(Icons.open_in_browser_rounded, size: 18),
              label: Text(l10n.readerOpenOriginal),
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.huge),
        ],
      ),
    );
  }

  Widget _buildEndOfArticleCard(
    ReaderThemeMode themeMode,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
      decoration: BoxDecoration(
        color: themeMode.surface,
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        border: Border.all(color: themeMode.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.readerEndTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: themeMode.text,
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          Wrap(
            spacing: ReadingRoomSpacing.sm,
            runSpacing: ReadingRoomSpacing.sm,
            children: <Widget>[
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: themeMode.accent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _markedReadInSession
                    ? null
                    : () => unawaited(_markFinished(alsoArchive: false)),
                icon: Icon(
                  _markedReadInSession
                      ? Icons.check_circle_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 18,
                ),
                label: Text(
                  _markedReadInSession
                      ? l10n.readerMarkedAsRead
                      : l10n.readerMarkRead,
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: themeMode.text,
                  side: BorderSide(color: themeMode.border),
                ),
                onPressed: () => unawaited(_markFinished(alsoArchive: true)),
                icon: const Icon(Icons.archive_outlined, size: 18),
                label: Text(l10n.readerMarkReadArchive),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(
    ArticleBlock block,
    ReaderThemeMode themeMode,
    ReaderPreferences prefs,
  ) {
    switch (block.type) {
      case ArticleBlockType.heading:
        final double scale = switch (block.level) {
          1 => 1.35,
          2 => 1.22,
          _ => 1.1,
        };
        final String headingText =
            block.text == ArticleExtractorService.topCommentsHeadingMarker
                ? context.l10n.readerTopComments
                : block.text;
        return Padding(
          padding: const EdgeInsets.only(
            top: ReadingRoomSpacing.xl,
            bottom: ReadingRoomSpacing.sm,
          ),
          child: SelectableText(
            headingText,
            contextMenuBuilder: _buildSelectionContextMenu,
            style: _getTextStyle(
              themeMode,
              prefs,
              size: prefs.fontSize * scale,
              weight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        );

      case ArticleBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
          child: SelectableText(
            block.text,
            contextMenuBuilder: _buildSelectionContextMenu,
            style: _getTextStyle(themeMode, prefs),
          ),
        );

      case ArticleBlockType.blockquote:
        return Container(
          margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
          padding: const EdgeInsets.symmetric(
            horizontal: ReadingRoomSpacing.md,
            vertical: ReadingRoomSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: themeMode.surface.withValues(alpha: 0.5),
            border: Border(
              left: BorderSide(color: themeMode.accent, width: 3.5),
            ),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(8),
            ),
          ),
          child: SelectableText(
            block.text,
            contextMenuBuilder: _buildSelectionContextMenu,
            style: _getTextStyle(
              themeMode,
              prefs,
              fontStyle: FontStyle.italic,
              height: 1.55,
            ),
          ),
        );

      case ArticleBlockType.code:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
          padding: const EdgeInsets.all(ReadingRoomSpacing.md),
          decoration: BoxDecoration(
            color: themeMode.surface,
            borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
            border: Border.all(color: themeMode.border),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              block.text,
              contextMenuBuilder: _buildSelectionContextMenu,
              style: GoogleFonts.jetBrainsMono(
                fontSize: prefs.fontSize * 0.85,
                color: themeMode.text,
                height: 1.5,
              ),
            ),
          ),
        );

      case ArticleBlockType.list:
        return Padding(
          padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: block.listItems
                .asMap()
                .entries
                .map((MapEntry<int, String> entry) {
              final String prefix =
                  block.isOrdered ? '${entry.key + 1}. ' : '• ';
              return Padding(
                padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      prefix,
                      style: _getTextStyle(
                        themeMode,
                        prefs,
                        weight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: SelectableText(
                        entry.value,
                        contextMenuBuilder: _buildSelectionContextMenu,
                        style: _getTextStyle(themeMode, prefs),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );

      case ArticleBlockType.image:
        if (block.imageUrl == null || block.imageUrl!.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
                child: BookmarkImage(
                  imageUrl: block.imageUrl,
                  width: double.infinity,
                ),
              ),
              if (block.caption != null &&
                  block.caption!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  block.caption!,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: themeMode.subtext,
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }

  String _themeName(BuildContext context, ReaderThemeMode mode) {
    return switch (mode) {
      ReaderThemeMode.light => context.l10n.readerThemePaper,
      ReaderThemeMode.sepia => context.l10n.readerThemeSepia,
      ReaderThemeMode.dark => context.l10n.readerThemeDark,
    };
  }

  String _fontLabel(BuildContext context, ReaderFontFamily font) {
    return switch (font) {
      ReaderFontFamily.serif => context.l10n.readerFontSerif,
      ReaderFontFamily.sans => context.l10n.readerFontSans,
    };
  }
}
