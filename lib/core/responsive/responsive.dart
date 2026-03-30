import 'package:flutter/material.dart';

/// Breakpoints siguiendo Material 3 Window Size Classes simplificado.
///
/// - Compact (< 600): móviles — drawer + bottom nav
/// - Medium (600-1199): tablets — sidebar colapsado (rail, ~72px)
/// - Expanded (>= 1200): desktop — sidebar completo (~260px)
abstract final class Breakpoints {
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
  static const double large = 1600;
}

/// Tamaño de pantalla semántico.
enum ScreenSize { compact, medium, expanded }

/// Extension de BuildContext para consultas responsive.
///
/// Usa `MediaQuery.sizeOf(context)` (Flutter 3.10+) para eficiencia —
/// solo se reconstruye al cambiar el tamaño, no al cambiar padding/insets.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isCompact => screenWidth < Breakpoints.compact;
  bool get isMedium =>
      screenWidth >= Breakpoints.compact && screenWidth < Breakpoints.expanded;
  bool get isExpanded => screenWidth >= Breakpoints.expanded;
  bool get isWideDesktop => screenWidth >= Breakpoints.large;

  ScreenSize get screenSize {
    if (isCompact) return ScreenSize.compact;
    if (isMedium) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  /// Retorna un valor adaptativo por breakpoint.
  T responsive<T>({required T compact, T? medium, required T expanded}) {
    if (isCompact) return compact;
    if (isMedium) return medium ?? expanded;
    return expanded;
  }

  /// Padding horizontal adaptativo para áreas de contenido.
  double get contentPaddingH =>
      responsive(compact: 16.0, medium: 24.0, expanded: 32.0);

  /// Padding vertical adaptativo para áreas de contenido.
  double get contentPaddingV =>
      responsive(compact: 16.0, medium: 24.0, expanded: 28.0);
}

/// Widget que construye layouts diferentes según el breakpoint.
///
/// Usa LayoutBuilder para reaccionar al espacio disponible (no al viewport).
class ResponsiveLayout extends StatelessWidget {
  final Widget compact;
  final Widget? medium;
  final Widget expanded;

  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.compact) {
          return compact;
        }
        if (constraints.maxWidth < Breakpoints.expanded) {
          return medium ?? expanded;
        }
        return expanded;
      },
    );
  }
}
