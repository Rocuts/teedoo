import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors_theme.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/glass_theme.dart';

/// GlassCard — Componente principal de glassmorphism.
///
/// Implementa el patrón ClipRRect > BackdropFilter > DecoratedBox
/// como recomienda la investigación de Flutter Web 2026.
///
/// Interactive cards (onTap != null) have tactile hover/press states:
/// - Hover: subtle border brightening + micro-scale (1.005)
/// - Press: scale 0.98, accent border glow, reduced blur
///
/// Ref Pencil: Component/GlassCard (f2a9W)
class GlassCard extends StatefulWidget {
  final Widget? header;
  final Widget? content;
  final Widget? actions;
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    this.header,
    this.content,
    this.actions,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _interactive => widget.onTap != null;

  void _handleTapDown(TapDownDetails _) {
    if (!_interactive) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_interactive) return;
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!_interactive) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    final colors = context.colors;

    Widget cardContent;

    if (widget.child != null) {
      cardContent = widget.child!;
    } else {
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.header != null) widget.header!,
          if (widget.content != null) widget.content!,
          if (widget.actions != null) widget.actions!,
        ],
      );
    }

    if (widget.padding != null) {
      cardContent = Padding(padding: widget.padding!, child: cardContent);
    }

    // Compute interactive visual state
    Color borderColor;
    double blurSigma;
    double scale;

    if (_interactive && _isPressed) {
      borderColor = colors.accentBlue.withValues(alpha: 0.3);
      blurSigma = max(10.0, glass.blurSigma - 5);
      scale = 0.98;
    } else if (_interactive && _isHovered) {
      // Increase border opacity by ~0.2 for hover glow
      final baseAlpha = glass.glassBorder.a;
      final hoverAlpha = min(1.0, baseAlpha + 0.2);
      borderColor = glass.glassBorder.withValues(alpha: hoverAlpha);
      blurSigma = glass.blurSigma;
      scale = 1.005;
    } else {
      borderColor = glass.glassBorder;
      blurSigma = glass.blurSigma;
      scale = 1.0;
    }

    Widget card = RepaintBoundary(
      child: ClipRRect(
        borderRadius: AppRadius.cardAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: glass.cardFill,
              borderRadius: AppRadius.cardAll,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: cardContent,
          ),
        ),
      ),
    );

    // Wrap with scale animation for interactive cards
    if (_interactive) {
      card = AnimatedScale(
        scale: scale,
        duration: Duration(milliseconds: _isPressed ? 100 : 200),
        curve: Curves.easeOutCubic,
        child: card,
      );
    }

    // Always wrap in MouseRegion for cursor; add gesture detection
    // only for interactive cards.
    if (_interactive) {
      card = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// GlassCardHeader — Header estándar para GlassCard.
///
/// Ref Pencil: GlassCard.header (LjPen)
class GlassCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const GlassCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.cardPaddingLarge,
        AppSpacing.xxl,
        AppDimensions.cardPaddingLarge,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.h4.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// GlassCardContent — Slot de contenido para GlassCard.
class GlassCardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassCardContent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppDimensions.cardPaddingLarge,
      0,
      AppDimensions.cardPaddingLarge,
      AppSpacing.xxl,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}

/// GlassCardActions — Footer de acciones para GlassCard.
class GlassCardActions extends StatelessWidget {
  final List<Widget> children;

  const GlassCardActions({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.cardPaddingLarge,
        AppSpacing.lg,
        AppDimensions.cardPaddingLarge,
        AppSpacing.xxl,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: children),
    );
  }
}
