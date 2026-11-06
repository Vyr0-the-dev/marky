import 'package:flutter/material.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';

/// Divider-less section header used inside long-scroll screens
/// (Settings, Library, Detail).
///
/// The visual language:
/// - **All-caps, letter-spaced, mono metadata style** for the title.
///   Reads as "chapter heading in a typeset book" rather than
///   Material's usual bold sans.
/// - Optional right-aligned trailing slot (link / count). The
///   Settings screen uses it for "Reset" affordances; feature screens
///   use it for "See all" links.
/// - No leading/trailing divider line — section boundaries are
///   conveyed by vertical rhythm instead. The rest of Reading Room
///   already avoids chrome, so headers shouldn't reintroduce it.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      ReadingRoomSpacing.lg,
      ReadingRoomSpacing.xl,
      ReadingRoomSpacing.lg,
      ReadingRoomSpacing.sm,
    ),
    super.key,
  });

  final String title;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Mono-voice, upper-case, widely-letterspaced. Same family as
    // ReadingRoomTextStyles.metadata but with transformation applied
    // via the text widget (so selectable copy keeps the original
    // case).
    final TextStyle style = theme.textTheme.labelSmall?.copyWith(
          letterSpacing: 1.2,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          color: theme.colorScheme.onSurfaceVariant,
        ) ??
        const TextStyle();

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: style,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
