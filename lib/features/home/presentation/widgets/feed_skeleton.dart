import 'package:flutter/material.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';

/// Skeleton loading state for the feed — mimics the [BookmarkCard]
/// layout with animated placeholder bars and a square thumbnail.
class FeedSkeleton extends StatefulWidget {
  const FeedSkeleton({this.itemCount = 6, super.key});

  final int itemCount;

  @override
  State<FeedSkeleton> createState() => _FeedSkeletonState();
}

class _FeedSkeletonState extends State<FeedSkeleton>
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
    final bool animate = !MediaQuery.of(context).disableAnimations;

    final Color baseColor = theme.colorScheme.outlineVariant;
    final Color highlightColor = Color.alphaBlend(
      theme.colorScheme.onSurface.withValues(alpha: 0.06),
      baseColor,
    );

    // Deterministic variations so it doesn't look stamped.
    const List<double> titleWidths = <double>[
      0.7,
      0.85,
      0.6,
      0.9,
      0.75,
      0.65,
    ];
    const List<double> subtitleWidths = <double>[
      0.4,
      0.35,
      0.5,
      0.3,
      0.45,
      0.38,
    ];

    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ReadingRoomSpacing.lg,
            vertical: ReadingRoomSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Thumbnail placeholder
              _AnimatedBox(
                width: 64,
                height: 64,
                borderRadius: ReadingRoomRadii.standard,
                controller: animate ? _controller : null,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              const SizedBox(width: ReadingRoomSpacing.md),
              // Text lines
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: ReadingRoomSpacing.xs),
                    _AnimatedBar(
                      widthFraction: titleWidths[index % titleWidths.length],
                      height: 14,
                      controller: animate ? _controller : null,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                    const SizedBox(height: ReadingRoomSpacing.sm),
                    _AnimatedBar(
                      widthFraction:
                          subtitleWidths[index % subtitleWidths.length],
                      height: 10,
                      controller: animate ? _controller : null,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                    const SizedBox(height: ReadingRoomSpacing.sm),
                    _AnimatedBar(
                      widthFraction: 0.2,
                      height: 10,
                      controller: animate ? _controller : null,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Shared building blocks ──────────────────────────────────────

class _AnimatedBar extends StatelessWidget {
  const _AnimatedBar({
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
    return _animated(
      width: width,
      height: height,
      borderRadius: height / 2,
    );
  }

  Widget _animated({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    if (controller == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }
    return AnimatedBuilder(
      animation: controller!,
      builder: (_, __) {
        final Color color =
            Color.lerp(baseColor, highlightColor, controller!.value) ??
                baseColor;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }
}

class _AnimatedBox extends StatelessWidget {
  const _AnimatedBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.baseColor,
    required this.highlightColor,
    this.controller,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;
  final AnimationController? controller;

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }
    return AnimatedBuilder(
      animation: controller!,
      builder: (_, __) {
        final Color color =
            Color.lerp(baseColor, highlightColor, controller!.value) ??
                baseColor;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }
}
