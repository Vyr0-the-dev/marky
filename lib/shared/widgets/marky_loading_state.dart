import 'package:flutter/material.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';

/// A 3-line skeleton placeholder used while content loads.
///
/// Reading Room avoids the "spinner at the centre of a blank screen"
/// pattern — it looks like the app is frozen. Instead we show shimmer-
/// free, subtly-animated skeleton rows that match the shape of the
/// content about to appear. Cheap to build, cheap to animate.
class MarkyLoadingState extends StatefulWidget {
  const MarkyLoadingState({
    this.rowCount = 4,
    super.key,
  });

  final int rowCount;

  @override
  State<MarkyLoadingState> createState() => _MarkyLoadingStateState();
}

class _MarkyLoadingStateState extends State<MarkyLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Respect the user's "disable animations" preference. When set, we
    // render a static skeleton at a single neutral tint.
    final MediaQueryData media = MediaQuery.of(context);
    final bool animate = !media.disableAnimations;

    final Color baseColor = theme.colorScheme.outlineVariant;
    final Color highlightColor = Color.alphaBlend(
      theme.colorScheme.onSurface.withValues(alpha: 0.06),
      baseColor,
    );

    Widget row(double titleFraction, double subtitleFraction) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ReadingRoomSpacing.lg,
          vertical: ReadingRoomSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Bar(
              widthFraction: titleFraction,
              height: 14,
              controller: animate ? _controller : null,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
            const SizedBox(height: ReadingRoomSpacing.sm),
            _Bar(
              widthFraction: subtitleFraction,
              height: 10,
              controller: animate ? _controller : null,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
          ],
        ),
      );
    }

    // Deterministic width variations so it doesn't look like a uniform
    // stamp pattern.
    const List<List<double>> widths = <List<double>>[
      <double>[0.85, 0.55],
      <double>[0.70, 0.40],
      <double>[0.92, 0.60],
      <double>[0.65, 0.35],
      <double>[0.80, 0.50],
    ];

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: widget.rowCount,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final List<double> fractions = widths[index % widths.length];
        return row(fractions[0], fractions[1]);
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.widthFraction,
    required this.height,
    required this.baseColor,
    required this.highlightColor,
    this.controller,
  });

  final double widthFraction;
  final double height;
  final Color baseColor;
  final Color highlightColor;
  final AnimationController? controller;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double width = screenWidth * widthFraction;

    if (controller == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
    }

    return AnimatedBuilder(
      animation: controller!,
      builder: (BuildContext context, _) {
        final Color color =
            Color.lerp(baseColor, highlightColor, controller!.value) ??
                baseColor;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        );
      },
    );
  }
}
