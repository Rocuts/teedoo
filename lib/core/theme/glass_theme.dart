import 'dart:ui';

import 'package:flutter/material.dart';

/// ThemeExtension para los tokens de glassmorphism.
/// Permite interpolar entre temas (dark/light/gray) con animación.
class GlassTheme extends ThemeExtension<GlassTheme> {
  final double blurSigma;
  final Color cardFill;
  final Color glassFill;
  final Color glassBorder;
  final Color glassHover;
  final double cardRadius;

  const GlassTheme({
    required this.blurSigma,
    required this.cardFill,
    required this.glassFill,
    required this.glassBorder,
    required this.glassHover,
    required this.cardRadius,
  });

  /// Tema oscuro — Negro + Violeta
  /// Glass con bordes morado sutil, blur fuerte para efecto premium
  static const dark = GlassTheme(
    blurSigma: 40.0,
    cardFill: Color(0x441C2128), // dark surface semi
    glassFill: Color(0x331C2128), // glass dark
    glassBorder: Color(0x338B5CF6), // violet-500 tinted border
    glassHover: Color(0x552D333B),
    cardRadius: 16.0,
  );

  /// Tema claro — Blanco + Violeta
  /// Cards con sombra sutil y bordes violet-200 en vez de glassmorphism
  static const light = GlassTheme(
    blurSigma: 16.0,
    cardFill: Color(0xEEFFFFFF), // card casi opaca
    glassFill: Color(0x99F5F3FF), // glass violet-50 tinted
    glassBorder: Color(0x88E9D5FF), // violet-200 semi
    glassHover: Color(0x88F3E8FF), // violet-100 hover
    cardRadius: 16.0,
  );

  @override
  GlassTheme copyWith({
    double? blurSigma,
    Color? cardFill,
    Color? glassFill,
    Color? glassBorder,
    Color? glassHover,
    double? cardRadius,
  }) {
    return GlassTheme(
      blurSigma: blurSigma ?? this.blurSigma,
      cardFill: cardFill ?? this.cardFill,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      glassHover: glassHover ?? this.glassHover,
      cardRadius: cardRadius ?? this.cardRadius,
    );
  }

  @override
  GlassTheme lerp(covariant GlassTheme? other, double t) {
    if (other == null) return this;
    return GlassTheme(
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
      cardFill: Color.lerp(cardFill, other.cardFill, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassHover: Color.lerp(glassHover, other.glassHover, t)!,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
    );
  }
}

/// Extension en BuildContext para acceso ergonómico.
extension GlassThemeX on BuildContext {
  GlassTheme get glass => Theme.of(this).extension<GlassTheme>()!;
}
