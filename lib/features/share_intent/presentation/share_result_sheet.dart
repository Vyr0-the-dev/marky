import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/l10n/app_localizations.dart';

Future<void> showMarkyShareResultSheet(
  BuildContext context, {
  CaptureResult? result,
  Future<CaptureResult>? resultFuture,
  VoidCallback? onOpenApp,
  VoidCallback? onClosed,
  VoidCallback? onDismiss,
  Duration autoCloseAfter = const Duration(seconds: 4),
}) async {
  assert(
    result != null || resultFuture != null,
    'Either result or resultFuture must be provided.',
  );

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.54),
    builder: (BuildContext sheetContext) {
      return MarkyShareResultPanel(
        resultFuture: resultFuture ?? Future<CaptureResult>.value(result!),
        autoCloseAfter: autoCloseAfter,
        onAutoClose: () {
          final NavigatorState? navigator = Navigator.maybeOf(sheetContext);
          if (navigator?.canPop() ?? false) navigator!.pop();
        },
        onOpenApp: onOpenApp == null
            ? null
            : () {
                Navigator.of(sheetContext).pop();
                onOpenApp();
              },
        onDismiss: () {
          final NavigatorState? navigator = Navigator.maybeOf(sheetContext);
          if (navigator?.canPop() ?? false) navigator!.pop();
          onDismiss?.call();
        },
      );
    },
  );

  onClosed?.call();
}

class MarkyShareResultPanel extends StatefulWidget {
  const MarkyShareResultPanel({
    required this.resultFuture,
    required this.autoCloseAfter,
    this.onAutoClose,
    this.onOpenApp,
    this.onDismiss,
    super.key,
  });

  final Future<CaptureResult> resultFuture;
  final Duration autoCloseAfter;
  final VoidCallback? onAutoClose;
  final VoidCallback? onOpenApp;
  final VoidCallback? onDismiss;

  @override
  State<MarkyShareResultPanel> createState() => _MarkyShareResultPanelState();
}

class _MarkyShareResultPanelState extends State<MarkyShareResultPanel>
    with SingleTickerProviderStateMixin {
  Timer? _autoCloseTimer;
  CaptureResult? _result;

  static const double _compactHeight = 384;
  static const double _expandedHeight = 540;
  static const double _dismissThreshold = 56;

  double _dragOffset = 0;
  double _expandedOffset = 0;
  late final AnimationController _snapController;
  Animation<double>? _dragAnimation;
  Animation<double>? _expansionAnimation;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(_handleSnapTick);
    unawaited(_waitForResult());
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _snapController.removeListener(_handleSnapTick);
    _snapController.dispose();
    super.dispose();
  }

  void _handleSnapTick() {
    if (_dragAnimation != null) {
      setState(() {
        _dragOffset = _dragAnimation!.value;
      });
    } else if (_expansionAnimation != null) {
      setState(() {
        _expandedOffset = _expansionAnimation!.value;
      });
    }
  }

  Future<void> _waitForResult() async {
    CaptureResult result;
    try {
      result = await widget.resultFuture;
    } on Object {
      result = CaptureResult.error('share_result_failed');
    }

    if (!mounted) return;
    setState(() {
      _result = result;
    });

    if (widget.autoCloseAfter > Duration.zero) {
      _autoCloseTimer = Timer(widget.autoCloseAfter, () {
        widget.onAutoClose?.call();
      });
    }
  }

  void _animateDragTo(double target) {
    _dragAnimation = Tween<double>(
      begin: _dragOffset,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _snapController,
        curve: Curves.easeOutCubic,
      ),
    );
    _expansionAnimation = null;
    _snapController.forward(from: 0);
  }

  void _animateExpansionTo(double target) {
    _expansionAnimation = Tween<double>(
      begin: _expandedOffset,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _snapController,
        curve: Curves.easeOutCubic,
      ),
    );
    _dragAnimation = null;
    _snapController.forward(from: 0);
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    final double delta = details.primaryDelta ?? 0;
    if (delta == 0) return;
    if (_snapController.isAnimating) {
      _snapController.stop();
    }

    setState(() {
      if (_expandedOffset > 0) {
        // When expanded, dragging down collapses expansion first.
        _expandedOffset = math.max(0, _expandedOffset - delta);
      } else if (delta < 0) {
        // Dragging upwards expands the sheet.
        const double maxExpansion = _expandedHeight - _compactHeight;
        _expandedOffset = math.min(maxExpansion, _expandedOffset - delta);
      } else {
        // Dragging downwards translates towards dismiss.
        _dragOffset = math.max(0, _dragOffset + delta);
      }
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;

    // Fling down or dragged past threshold -> dismiss
    if (_dragOffset > _dismissThreshold || velocity > 600) {
      widget.onDismiss?.call();
      return;
    }

    // Expand snap handling
    if (_expandedOffset > 0) {
      const double maxExpansion = _expandedHeight - _compactHeight;
      final double target =
          (_expandedOffset > 50 || velocity < -400) ? maxExpansion : 0;
      _animateExpansionTo(target);
      return;
    }

    // Settle drag offset back to resting position
    if (_dragOffset > 0) {
      _animateDragTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final CaptureResult? result = _result;
    final _ShareSheetCopy copy = _ShareSheetCopy.from(result, l10n);
    final bool success = result?.status == CaptureStatus.saved ||
        result?.status == CaptureStatus.duplicate;
    final bool pending = result == null;
    final double currentHeight = _compactHeight + _expandedOffset;
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: <Widget>[
        // Scrim barrier above sheet — tap to dismiss
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: const ColoredBox(
              color: Color(0x66000000),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(0, _dragOffset),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: _handleVerticalDragUpdate,
              onVerticalDragEnd: _handleVerticalDragEnd,
              onVerticalDragCancel: () {
                if (_dragOffset > 0) _animateDragTo(0);
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                    left: BorderSide(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                    right: BorderSide(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: currentHeight + bottomInset,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      12,
                      24,
                      math.max(20, bottomInset + 12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Drag handle
                        Center(
                          child: Container(
                            width: 42,
                            height: 5,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Status indicator
                        SizedBox(
                          width: 104,
                          height: 104,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            child: pending
                                ? const _PendingShareIndicator(
                                    key: ValueKey('pending'),
                                  )
                                : success
                                    ? const _FallbackCheck(
                                        key: ValueKey('success'),
                                      )
                                    : Icon(
                                        copy.icon,
                                        key: const ValueKey('error'),
                                        size: 72,
                                        color: theme.colorScheme.error,
                                      ),
                          ),
                        ),
                        const SizedBox(height: ReadingRoomSpacing.md),
                        Text(
                          copy.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: ReadingRoomSpacing.xs),
                        Text(
                          copy.message,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                        if (result?.bookmark != null) ...<Widget>[
                          const SizedBox(height: ReadingRoomSpacing.md),
                          _BookmarkQuickInfo(bookmark: result!.bookmark!),
                        ],
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: pending || widget.onOpenApp == null
                                ? null
                                : widget.onOpenApp,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              pending
                                  ? l10n?.statusSaving ?? 'Saving...'
                                  : l10n?.shareOverlayOpenApp ?? 'Open app',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookmarkQuickInfo extends StatelessWidget {
  const _BookmarkQuickInfo({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String url = (bookmark.canonicalUrl?.isNotEmpty ?? false)
        ? bookmark.canonicalUrl!
        : bookmark.originalUrl;
    final String host =
        bookmark.normalizedHost ?? Uri.tryParse(url)?.host ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.link_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              host.isNotEmpty ? host : url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingShareIndicator extends StatefulWidget {
  const _PendingShareIndicator({super.key});

  @override
  State<_PendingShareIndicator> createState() => _PendingShareIndicatorState();
}

class _PendingShareIndicatorState extends State<_PendingShareIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween<double>(
    begin: 0.94,
    end: 1.04,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ),
  );

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.72,
    end: 1,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return RepaintBoundary(
      child: ScaleTransition(
        scale: _scale,
        child: FadeTransition(
          opacity: _opacity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(dimension: 34),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackCheck extends StatelessWidget {
  const _FallbackCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFF20BF63),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          size: 68,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ShareSheetCopy {
  const _ShareSheetCopy({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  static _ShareSheetCopy from(
    CaptureResult? result,
    AppLocalizations? l10n,
  ) {
    final CaptureStatus? status = result?.status;
    switch (status) {
      case null:
        return _ShareSheetCopy(
          title: l10n?.shareOverlaySavingTitle ?? 'Saving',
          message: l10n?.shareOverlaySavingMessage ??
              'Sending the shared item to Marky.',
          icon: Icons.downloading_rounded,
        );
      case CaptureStatus.saved:
        return _ShareSheetCopy(
          title: l10n?.shareOverlaySavedTitle ?? 'Saved',
          message: l10n?.shareOverlaySavedMessage ??
              '1 shared item was saved to Marky.',
          icon: Icons.check_rounded,
        );
      case CaptureStatus.duplicate:
        return _ShareSheetCopy(
          title: l10n?.shareOverlayDuplicateTitle ?? 'Already saved',
          message: l10n?.shareOverlayDuplicateMessage ??
              'This shared item is already in your library.',
          icon: Icons.bookmark_added_rounded,
        );
      case CaptureStatus.invalidUrl:
        return _ShareSheetCopy(
          title: l10n?.shareOverlayInvalidTitle ?? 'Could not save',
          message: l10n?.shareOverlayInvalidMessage ??
              'No saveable link was found in the shared item.',
          icon: Icons.link_off_rounded,
        );
      case CaptureStatus.error:
        final String? diagnostic = result?.errorMessage?.trim();
        final String message = diagnostic == null || diagnostic.isEmpty
            ? l10n?.shareOverlayErrorMessage ??
                'Could not save this shared item. Please try again.'
            : l10n?.shareOverlayErrorMessageWithDetail(diagnostic) ??
                'Could not save this shared item: $diagnostic';
        return _ShareSheetCopy(
          title: l10n?.shareOverlayErrorTitle ?? 'Something went wrong',
          message: message,
          icon: Icons.error_outline_rounded,
        );
    }
  }
}
