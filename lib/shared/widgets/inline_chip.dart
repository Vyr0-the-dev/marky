import 'package:flutter/material.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';

/// A compact, non-Material-looking chip for filters, tags, and
/// collections.
///
/// Why not [ChoiceChip]? Material's chip widgets render touch ripples,
/// elevation overlays, and 32dp minimum heights that fight the
/// Reading Room grid. This component is flat, 28dp tall, and
/// consistent across the app — feed filters, tag picker, detail
/// screen tag strip all use it.
///
/// Visual states:
/// - **Default**: outline + surface fill
/// - **Selected**: accent fill + on-accent text
/// - **Muted** (via [color] override): custom tag colour; the chip
///   uses it as a dot prefix so selected vs. unselected reads
///   instantly without needing to recolour the label.
class InlineChip extends StatelessWidget {
  const InlineChip({
    required this.label,
    this.selected = false,
    this.onTap,
    this.onDelete,
    this.color,
    this.leading,
    this.expanded = false,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Optional "x" affordance — shown when non-null. Used by the
  /// detail screen's tag strip to remove a tag inline.
  final VoidCallback? onDelete;

  /// Custom colour dot prefix — only rendered when [leading] is null.
  /// Used by tag chips to surface the user's picked tag colour.
  final Color? color;

  /// Optional custom leading widget. Takes precedence over [color].
  final Widget? leading;

  final bool expanded;

  void _handleTap() {
    if (onTap == null) return;
    onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fg = selected
        ? (theme.brightness == Brightness.light
            ? ReadingRoomColors.lightSurfaceRaised
            : ReadingRoomColors.darkInk)
        : theme.colorScheme.onSurface;
    final Color bg = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHigh;
    final Color border =
        selected ? theme.colorScheme.primary : theme.colorScheme.outline;

    Widget? prefix = leading;
    if (prefix == null && color != null) {
      prefix = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }

    final Widget content = Row(
      mainAxisAlignment:
          expanded ? MainAxisAlignment.center : MainAxisAlignment.start,
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: <Widget>[
        if (prefix != null) ...<Widget>[
          prefix,
          const SizedBox(width: ReadingRoomSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(color: fg),
          ),
        ),
        if (onDelete != null) ...<Widget>[
          const SizedBox(width: ReadingRoomSpacing.xs),
          InkResponse(
            onTap: onDelete,
            radius: 14,
            child: Icon(Icons.close_rounded, size: 14, color: fg),
          ),
        ],
      ],
    );

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReadingRoomRadii.chip),
        side: BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap == null ? null : _handleTap,
        enableFeedback: false,
        splashFactory: NoSplash.splashFactory,
        highlightColor: theme.colorScheme.primary.withValues(alpha: 0.06),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ReadingRoomSpacing.md,
              vertical: ReadingRoomSpacing.sm,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
