import 'package:flutter/material.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/l10n/app_localizations.dart';

enum QuickAddAction {
  qr,
  manual,
  clipboard,
}

Future<QuickAddAction?> showQuickAddSheet(BuildContext context) {
  final AppLocalizations? l10n = AppLocalizations.of(context);

  return showModalBottomSheet<QuickAddAction>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ReadingRoomRadii.sheet),
      ),
    ),
    builder: (BuildContext ctx) {
      final ThemeData theme = Theme.of(ctx);
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          ReadingRoomSpacing.lg,
          ReadingRoomSpacing.sm,
          ReadingRoomSpacing.lg,
          ReadingRoomSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n?.quickAddTitle ?? 'Quick add',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: ReadingRoomSpacing.xs),
              Text(
                l10n?.quickAddSubtitle ?? 'Choose a way to add a new link.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: ReadingRoomSpacing.md),
              _QuickAddTile(
                icon: Icons.qr_code_scanner_rounded,
                title: l10n?.quickAddQrTitle ?? 'Scan QR',
                subtitle: l10n?.quickAddQrSubtitle ??
                    'Use camera to read a QR code and capture the link.',
                onTap: () => Navigator.of(ctx).pop(QuickAddAction.qr),
              ),
              _QuickAddTile(
                icon: Icons.edit_rounded,
                title: l10n?.quickAddManualTitle ?? 'Manual input',
                subtitle: l10n?.quickAddManualSubtitle ??
                    'Type or paste a link manually.',
                onTap: () => Navigator.of(ctx).pop(QuickAddAction.manual),
              ),
              _QuickAddTile(
                icon: Icons.content_paste_rounded,
                title: l10n?.quickAddClipboardTitle ?? 'Paste clipboard',
                subtitle: l10n?.quickAddClipboardSubtitle ??
                    'Capture the first link found in clipboard text.',
                onTap: () => Navigator.of(ctx).pop(QuickAddAction.clipboard),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.sm),
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          ),
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          onTap: onTap,
        ),
      ),
    );
  }
}
