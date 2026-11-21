import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/reader/presentation/reader_screen.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sticky bottom action bar for [DetailScreen].
///
/// Highlights the three primary link actions: Open in browser, Reader Mode,
/// and Copy URL.
class DetailBottomBar extends StatelessWidget {
  const DetailBottomBar({
    required this.bookmark,
    super.key,
  });

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final Color surfaceColor =
        theme.scaffoldBackgroundColor == ReadingRoomColors.oledSurface
            ? ReadingRoomColors.oledSurface
            : theme.colorScheme.surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ReadingRoomSpacing.lg,
            vertical: ReadingRoomSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openInBrowser(context),
                  icon: const Icon(Icons.open_in_browser, size: 18),
                  label: Text(l10n?.actionOpen ?? 'Open'),
                ),
              ),
              const SizedBox(width: ReadingRoomSpacing.sm),
              FilledButton.tonalIcon(
                onPressed: () => unawaited(
                  Navigator.of(context).push(ReaderScreen.route(bookmark)),
                ),
                icon: const Icon(Icons.chrome_reader_mode_outlined, size: 18),
                label: Text(l10n?.detailReaderMode ?? 'Reader'),
              ),
              const SizedBox(width: ReadingRoomSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => _copyUrl(context),
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: Text(l10n?.actionCopy ?? 'Copy'),
              ),
            ],
          ),
        ),
      ),
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
    unawaited(Clipboard.setData(ClipboardData(text: url)));
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
}
