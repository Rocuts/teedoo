/// Sistema de spacing — escala estricta de 4px.
///
/// Principio: el espacio vacío comunica jerarquía y profesionalismo.
/// Regla: TODOS los valores deben ser múltiplos de 4. Sin excepciones.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s36 = 36;
  static const double s40 = 40;
  static const double s48 = 48;

  // ── Layout-specific (generoso, enterprise) ──

  /// Padding interno del content area principal
  static const double contentPaddingVertical = 32;
  static const double contentPaddingHorizontal = 40;

  /// Gap entre elementos del content
  static const double contentGap = 28;

  /// Padding interno de cards
  static const double cardPadding = 28;

  /// Gap en KPI rows
  static const double kpiGap = 20;

  /// Gap en formularios
  static const double formGap = 24;

  /// Gap en botones agrupados
  static const double buttonGap = 12;
}
