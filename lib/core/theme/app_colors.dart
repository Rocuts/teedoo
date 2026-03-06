import 'package:flutter/material.dart';

/// Design tokens de color — "Purple Enterprise"
///
/// Estética: Premium dark/light con violeta como acento principal.
/// Dark: negro (#0D1117) + violet-500 (#8B5CF6)
/// Light: blanco (#FAFAFA) + violet-600 (#7C3AED)
abstract final class AppColors {
  // ── Background (dark mode) ──
  static const bgPrimary = Color(0xFF0D1117);      // GitHub dark
  static const bgSecondary = Color(0xFF161B22);
  static const bgSurface = Color(0xFF1C2128);
  static const bgCard = Color(0x441C2128);          // surface semi
  static const bgGlass = Color(0x331C2128);          // glass surface
  static const bgGlassBorder = Color(0x338B5CF6);   // purple-tinted border
  static const bgGlassHover = Color(0x552D333B);
  static const bgInput = Color(0x660D1117);          // input semi
  static const bgModal = Color(0xEE161B22);
  static const bgSidebar = Color(0xFF0D1117);
  static const bgTopbar = Color(0x99161B22);

  // ── Text (alto contraste, limpio) ──
  static const textPrimary = Color(0xFFF0F3F6);
  static const textSecondary = Color(0xFF9EA7B3);
  static const textTertiary = Color(0xFF636E7B);
  static const textOnAccent = Color(0xFFFFFFFF);

  // ── Accent (violeta como primario) ──
  static const accentBlue = Color(0xFF8B5CF6);      // violet-500 (primary)
  static const accentBlueHover = Color(0xFFA78BFA);  // violet-400
  static const accentBlueSubtle = Color(0x1A8B5CF6);
  static const accentTeal = Color(0xFF7C3AED);       // violet-600 (secondary)

  // ── AI (mismo violeta, badges/sparkles) ──
  static const aiPurple = Color(0xFFA78BFA);         // violet-400
  static const aiPurpleBg = Color(0x1AA78BFA);
  static const aiPurpleBorder = Color(0x33A78BFA);

  // ── Status (limpios, saturados) ──
  static const statusSuccess = Color(0xFF3FB950);
  static const statusSuccessBg = Color(0x1A3FB950);
  static const statusWarning = Color(0xFFD29922);
  static const statusWarningBg = Color(0x1AD29922);
  static const statusError = Color(0xFFF85149);
  static const statusErrorBg = Color(0x1AF85149);
  static const statusInfo = Color(0xFF58A6FF);
  static const statusInfoBg = Color(0x1A58A6FF);

  // ── Border ──
  static const borderPrimary = Color(0xFF3D444D);
  static const borderSubtle = Color(0x448B5CF6);    // purple-tinted subtle
  static const borderAccent = Color(0x448B5CF6);    // purple accent border
}
