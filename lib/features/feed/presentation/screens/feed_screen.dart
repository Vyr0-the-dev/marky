import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/capture/domain/use_cases/save_bookmark_use_case.dart';
import 'package:marky/features/capture/presentation/providers/capture_providers.dart';
import 'package:marky/features/capture/presentation/providers/clipboard_providers.dart';
import 'package:marky/features/feed/presentation/providers/feed_providers.dart';
import 'package:marky/features/feed/presentation/widgets/bookmark_card.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// The main feed screen displaying saved bookmarks with incremental
/// pagination.
///
/// Watches [bookmarkListProvider] and renders:
/// - Loading spinner while the first page loads.
/// - Error message on failure.
/// - Empty state illustration when no bookmarks exist.
/// - Scrollable masonry grid of bookmark cards when data is present.
/// - Bottom loading indicator when fetching the next page.
class FeedScreen extends ConsumerStatefulWidget {
  /// Creates the [FeedScreen].
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  static const double _loadMoreThreshold = 200;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Triggers [PaginatedFeedNotifier.loadMore] when the user scrolls
  /// within [_loadMoreThreshold] pixels of the bottom.
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;

    if (maxScroll > 0 && currentScroll >= maxScroll - _loadMoreThreshold) {
      ref.read(bookmarkListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final String feedTitle = l10n?.feedTitle ?? 'Feed';
    final String feedMainContentLabel =
        l10n?.feedMainContentLabel ?? 'Bookmarks feed content';
    final PaginatedFeedState feedState = ref.watch(bookmarkListProvider);
    final ClipboardState clipboardState = ref.watch(clipboardUrlProvider);
    final String? detectedUrl = clipboardState.detectedUrl;

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: ExcludeSemantics(
            child: Text(feedTitle),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          if (detectedUrl != null) _ClipboardBanner(url: detectedUrl),
          Expanded(
            child: Semantics(
              container: true,
              label: feedMainContentLabel,
              child: _buildBody(context: context, state: feedState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required PaginatedFeedState state,
  }) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    // Initial loading state.
    if (state.items.isEmpty && state.isLoadingMore) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state with no data.
    if (state.items.isEmpty && state.error != null) {
      return Center(
        child: Text(
          l10n?.errorLoadFeedMessage ?? 'The feed could not be loaded.',
          style: AppTypography.body.copyWith(
            color: AppColors.danger,
          ),
        ),
      );
    }

    // Empty state.
    if (state.items.isEmpty) {
      return _EmptyState(l10n: l10n);
    }

    // Data state with optional bottom loader.
    return _BookmarkGrid(
      bookmarks: state.items,
      scrollController: _scrollController,
      isLoadingMore: state.isLoadingMore,
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.l10n});

  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.bookmark_border,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.emptyBookmarksTitle ?? 'No bookmarks yet',
            style: AppTypography.sectionTitle,
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.emptyBookmarksSubtitle ??
                'Saved links will appear here once you add your first item.',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Bookmark grid ─────────────────────────────────────────────────────

class _BookmarkGrid extends StatelessWidget {
  const _BookmarkGrid({
    required this.bookmarks,
    required this.scrollController,
    this.isLoadingMore = false,
  });

  final List<BookmarkItem> bookmarks;
  final ScrollController scrollController;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 2 : 1;
    return MasonryGridView.count(
      controller: scrollController,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: AppShapes.gridMainAxisSpacing,
      crossAxisSpacing: AppShapes.gridCrossAxisSpacing,
      padding: AppShapes.screenPaddingInsets,
      itemCount: bookmarks.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        // Bottom loading indicator.
        if (index == bookmarks.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final BookmarkItem bookmark = bookmarks[index];
        return RepaintBoundary(
          child: BookmarkCard(
            bookmark: bookmark,
            onTap: () => context.go('/detail/${bookmark.id}'),
          ),
        );
      },
    );
  }
}

// ─── Clipboard banner ──────────────────────────────────────────────────

class _ClipboardBanner extends ConsumerWidget {
  const _ClipboardBanner({required this.url});

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final String clipboardBannerTitle =
        l10n?.clipboardBannerTitle ?? 'Link found in clipboard';
    final String dismissLabel = l10n?.actionDismiss ?? 'Dismiss';
    final String saveLabel = l10n?.actionSave ?? 'Save';
    final String savedLabel = l10n?.snackbarBookmarkSaved ?? 'Bookmark saved';
    final String duplicateLabel =
        l10n?.snackbarBookmarkAlreadySaved ?? 'Already saved';
    final String saveErrorLabel =
        l10n?.errorSaveBookmarkMessage ?? 'The bookmark could not be saved.';
    final String domain = _extractDomain(url);

    return Container(
      width: double.infinity,
      color: AppColors.surface2,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.content_paste,
                  size: 16,
                  color: AppColors.accentSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    clipboardBannerTitle,
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                domain,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => _onDismiss(ref),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textTertiary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(dismissLabel),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _onSave(
                    context,
                    ref,
                    savedLabel: savedLabel,
                    duplicateLabel: duplicateLabel,
                    saveErrorLabel: saveErrorLabel,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accentPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(saveLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onDismiss(WidgetRef ref) {
    ref.read(clipboardUrlProvider.notifier).dismiss();
  }

  Future<void> _onSave(
    BuildContext context,
    WidgetRef ref, {
    required String savedLabel,
    required String duplicateLabel,
    required String saveErrorLabel,
  }) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final SaveBookmarkUseCase useCase = ref.read(saveBookmarkUseCaseProvider);

    try {
      final SaveResult result = await useCase.execute(url);

      switch (result) {
        case SaveSuccess():
          _showSnackBar(
            messenger,
            message: savedLabel,
            backgroundColor: AppColors.success,
          );
          ref.invalidate(bookmarkListProvider);
          ref.read(clipboardUrlProvider.notifier).dismiss();
        case SaveDuplicate():
          _showSnackBar(
            messenger,
            message: duplicateLabel,
            backgroundColor: AppColors.warning,
          );
          ref.read(clipboardUrlProvider.notifier).dismiss();
        case SaveInvalid(:final String reason):
          _showSnackBar(
            messenger,
            message: reason,
            backgroundColor: AppColors.danger,
          );
          ref.read(clipboardUrlProvider.notifier).dismiss();
      }
    } on Object {
      _showSnackBar(
        messenger,
        message: saveErrorLabel,
        backgroundColor: AppColors.danger,
      );
      ref.read(clipboardUrlProvider.notifier).dismiss();
    }
  }

  void _showSnackBar(
    ScaffoldMessengerState messenger, {
    required String message,
    required Color backgroundColor,
  }) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────

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
