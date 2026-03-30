import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors_theme.dart';
import '../../core/theme/app_radius.dart';

/// SkeletonLoader — Shimmer-based skeleton for loading states.
///
/// Colors: bg-surface base, bg-glass-hover highlight.
/// Uses the shimmer package for the animation effect.

/// Base shimmer wrapper that provides the shimmer animation.
class _ShimmerBase extends StatelessWidget {
  final Widget child;

  const _ShimmerBase({required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colors.bgSurface,
      highlightColor: context.colors.bgGlassHover,
      child: child,
    );
  }
}

/// SkeletonBox — Rectangle skeleton with configurable width and height.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double? borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return _ShimmerBase(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.sm),
        ),
      ),
    );
  }
}

/// SkeletonText — Text-shaped skeleton with configurable number of lines.
class SkeletonText extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double lineSpacing;
  final double? width;

  const SkeletonText({
    super.key,
    this.lines = 3,
    this.lineHeight = 12,
    this.lineSpacing = 8,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return _ShimmerBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < lines; i++) ...[
            if (i > 0) SizedBox(height: lineSpacing),
            Container(
              width: i == lines - 1 ? (width ?? double.infinity) * 0.7 : width,
              height: lineHeight,
              decoration: BoxDecoration(
                color: context.colors.bgSurface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// SkeletonCard — Card-shaped skeleton combining boxes and text.
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonCard({super.key, this.width, this.height = 160});

  @override
  Widget build(BuildContext context) {
    return _ShimmerBase(
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: context.colors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title placeholder
            Container(
              width: 140,
              height: 14,
              decoration: BoxDecoration(
                color: context.colors.bgGlassHover,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle placeholder
            Container(
              width: 200,
              height: 10,
              decoration: BoxDecoration(
                color: context.colors.bgGlassHover,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            // Footer placeholder
            Container(
              width: 100,
              height: 10,
              decoration: BoxDecoration(
                color: context.colors.bgGlassHover,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
