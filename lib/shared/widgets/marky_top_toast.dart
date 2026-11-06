import 'dart:async';

import 'package:flutter/material.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';

/// A native-feeling top overlay toast — similar to the Android
/// heads-up notification or AirPods connection popup.
///
/// Slides in from the top, auto-dismisses after [duration], and
/// optionally offers an action button (e.g. "Open").
class MarkyTopToast {
  MarkyTopToast._();

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// Shows a top-sliding toast overlay.
  ///
  /// [context] must have an [Overlay] ancestor (any Scaffold does).
  /// [icon] appears on the left. [message] is the main text.
  /// [actionLabel] / [onAction] add an optional trailing button.
  /// [duration] controls auto-dismiss (default 3.5 seconds).
  static void show(
    BuildContext context, {
    required IconData icon,
    required String message,
    Color? iconColor,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    dismiss();

    final OverlayState overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext ctx) => _TopToastWidget(
        icon: icon,
        iconColor: iconColor,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction != null
            ? () {
                dismiss();
                onAction();
              }
            : null,
        onDismiss: dismiss,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(duration, dismiss);
  }

  /// Removes the current toast if any.
  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _TopToastWidget extends StatefulWidget {
  const _TopToastWidget({
    required this.icon,
    required this.message,
    required this.onDismiss,
    this.iconColor,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color? iconColor;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onVerticalDragEnd: (DragEndDetails details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < -200) {
                widget.onDismiss();
              }
            },
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ReadingRoomSpacing.lg,
                  vertical: ReadingRoomSpacing.sm,
                ),
                child: Material(
                  elevation: 8,
                  shadowColor: Colors.black54,
                  borderRadius:
                      BorderRadius.circular(ReadingRoomRadii.standard),
                  color: theme.colorScheme.inverseSurface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ReadingRoomSpacing.lg,
                      vertical: ReadingRoomSpacing.md,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          widget.icon,
                          size: 22,
                          color: widget.iconColor ??
                              theme.colorScheme.inversePrimary,
                        ),
                        const SizedBox(width: ReadingRoomSpacing.md),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onInverseSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.actionLabel != null) ...<Widget>[
                          const SizedBox(width: ReadingRoomSpacing.sm),
                          TextButton(
                            onPressed: widget.onAction,
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.inversePrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: ReadingRoomSpacing.md,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(widget.actionLabel!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
