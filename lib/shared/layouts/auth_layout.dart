import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors_theme.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/glass_theme.dart';

/// AuthLayout — Layout wrapper para pantallas de autenticación.
///
/// Common layout for Login, MFA, ForgotPassword screens.
/// - Scaffold with bg-primary
/// - Center child
/// - Optional glassmorphism card wrapper (configurable width)
class AuthLayout extends StatelessWidget {
  final Widget child;
  final double? cardWidth;
  final bool wrapInCard;

  const AuthLayout({
    super.key,
    required this.child,
    this.cardWidth = 440,
    this.wrapInCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = wrapInCard
        ? _GlassAuthCard(
            width: cardWidth,
            child: child,
          )
        : child;

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: Center(child: content),
    );
  }
}

/// Card glassmorphism para auth screens.
class _GlassAuthCard extends StatelessWidget {
  final Widget child;
  final double? width;

  const _GlassAuthCard({
    required this.child,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: AppRadius.cardAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: glass.blurSigma,
            sigmaY: glass.blurSigma,
          ),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: glass.cardFill,
              borderRadius: AppRadius.cardAll,
              border: Border.all(
                color: glass.glassBorder,
              ),
            ),
            padding: const EdgeInsets.all(32),
            child: child,
          ),
        ),
      ),
    );
  }
}
