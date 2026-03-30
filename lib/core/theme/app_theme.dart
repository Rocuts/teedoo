import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors_theme.dart';
import 'app_radius.dart';
import 'glass_theme.dart';

/// Modos de tema disponibles en la aplicación.
enum AppThemeMode { system, light, dark }

/// Configuración del ThemeData principal para TeeDoo.
///
/// Genera un ThemeData completo a partir de un [AppColorsTheme] y [GlassTheme].
abstract final class AppTheme {
  /// Tema oscuro (por defecto del diseño)
  static ThemeData get dark => _build(
    colors: AppColorsTheme.dark,
    glass: GlassTheme.dark,
    brightness: Brightness.dark,
  );

  /// Tema claro (blanco)
  static ThemeData get light => _build(
    colors: AppColorsTheme.light,
    glass: GlassTheme.light,
    brightness: Brightness.light,
  );

  /// Devuelve el ThemeData correspondiente al modo dado.
  static ThemeData fromMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return dark;
      case AppThemeMode.light:
      case AppThemeMode.system:
        return light;
    }
  }

  /// Builder interno que genera un ThemeData completo.
  static ThemeData _build({
    required AppColorsTheme colors,
    required GlassTheme glass,
    required Brightness brightness,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final baseTextTheme = isDark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.bgPrimary,
      colorScheme:
          (isDark ? const ColorScheme.dark() : const ColorScheme.light())
              .copyWith(
                primary: colors.accentBlue,
                onPrimary: colors.textOnAccent,
                secondary: colors.accentTeal,
                surface: colors.bgSurface,
                onSurface: colors.textPrimary,
                error: colors.statusError,
                outline: colors.borderSubtle,
              ),
      textTheme: GoogleFonts.interTextTheme(
        baseTextTheme,
      ).apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary),
      dividerColor: colors.borderSubtle,
      dividerTheme: DividerThemeData(
        color: colors.borderSubtle,
        thickness: 1,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.bgInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: colors.accentBlue, width: 1.5),
        ),
        hintStyle: TextStyle(color: colors.textTertiary, fontSize: 13),
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accentBlue,
          foregroundColor: colors.textOnAccent,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size(0, 44),
          side: BorderSide(color: colors.borderSubtle),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accentBlue,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: colors.borderSubtle),
        ),
        textStyle: TextStyle(color: colors.textPrimary, fontSize: 12),
      ),
      extensions: [colors, glass],
    );
  }
}
