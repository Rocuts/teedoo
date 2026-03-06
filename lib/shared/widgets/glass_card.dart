import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors_theme.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/glass_theme.dart';

/// GlassCard — Componente principal de glassmorphism.
///
/// Implementa el patrón ClipRRect > BackdropFilter > DecoratedBox
/// como recomienda la investigación de Flutter Web 2026.
///
/// Ref Pencil: Component/GlassCard (f2a9W)
class GlassCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final glass = context.glass;

    Widget cardContent;

    if (child != null) {
      cardContent = child!;
    } else {
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) header!,
          if (content != null) content!,
          if (actions != null) actions!,
        ],
      );
    }

    if (padding != null) {
      cardContent = Padding(
        padding: padding!,
        child: cardContent,
      );
    }

    Widget card = RepaintBoundary(
      child: ClipRRect(
        borderRadius: AppRadius.cardAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: glass.blurSigma,
            sigmaY: glass.blurSigma,
          ),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: glass.cardFill,
              borderRadius: AppRadius.cardAll,
              border: Border.all(
                color: glass.glassBorder,
                width: 1,
              ),
            ),
            child: cardContent,
          ),
        ),
      ),
    );

    if (onTap != null) {
      card = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
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
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// GlassCardActions — Footer de acciones para GlassCard.
class GlassCardActions extends StatelessWidget {
  final List<Widget> children;

  const GlassCardActions({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: children,
      ),
    );
  }
}
