import 'package:flutter/material.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';

/// Reading Room's opinionated app bar.
///
/// Differences from stock [AppBar]:
/// - **No elevation, no scroll-under tint.** The scroll region meets
///   the app bar cleanly along a 1px divider; there's no ambient
///   shadow-on-scroll chrome.
/// - **Serif title**, styled from [TextTheme.titleLarge] so the
///   tripartite type system stays consistent.
/// - **Large-title mode**: when [large] is true, the title renders
///   below the action row like iOS / Material 3's `TwoRowsTitle`,
///   giving headlines more visual weight. The collapsed version stays
///   available for secondary routes.
/// - **Optional trailing counter** (e.g. bookmark count) rendered in
///   the mono "metadata" voice.
class MarkyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MarkyAppBar({
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
    this.large = false,
    this.trailingCounter,
    super.key,
  });

  final String title;

  /// Optional supporting line rendered in muted body voice below the
  /// title. Only shown when [large] is true.
  final String? subtitle;

  final Widget? leading;
  final List<Widget> actions;

  /// When true, renders as a tall 2-row app bar. Home / Library /
  /// Search use this on landing; detail routes use the compact form.
  final bool large;

  /// Optional right-aligned metadata line (e.g. "23 saved"). Rendered
  /// in JetBrains Mono so it reads like data, not prose.
  final String? trailingCounter;

  @override
  Size get preferredSize => Size.fromHeight(
        large ? 108 : kToolbarHeight,
      );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (!large) {
      return AppBar(
        leading: leading,
        title: Text(title),
        actions: <Widget>[
          ...actions,
          if (trailingCounter != null)
            Padding(
              padding: const EdgeInsets.only(right: ReadingRoomSpacing.lg),
              child: Center(
                child: Text(
                  trailingCounter!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
        ],
      );
    }

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Top row: leading + actions. Title is reserved for the
            // row below so the headline can breathe.
            SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: <Widget>[
                  if (leading != null) leading!,
                  const Spacer(),
                  ...actions,
                  if (trailingCounter != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(right: ReadingRoomSpacing.lg),
                      child: Text(
                        trailingCounter!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ReadingRoomSpacing.lg,
                ReadingRoomSpacing.xs,
                ReadingRoomSpacing.lg,
                ReadingRoomSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium,
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: ReadingRoomSpacing.xs),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
