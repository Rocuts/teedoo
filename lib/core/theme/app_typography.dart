import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Escala tipográfica del Design System.
/// Font: Inter (via Google Fonts)
///
/// Los colores NO se incluyen en los estilos — se heredan del tema
/// o se aplican con `.copyWith(color: context.colors.xxx)`.
abstract final class AppTypography {
  static final String _fontFamily = GoogleFonts.inter().fontFamily!;

  // ── Headings ──

  /// 28px / 700 — KPI grandes, números destacados
  static final TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// 24px / 600 — Títulos de página
  static final TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: 1.25,
  );

  /// 22px / 600 — Títulos de sección (auth cards)
  static final TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  /// 16px / 600 — Títulos de cards
  static final TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.35,
  );

  // ── Body ──

  /// 14px / 400 — Texto general, nav items
  static final TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 14px / 500 — Texto general con peso medio
  static final TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  /// 13px / 400 — Subtítulos, inputs, breadcrumbs
  static final TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// 13px / 500 — Labels de input
  static final TextStyle bodySmallMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  // ── Caption ──

  /// 12px / 400 — Labels, links
  static final TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );

  /// 12px / 500 — Labels con peso medio
  static final TextStyle captionMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  /// 12px / 600 — Badges, labels fuertes
  static final TextStyle captionBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  /// 11px / 500 — Hints, tabla headers
  static final TextStyle captionSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.35,
  );

  /// 11px / 600 — Headers de tabla (uppercase-ready)
  static final TextStyle captionSmallBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.35,
  );

  // ── Special ──

  /// 18px / 600 — Logo "TeeDoo" en sidebar
  static final TextStyle logo = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// 13px / 600 — Texto de botón
  static final TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  /// 14px / 500 — Texto de botón mediano
  static final TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}
