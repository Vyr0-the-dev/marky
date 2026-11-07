import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
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

  CaptureResult? resolvedResult = result;
  if (resolvedResult == null && resultFuture != null) {
    try {
      resolvedResult = await resultFuture;
    } on Object {
      resolvedResult = CaptureResult.error('share_result_failed');
    }
  }

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.54),
    builder: (BuildContext sheetContext) {
      return MarkyShareResultPanel(
        hasInternalScrim: false,
        result: resolvedResult,
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
    this.result,
    this.resultFuture,
    required this.autoCloseAfter,
    this.exitDuration = const Duration(milliseconds: 240),
    this.hasInternalScrim = true,
    this.onAutoClose,
    this.onOpenApp,
    this.onDismiss,
    super.key,
  }) : assert(
          result != null || resultFuture != null,
          'Either result or resultFuture must be provided.',
        );

  final CaptureResult? result;
  final Future<CaptureResult>? resultFuture;
  final Duration autoCloseAfter;
  final Duration exitDuration;
  final bool hasInternalScrim;
  final VoidCallback? onAutoClose;
  final VoidCallback? onOpenApp;
  final VoidCallback? onDismiss;

  @override
  MarkyShareResultPanelState createState() => MarkyShareResultPanelState();
}

class MarkyShareResultPanelState extends State<MarkyShareResultPanel>
    with TickerProviderStateMixin {
  Timer? _autoCloseTimer;
  CaptureResult? _result;
  int _resultGeneration = 0;
  bool _isDismissing = false;

  static const double _compactHeight = 320;
  static const double _dismissThreshold = 56;

  final ValueNotifier<double> _dragOffsetNotifier = ValueNotifier<double>(0);

  late final AnimationController _entranceController;
  late final AnimationController _snapController;
  late final AnimationController _exitController;

  Animation<double>? _snapAnimation;
  Animation<double>? _exitAnimation;

  @override
  void initState() {
    super.initState();
    _result = widget.result;

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..addListener(_handleSnapTick);

    _exitController = AnimationController(
      vsync: this,
      duration: widget.exitDuration,
    )..addListener(_handleExitTick);

    if (_result != null) {
      _entranceController.forward();
      _startAutoCloseTimer();
    } else if (widget.resultFuture != null) {
      unawaited(_waitForResult(++_resultGeneration));
    }
  }

  void _startAutoCloseTimer() {
    if (widget.autoCloseAfter > Duration.zero) {
      _autoCloseTimer?.cancel();
      _autoCloseTimer = Timer(widget.autoCloseAfter, () {
        if (!mounted || _isDismissing) return;
        animateDismiss(isAutoClose: true);
      });
    }
  }

  @override
  void didUpdateWidget(MarkyShareResultPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.result != oldWidget.result && widget.result != null) {
      _result = widget.result;
      _startAutoCloseTimer();
    } else if (widget.resultFuture != oldWidget.resultFuture &&
        widget.resultFuture != null) {
      _autoCloseTimer?.cancel();
      _result = null;
      _resultGeneration++;
      _isDismissing = false;
      _exitController.reset();
      _snapController.reset();
      _dragOffsetNotifier.value = 0.0;
      unawaited(_waitForResult(_resultGeneration));
    }
    if (widget.exitDuration != oldWidget.exitDuration) {
      _exitController.duration = widget.exitDuration;
    }
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _entranceController.dispose();
    _snapController.removeListener(_handleSnapTick);
    _snapController.dispose();
    _exitController.removeListener(_handleExitTick);
    _exitController.dispose();
    _dragOffsetNotifier.dispose();
    super.dispose();
  }

  void _handleSnapTick() {
    if (_snapAnimation != null) {
      _dragOffsetNotifier.value = _snapAnimation!.value;
    }
  }

  void _handleExitTick() {
    if (_exitAnimation != null) {
      _dragOffsetNotifier.value = _exitAnimation!.value;
    }
  }

  Future<void> _waitForResult(int generation) async {
    CaptureResult result;
    try {
      result = await widget.resultFuture!;
    } on Object {
      result = CaptureResult.error('share_result_failed');
    }

    if (!mounted || generation != _resultGeneration) return;
    setState(() {
      _result = result;
    });
    unawaited(_entranceController.forward(from: 0));
    _startAutoCloseTimer();
  }

  void animateDismiss({bool isAutoClose = false}) {
    if (_isDismissing) return;
    _isDismissing = true;
    _autoCloseTimer?.cancel();
    if (_snapController.isAnimating) {
      _snapController.stop();
    }

    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double totalHeight = _compactHeight + bottomInset;
    final double targetExit = math.max(650, totalHeight + 180);

    if (widget.exitDuration == Duration.zero) {
      _dragOffsetNotifier.value = targetExit;
      if (isAutoClose) {
        (widget.onAutoClose ?? widget.onDismiss)?.call();
      } else {
        widget.onDismiss?.call();
      }
      return;
    }

    final double start = _dragOffsetNotifier.value;
    _exitAnimation = Tween<double>(
      begin: start,
      end: targetExit,
    ).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInCubic,
      ),
    );

    _exitController.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      if (isAutoClose) {
        (widget.onAutoClose ?? widget.onDismiss)?.call();
      } else {
        widget.onDismiss?.call();
      }
    });
  }

  void _animateSnapBack() {
    _snapAnimation = Tween<double>(
      begin: _dragOffsetNotifier.value,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _snapController,
        curve: Curves.easeOutCubic,
      ),
    );
    _snapController.forward(from: 0);
  }

  void _handleVerticalDragStart(DragStartDetails details) {
    if (_isDismissing) return;
    _autoCloseTimer?.cancel();
    if (_snapController.isAnimating) {
      _snapController.stop();
    }
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_isDismissing) return;
    final double delta = details.primaryDelta ?? 0;
    if (delta == 0) return;
    if (_snapController.isAnimating) {
      _snapController.stop();
    }

    if (_dragOffsetNotifier.value > 0) {
      _dragOffsetNotifier.value =
          math.max(0, _dragOffsetNotifier.value + delta);
    } else if (delta > 0) {
      _dragOffsetNotifier.value = delta;
    } else {
      _dragOffsetNotifier.value =
          math.max(-16, _dragOffsetNotifier.value + delta * 0.15);
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_isDismissing) return;
    final double velocity = details.primaryVelocity ?? 0;
    final double currentOffset = _dragOffsetNotifier.value;

    if (currentOffset > _dismissThreshold || velocity > 600) {
      animateDismiss();
      return;
    }

    if (currentOffset != 0) {
      _animateSnapBack();
    }
  }

  void _handleVerticalDragCancel() {
    if (_isDismissing) return;
    if (_dragOffsetNotifier.value != 0) {
      _animateSnapBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final CaptureResult? result = _result;
    if (result == null) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final _ShareSheetCopy copy = _ShareSheetCopy.from(result, l10n);
    final bool isSaved = result.status == CaptureStatus.saved;
    final bool isDuplicate = result.status == CaptureStatus.duplicate;
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double totalHeight = _compactHeight + bottomInset;

    final Widget indicatorWidget;
    if (isSaved) {
      indicatorWidget = const _AnimatedCheckmark(key: ValueKey('saved'));
    } else if (isDuplicate) {
      indicatorWidget = DecoratedBox(
        key: const ValueKey('duplicate'),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.bookmark_added_rounded,
            size: 58,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    } else {
      indicatorWidget = DecoratedBox(
        key: const ValueKey('error'),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            copy.icon,
            size: 58,
            color: theme.colorScheme.error,
          ),
        ),
      );
    }

    final Widget sheetCard = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          left: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          right: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
        height: totalHeight,
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
              // Status indicator isolated in RepaintBoundary
              SizedBox(
                width: 104,
                height: 104,
                child: RepaintBoundary(
                  child: indicatorWidget,
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
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.onOpenApp,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    l10n?.shareOverlayOpenApp ?? 'Open app',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final Widget animatedSheet = AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _entranceController,
        _dragOffsetNotifier,
      ]),
      builder: (BuildContext context, Widget? child) {
        final double entranceFactor =
            1.0 - Curves.easeOutCubic.transform(_entranceController.value);
        final double entranceOffset = entranceFactor * totalHeight;
        final double currentY = entranceOffset + _dragOffsetNotifier.value;

        return Transform.translate(
          offset: Offset(0, currentY),
          child: child,
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragStart: _handleVerticalDragStart,
        onVerticalDragUpdate: _handleVerticalDragUpdate,
        onVerticalDragEnd: _handleVerticalDragEnd,
        onVerticalDragCancel: _handleVerticalDragCancel,
        child: sheetCard,
      ),
    );

    if (!widget.hasInternalScrim) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: animatedSheet,
      );
    }

    final Widget scrim = AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _entranceController,
        _dragOffsetNotifier,
      ]),
      builder: (BuildContext context, Widget? child) {
        final double entranceProgress =
            Curves.easeOut.transform(_entranceController.value);
        final double dragDismissFraction =
            (_dragOffsetNotifier.value / _compactHeight).clamp(0.0, 1.0);
        final double scrimOpacity =
            (entranceProgress * (1.0 - dragDismissFraction)).clamp(0.0, 1.0);

        if (scrimOpacity <= 0.0) {
          return const SizedBox.shrink();
        }

        return Opacity(
          opacity: scrimOpacity,
          child: child,
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: animateDismiss,
        child: const ColoredBox(
          color: Color(0x66000000),
          child: SizedBox.expand(),
        ),
      ),
    );

    return Stack(
      children: <Widget>[
        scrim,
        Align(
          alignment: Alignment.bottomCenter,
          child: animatedSheet,
        ),
      ],
    );
  }
}

class _AnimatedCheckmark extends StatefulWidget {
  const _AnimatedCheckmark({super.key});

  @override
  State<_AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<_AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  late final Animation<double> _circleScale = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
    ),
  );

  late final Animation<double> _checkProgress = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.9, curve: Curves.easeOutCubic),
    ),
  );

  late final Animation<double> _rippleScale = Tween<double>(
    begin: 0.8,
    end: 1.25,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    ),
  );

  late final Animation<double> _rippleOpacity = Tween<double>(
    begin: 0.35,
    end: 0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return SizedBox.square(
            dimension: 104,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                if (_rippleOpacity.value > 0.0)
                  Transform.scale(
                    scale: _rippleScale.value,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF20BF63).withValues(
                          alpha: _rippleOpacity.value,
                        ),
                      ),
                      child: const SizedBox.square(dimension: 88),
                    ),
                  ),
                Transform.scale(
                  scale: _circleScale.value,
                  child: CustomPaint(
                    size: const Size(88, 88),
                    painter: _CheckmarkPainter(
                      checkProgress: _checkProgress.value,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  const _CheckmarkPainter({
    required this.checkProgress,
  });

  final double checkProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    final Paint circlePaint = Paint()
      ..color = const Color(0xFF20BF63)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, circlePaint);

    if (checkProgress <= 0) return;

    final Paint checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final Path fullPath = Path()
      ..moveTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.68)
      ..lineTo(size.width * 0.72, size.height * 0.36);

    final Path path = Path();
    for (final ui.PathMetric metric in fullPath.computeMetrics()) {
      path.addPath(
        metric.extractPath(0, metric.length * checkProgress),
        Offset.zero,
      );
    }

    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) {
    return oldDelegate.checkProgress != checkProgress;
  }
}

class _ShareSheetCopy {
  const _ShareSheetCopy({
    required this.status,
    required this.title,
    required this.message,
    required this.icon,
  });

  final CaptureStatus? status;
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
          status: null,
          title: l10n?.shareOverlaySavingTitle ?? 'Saving',
          message: l10n?.shareOverlaySavingMessage ??
              'Sending the shared item to Marky.',
          icon: Icons.downloading_rounded,
        );
      case CaptureStatus.saved:
        return _ShareSheetCopy(
          status: CaptureStatus.saved,
          title: l10n?.shareOverlaySavedTitle ?? 'Saved',
          message: l10n?.shareOverlaySavedMessage ??
              '1 shared item was saved to Marky.',
          icon: Icons.check_rounded,
        );
      case CaptureStatus.duplicate:
        return _ShareSheetCopy(
          status: CaptureStatus.duplicate,
          title: l10n?.shareOverlayDuplicateTitle ?? 'Already saved',
          message: l10n?.shareOverlayDuplicateMessage ??
              'This shared item is already in your library.',
          icon: Icons.bookmark_added_rounded,
        );
      case CaptureStatus.invalidUrl:
        return _ShareSheetCopy(
          status: CaptureStatus.invalidUrl,
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
          status: CaptureStatus.error,
          title: l10n?.shareOverlayErrorTitle ?? 'Something went wrong',
          message: message,
          icon: Icons.error_outline_rounded,
        );
    }
  }
}
