import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/feed/presentation/widgets/bookmark_card.dart';
import 'package:marky/features/vault/presentation/providers/vault_providers.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Feed screen for vault bookmarks.
///
/// Watches [vaultItemsProvider] which queries the search infrastructure
/// with the `in:vault` operator. Only renders content when the user has
/// successfully authenticated via [VaultAuthScreen].
///
/// Features:
/// - Pitch-black luxury grid of bookmark cards.
/// - Empty state with lock icon when no vault items exist.
/// - Lock action in the app bar to manually re-lock the vault.
/// - Pull-to-refresh support.
class VaultFeedScreen extends ConsumerWidget {
  /// Creates the [VaultFeedScreen].
  const VaultFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BookmarkItem>> vaultAsync =
        ref.watch(vaultItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.base,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.lock,
              color: AppColors.accentLuxe,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Vault',
              style: AppTypography.sectionTitle.copyWith(fontSize: 18),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.go('/home'),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.lock_outline,
              color: AppColors.accentLuxe,
            ),
            tooltip: 'Lock Vault',
            onPressed: () {
              ref.read(vaultAuthStateProvider.notifier).lock();
              context.go('/vault');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accentLuxe,
        backgroundColor: AppColors.surface2,
        onRefresh: () async {
          ref.invalidate(vaultItemsProvider);
        },
        child: vaultAsync.when(
          loading: () => const _LoadingState(),
          error: (Object error, StackTrace? stackTrace) => _ErrorState(
            error: error,
            onRetry: () => ref.invalidate(vaultItemsProvider),
          ),
          data: (List<BookmarkItem> bookmarks) {
            if (bookmarks.isEmpty) {
              return const _EmptyState();
            }
            return _VaultGrid(bookmarks: bookmarks);
          },
        ),
      ),
    );
  }
}

// ─── Sub-states ────────────────────────────────────────────────────────

/// Loading state shown while vault items are fetching.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: AppColors.accentLuxe,
      ),
    );
  }
}

/// Error state with a retry affordance.
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppShapes.screenPaddingInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTypography.sectionTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTypography.metadata,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentLuxe.withValues(alpha: 0.15),
                foregroundColor: AppColors.accentLuxe,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state shown when the vault contains no bookmarks.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: const Center(
              child: Padding(
                padding: AppShapes.screenPaddingInsets,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Your vault is empty',
                      style: AppTypography.sectionTitle,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Move sensitive bookmarks here to keep them hidden from your main feed.',
                      style: AppTypography.body,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Bookmark grid ─────────────────────────────────────────────────────

/// Masonry grid of vault bookmark cards.
class _VaultGrid extends StatelessWidget {
  const _VaultGrid({required this.bookmarks});

  final List<BookmarkItem> bookmarks;

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount =
        MediaQuery.sizeOf(context).width > 600 ? 3 : 2;

    return MasonryGridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: AppShapes.gridMainAxisSpacing,
      crossAxisSpacing: AppShapes.gridCrossAxisSpacing,
      padding: AppShapes.screenPaddingInsets,
      itemCount: bookmarks.length,
      itemBuilder: (BuildContext context, int index) {
        final BookmarkItem bookmark = bookmarks[index];
        return BookmarkCard(
          bookmark: bookmark,
          onTap: () => context.push('/detail/${bookmark.id}'),
        );
      },
    );
  }
}
