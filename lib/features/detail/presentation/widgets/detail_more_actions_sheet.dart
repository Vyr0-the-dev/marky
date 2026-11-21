import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Overflow actions bottom sheet for [DetailScreen].
class DetailMoreActionsSheet extends StatelessWidget {
  const DetailMoreActionsSheet({
    required this.bookmark,
    super.key,
  });

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final Color dividerColor = theme.colorScheme.outline.withValues(alpha: 0.4);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ReadingRoomRadii.sheet),
        ),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ReadingRoomSpacing.lg,
            ReadingRoomSpacing.md,
            ReadingRoomSpacing.lg,
            ReadingRoomSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(ReadingRoomRadii.chip),
                  ),
                ),
              ),
              const SizedBox(height: ReadingRoomSpacing.lg),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _ActionSheetTile(
                        icon: Icons.edit_outlined,
                        label: l10n?.actionEdit ?? 'Edit',
                        onTap: () => _select(context, 'edit'),
                      ),
                      Divider(height: 1, thickness: 1, color: dividerColor),
                      _ActionSheetTile(
                        icon: Icons.info_outline_rounded,
                        label:
                            l10n?.detailMetadataTitle ?? 'Details & Metadata',
                        onTap: () => _select(context, 'info'),
                      ),
                      if ((bookmark.heroImageUrl?.isNotEmpty ?? false) ||
                          (bookmark.faviconUrl?.isNotEmpty ??
                              false)) ...<Widget>[
                        Divider(height: 1, thickness: 1, color: dividerColor),
                        _ActionSheetTile(
                          icon: Icons.image_outlined,
                          label: l10n?.detailCoverUrlTitle ?? 'Cover Image',
                          onTap: () => _select(context, 'coverOptions'),
                        ),
                      ],
                      Divider(height: 1, thickness: 1, color: dividerColor),
                      _ActionSheetTile(
                        icon: Icons.refresh_rounded,
                        label: l10n?.detailActionRefetch ?? 'Refetch',
                        onTap: () => _select(context, 'refetch'),
                      ),
                      Divider(height: 1, thickness: 1, color: dividerColor),
                      _ActionSheetTile(
                        icon: bookmark.isRead
                            ? Icons.visibility_off_outlined
                            : Icons.check_circle_outline_rounded,
                        label: bookmark.isRead
                            ? (l10n?.detailActionUnread ?? 'Unread')
                            : (l10n?.detailActionRead ?? 'Read'),
                        onTap: () => _select(context, 'toggleRead'),
                      ),
                      Divider(height: 1, thickness: 1, color: dividerColor),
                      _ActionSheetTile(
                        icon: bookmark.isArchived
                            ? Icons.unarchive_outlined
                            : Icons.archive_outlined,
                        label: bookmark.isArchived
                            ? (l10n?.detailActionUnarchive ?? 'Unarchive')
                            : (l10n?.actionArchive ?? 'Archive'),
                        onTap: () => _select(context, 'toggleArchive'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: ReadingRoomSpacing.md),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.25),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: _ActionSheetTile(
                    icon: Icons.delete_outline_rounded,
                    label: l10n?.actionDelete ?? 'Delete',
                    accentColor: theme.colorScheme.error,
                    onTap: () => _select(context, 'delete'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _select(BuildContext context, String value) {
    unawaited(HapticFeedback.selectionClick());
    Navigator.of(context).pop(value);
  }
}

class _ActionSheetTile extends StatelessWidget {
  const _ActionSheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color badgeColor = accentColor ?? theme.colorScheme.primary;
    final Color? textColor = accentColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ReadingRoomSpacing.md,
          vertical: ReadingRoomSpacing.md,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: badgeColor),
            ),
            const SizedBox(width: ReadingRoomSpacing.md),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: (accentColor ?? theme.colorScheme.onSurfaceVariant)
                  .withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
