import 'package:flutter/material.dart';

/// ThemeExtension con todos los colores semánticos de la app.
///
/// Permite interpolación animada entre temas (dark ↔ light ↔ gray).
/// Acceso vía `context.colors`.
class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  // ── Background ──
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgSurface;
  final Color bgCard;
  final Color bgGlass;
  final Color bgGlassBorder;
  final Color bgGlassHover;
  final Color bgInput;
  final Color bgModal;
  final Color bgSidebar;
  final Color bgTopbar;

  // ── Text ──
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnAccent;

  // ── Accent ──
  final Color accentBlue;
  final Color accentBlueHover;
  final Color accentBlueSubtle;
  final Color accentTeal;

  // ── AI ──
  final Color aiPurple;
  final Color aiPurpleBg;
  final Color aiPurpleBorder;

  // ── Status ──
  final Color statusSuccess;
  final Color statusSuccessBg;
  final Color statusWarning;
  final Color statusWarningBg;
  final Color statusError;
  final Color statusErrorBg;
  final Color statusInfo;
  final Color statusInfoBg;

  // ── Border ──
  final Color borderPrimary;
  final Color borderSubtle;
  final Color borderAccent;

  const AppColorsTheme({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgSurface,
    required this.bgCard,
    required this.bgGlass,
    required this.bgGlassBorder,
    required this.bgGlassHover,
    required this.bgInput,
    required this.bgModal,
    required this.bgSidebar,
    required this.bgTopbar,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnAccent,
    required this.accentBlue,
    required this.accentBlueHover,
    required this.accentBlueSubtle,
    required this.accentTeal,
    required this.aiPurple,
    required this.aiPurpleBg,
    required this.aiPurpleBorder,
    required this.statusSuccess,
    required this.statusSuccessBg,
    required this.statusWarning,
    required this.statusWarningBg,
    required this.statusError,
    required this.statusErrorBg,
    required this.statusInfo,
    required this.statusInfoBg,
    required this.borderPrimary,
    required this.borderSubtle,
    required this.borderAccent,
  });

  // ═══════════════════════════════════════════════════════════════
  // DARK — Negro + Violeta
  //
  // Fondo: #0D1117 (GitHub dark) + violet-500 (#8B5CF6) como acento
  // Bordes con tinte violeta sutil para identidad de marca
  // ═══════════════════════════════════════════════════════════════
  static const dark = AppColorsTheme(
    bgPrimary: Color(0xFF0D1117), // fondo principal
    bgSecondary: Color(0xFF161B22),
    bgSurface: Color(0xFF1C2128),
    bgCard: Color(0x441C2128),
    bgGlass: Color(0x331C2128),
    bgGlassBorder: Color(0x338B5CF6), // purple-tinted border
    bgGlassHover: Color(0x552D333B),
    bgInput: Color(0x660D1117),
    bgModal: Color(0xEE161B22),
    bgSidebar: Color(0xFF0D1117),
    bgTopbar: Color(0x99161B22),
    textPrimary: Color(0xFFF0F3F6),
    textSecondary: Color(0xFF9EA7B3),
    textTertiary: Color(0xFF8B95A1),
    textOnAccent: Color(0xFFFFFFFF),
    accentBlue: Color(0xFF8B5CF6), // violet-500 (primary CTA)
    accentBlueHover: Color(0xFFA78BFA), // violet-400
    accentBlueSubtle: Color(0x1A8B5CF6),
    accentTeal: Color(0xFF7C3AED), // violet-600 (secondary)
    aiPurple: Color(0xFFA78BFA), // violet-400 (AI)
    aiPurpleBg: Color(0x1AA78BFA),
    aiPurpleBorder: Color(0x33A78BFA),
    statusSuccess: Color(0xFF3FB950),
    statusSuccessBg: Color(0x1A3FB950),
    statusWarning: Color(0xFFD29922),
    statusWarningBg: Color(0x1AD29922),
    statusError: Color(0xFFF85149),
    statusErrorBg: Color(0x1AF85149),
    statusInfo: Color(0xFF58A6FF),
    statusInfoBg: Color(0x1A58A6FF),
    borderPrimary: Color(0xFF3D444D),
    borderSubtle: Color(0x448B5CF6), // purple-tinted subtle
    borderAccent: Color(0x448B5CF6),
  );

  // ═══════════════════════════════════════════════════════════════
  // LIGHT — Blanco + Violeta
  //
  // Fondo: #FAFAFA + sidebar violet-50 (#F5F3FF)
  // Acento: violet-600 (#7C3AED) para contraste AA sobre blanco
  // Cards: sombra sutil + borde violet-200
  // ═══════════════════════════════════════════════════════════════
  static const light = AppColorsTheme(
    bgPrimary: Color(0xFFFAFAFA), // fondo principal gris claro
    bgSecondary: Color(0xFFF5F3FF), // violet-50
    bgSurface: Color(0xFFFFFFFF),
    bgCard: Color(0xEEFFFFFF), // cards casi opacas
    bgGlass: Color(0x99F5F3FF), // glass con tinte violet
    bgGlassBorder: Color(0x88E9D5FF), // violet-200 semi
    bgGlassHover: Color(0x88F3E8FF),
    bgInput: Color(0xFFF3F4F6), // gray-100
    bgModal: Color(0xF0FFFFFF),
    bgSidebar: Color(0xFFF5F3FF), // violet-50 sidebar
    bgTopbar: Color(0xEEFFFFFF),
    textPrimary: Color(0xFF1E1B4B), // indigo-950 (profundo)
    textSecondary: Color(0xFF6B7280), // gray-500
    textTertiary: Color(0xFF6B7280), // gray-500 (WCAG AA)
    textOnAccent: Color(0xFFFFFFFF),
    accentBlue: Color(0xFF7C3AED), // violet-600 (contraste AA)
    accentBlueHover: Color(0xFF6D28D9), // violet-700
    accentBlueSubtle: Color(0x1A7C3AED),
    accentTeal: Color(0xFF8B5CF6), // violet-500 (secondary)
    aiPurple: Color(0xFF8B5CF6), // violet-500 (AI)
    aiPurpleBg: Color(0x1A8B5CF6),
    aiPurpleBorder: Color(0x338B5CF6),
    statusSuccess: Color(0xFF16A34A), // green-600
    statusSuccessBg: Color(0x1A16A34A),
    statusWarning: Color(0xFFCA8A04), // yellow-600
    statusWarningBg: Color(0x1ACA8A04),
    statusError: Color(0xFFDC2626), // red-600
    statusErrorBg: Color(0x1ADC2626),
    statusInfo: Color(0xFF2563EB), // blue-600
    statusInfoBg: Color(0x1A2563EB),
    borderPrimary: Color(0xFFE5E7EB), // gray-200
    borderSubtle: Color(0xFFE5E7EB),
    borderAccent: Color(0x448B5CF6), // purple accent
  );

  @override
  AppColorsTheme copyWith({
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgSurface,
    Color? bgCard,
    Color? bgGlass,
    Color? bgGlassBorder,
    Color? bgGlassHover,
    Color? bgInput,
    Color? bgModal,
    Color? bgSidebar,
    Color? bgTopbar,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnAccent,
    Color? accentBlue,
    Color? accentBlueHover,
    Color? accentBlueSubtle,
    Color? accentTeal,
    Color? aiPurple,
    Color? aiPurpleBg,
    Color? aiPurpleBorder,
    Color? statusSuccess,
    Color? statusSuccessBg,
    Color? statusWarning,
    Color? statusWarningBg,
    Color? statusError,
    Color? statusErrorBg,
    Color? statusInfo,
    Color? statusInfoBg,
    Color? borderPrimary,
    Color? borderSubtle,
    Color? borderAccent,
  }) {
    return AppColorsTheme(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgSurface: bgSurface ?? this.bgSurface,
      bgCard: bgCard ?? this.bgCard,
      bgGlass: bgGlass ?? this.bgGlass,
      bgGlassBorder: bgGlassBorder ?? this.bgGlassBorder,
      bgGlassHover: bgGlassHover ?? this.bgGlassHover,
      bgInput: bgInput ?? this.bgInput,
      bgModal: bgModal ?? this.bgModal,
      bgSidebar: bgSidebar ?? this.bgSidebar,
      bgTopbar: bgTopbar ?? this.bgTopbar,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      accentBlue: accentBlue ?? this.accentBlue,
      accentBlueHover: accentBlueHover ?? this.accentBlueHover,
      accentBlueSubtle: accentBlueSubtle ?? this.accentBlueSubtle,
      accentTeal: accentTeal ?? this.accentTeal,
      aiPurple: aiPurple ?? this.aiPurple,
      aiPurpleBg: aiPurpleBg ?? this.aiPurpleBg,
      aiPurpleBorder: aiPurpleBorder ?? this.aiPurpleBorder,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusSuccessBg: statusSuccessBg ?? this.statusSuccessBg,
      statusWarning: statusWarning ?? this.statusWarning,
      statusWarningBg: statusWarningBg ?? this.statusWarningBg,
      statusError: statusError ?? this.statusError,
      statusErrorBg: statusErrorBg ?? this.statusErrorBg,
      statusInfo: statusInfo ?? this.statusInfo,
      statusInfoBg: statusInfoBg ?? this.statusInfoBg,
      borderPrimary: borderPrimary ?? this.borderPrimary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderAccent: borderAccent ?? this.borderAccent,
    );
  }

  @override
  AppColorsTheme lerp(covariant AppColorsTheme? other, double t) {
    if (other == null) return this;
    return AppColorsTheme(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgGlass: Color.lerp(bgGlass, other.bgGlass, t)!,
      bgGlassBorder: Color.lerp(bgGlassBorder, other.bgGlassBorder, t)!,
      bgGlassHover: Color.lerp(bgGlassHover, other.bgGlassHover, t)!,
      bgInput: Color.lerp(bgInput, other.bgInput, t)!,
      bgModal: Color.lerp(bgModal, other.bgModal, t)!,
      bgSidebar: Color.lerp(bgSidebar, other.bgSidebar, t)!,
      bgTopbar: Color.lerp(bgTopbar, other.bgTopbar, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      accentBlueHover: Color.lerp(accentBlueHover, other.accentBlueHover, t)!,
      accentBlueSubtle: Color.lerp(
        accentBlueSubtle,
        other.accentBlueSubtle,
        t,
      )!,
      accentTeal: Color.lerp(accentTeal, other.accentTeal, t)!,
      aiPurple: Color.lerp(aiPurple, other.aiPurple, t)!,
      aiPurpleBg: Color.lerp(aiPurpleBg, other.aiPurpleBg, t)!,
      aiPurpleBorder: Color.lerp(aiPurpleBorder, other.aiPurpleBorder, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusSuccessBg: Color.lerp(statusSuccessBg, other.statusSuccessBg, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusWarningBg: Color.lerp(statusWarningBg, other.statusWarningBg, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
      statusErrorBg: Color.lerp(statusErrorBg, other.statusErrorBg, t)!,
      statusInfo: Color.lerp(statusInfo, other.statusInfo, t)!,
      statusInfoBg: Color.lerp(statusInfoBg, other.statusInfoBg, t)!,
      borderPrimary: Color.lerp(borderPrimary, other.borderPrimary, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderAccent: Color.lerp(borderAccent, other.borderAccent, t)!,
    );
  }
}

/// Acceso ergonómico: `context.colors.accentBlue`
extension AppColorsThemeX on BuildContext {
  AppColorsTheme get colors => Theme.of(this).extension<AppColorsTheme>()!;
}
