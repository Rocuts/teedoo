import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Escala tipográfica del Design System.
/// Font: Inter (via Google Fonts)
///
/// Los colores NO se incluyen en los estilos — se heredan del tema
/// o se aplican con `.copyWith(color: context.colors.xxx)`.
abstract final class AppTypography {
  static String get _fontFamily => GoogleFonts.inter().fontFamily!;

  // ── Headings ──

  /// 28px / 700 — KPI grandes, números destacados
  static TextStyle get h1 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      );

  /// 24px / 600 — Títulos de página
  static TextStyle get h2 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.25,
      );

  /// 22px / 600 — Títulos de sección (auth cards)
  static TextStyle get h3 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
      );

  /// 16px / 600 — Títulos de cards
  static TextStyle get h4 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.35,
      );

  // ── Body ──

  /// 14px / 400 — Texto general, nav items
  static TextStyle get body => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  /// 14px / 500 — Texto general con peso medio
  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  /// 13px / 400 — Subtítulos, inputs, breadcrumbs
  static TextStyle get bodySmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  /// 13px / 500 — Labels de input
  static TextStyle get bodySmallMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.45,
      );

  // ── Caption ──

  /// 12px / 400 — Labels, links
  static TextStyle get caption => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.4,
      );

  /// 12px / 500 — Labels con peso medio
  static TextStyle get captionMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  /// 12px / 600 — Badges, labels fuertes
  static TextStyle get captionBold => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  /// 11px / 500 — Hints, tabla headers
  static TextStyle get captionSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.35,
      );

  /// 11px / 600 — Headers de tabla (uppercase-ready)
  static TextStyle get captionSmallBold => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        height: 1.35,
      );

  // ── Special ──

  /// 18px / 600 — Logo "TeeDoo" en sidebar
  static TextStyle get logo => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  /// 13px / 600 — Texto de botón
  static TextStyle get button => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  /// 14px / 500 — Texto de botón mediano
  static TextStyle get buttonMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );
}
