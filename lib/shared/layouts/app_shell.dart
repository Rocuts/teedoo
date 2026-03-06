import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_colors_theme.dart';
import '../widgets/ai/ai_orbit_widget.dart';
import '../widgets/navigation/app_sidebar.dart';

/// AppShell — Layout principal con sidebar + área de contenido.
///
/// Adapta la navegación según el viewport:
/// - Compact (< 600): sin sidebar, Drawer via hamburger en topbar
/// - Medium (600-1199): sidebar colapsado (72px, solo iconos)
/// - Expanded (>= 1200): sidebar completo (260px)
class AppShell extends StatelessWidget {
  final String currentPath;
  final Widget child;

  const AppShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSize;

    return Stack(
      children: [
        Scaffold(
          key: ValueKey(currentPath),
          backgroundColor: context.colors.bgPrimary,
          // Drawer solo en compact
          drawer: screenSize == ScreenSize.compact
              ? AppDrawer(currentPath: currentPath)
              : null,
          body: Row(
            children: [
              // ── Sidebar (medium + expanded) ──
              if (screenSize != ScreenSize.compact)
                AppSidebar(
                  currentPath: currentPath,
                  initiallyCollapsed: screenSize == ScreenSize.medium,
                ),

              // ── Área principal (fill) ──
              Expanded(
                child: ClipRect(child: child),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: screenSize == ScreenSize.compact ? 16 : 40,
          right: screenSize == ScreenSize.compact ? 16 : 40,
          child: const Material(
            type: MaterialType.transparency,
            child: AiOrbitWidget(),
          ),
        ),
      ],
    );
  }
}
