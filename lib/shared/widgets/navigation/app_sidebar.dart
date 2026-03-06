import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/router/route_names.dart';
import 'nav_item.dart';

/// Sidebar principal de la aplicación.
///
/// Soporta 2 modos:
/// - Expandido (260px): icono + label  (desktop >= 1200)
/// - Colapsado (72px): solo icono       (tablet 600-1199)
///
/// En móvil (< 600) el sidebar no se renderiza — se usa un Drawer.
class AppSidebar extends StatefulWidget {
  final String currentPath;
  final bool initiallyCollapsed;

  const AppSidebar({
    super.key,
    required this.currentPath,
    this.initiallyCollapsed = false,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  late bool _collapsed;

  static const double expandedWidth = AppDimensions.sidebarExpandedWidth;
  static const double collapsedWidth = AppDimensions.sidebarCollapsedWidth;

  @override
  void initState() {
    super.initState();
    _collapsed = widget.initiallyCollapsed;
  }

  @override
  void didUpdateWidget(covariant AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyCollapsed != widget.initiallyCollapsed) {
      _collapsed = widget.initiallyCollapsed;
    }
  }

  double get _width => _collapsed ? collapsedWidth : expandedWidth;

  void _toggleCollapse() {
    setState(() {
      _collapsed = !_collapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
      width: _width,
      height: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: context.colors.bgSidebar,
        border: Border(
          right: BorderSide(color: context.colors.borderSubtle),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(_collapsed ? 12 : 16)
            .copyWith(top: 20, bottom: 20),
        child: Column(
          crossAxisAlignment:
              _collapsed ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            // ── Logo ──
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _collapsed ? _buildCollapsedLogo(context) : _buildLogo(context),
            ),

            // ── Nav Items ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildNavItems(context),
                  ),
                ),
              ),
            ),

            // ── Footer ──
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: context.colors.borderSubtle),
                ),
              ),
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  _collapsed
                      ? _buildCollapsedNavItem(
                          context,
                          icon: LucideIcons.helpCircle,
                          isActive: false,
                          onTap: () {},
                          tooltip: 'Ayuda',
                        )
                      : NavItem(
                          icon: LucideIcons.helpCircle,
                          label: 'Ayuda',
                          onTap: () {},
                        ),
                  const SizedBox(height: 8),
                  _collapsed
                      ? _buildCollapsedNavItem(
                          context,
                          icon: LucideIcons.chevronRight,
                          isActive: false,
                          onTap: _toggleCollapse,
                          tooltip: 'Expandir',
                        )
                      : NavItem(
                          icon: LucideIcons.chevronLeft,
                          label: 'Colapsar',
                          onTap: _toggleCollapse,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/logo.png',
              width: 32, height: 32, fit: BoxFit.contain),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'TeDoo',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedLogo(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset('assets/images/logo.png',
          width: 32, height: 32, fit: BoxFit.contain),
    );
  }

  List<Widget> _buildNavItems(BuildContext context) {
    const items = [
      _NavDef(LucideIcons.layoutDashboard, 'Dashboard', RoutePaths.dashboard),
      _NavDef(LucideIcons.fileText, 'Facturas', RoutePaths.invoices),
      _NavDef(LucideIcons.folderOpen, 'Documentos por Facturas', RoutePaths.invoiceDocuments),
      _NavDef(LucideIcons.shieldCheck, 'Compliance IA', RoutePaths.compliance),
      _NavDef(LucideIcons.scrollText, 'Evidencias', RoutePaths.audit),
      _NavDef(LucideIcons.settings, 'Configuración', RoutePaths.settings),
    ];

    final widgets = <Widget>[];
    for (final item in items) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 2));
      bool isActive = widget.currentPath.startsWith(item.path);
      if (item.label == 'Facturas' && widget.currentPath.contains('documentos')) isActive = false;
      if (item.label == 'Documentos por Facturas' && !widget.currentPath.contains('documentos')) isActive = false;
      if (_collapsed) {
        widgets.add(_buildCollapsedNavItem(
          context,
          icon: item.icon,
          isActive: isActive,
          onTap: () => context.go(item.path),
          tooltip: item.label,
        ));
      } else {
        widgets.add(NavItem(
          icon: item.icon,
          label: item.label,
          isActive: isActive,
          onTap: () => context.go(item.path),
        ));
      }
    }
    return widgets;
  }

  Widget _buildCollapsedNavItem(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    final iconColor =
        isActive ? context.colors.accentBlue : context.colors.textTertiary;
    final bgColor =
        isActive ? context.colors.accentBlueSubtle : Colors.transparent;

    return Semantics(
      button: true,
      label: tooltip,
      selected: isActive,
      child: Tooltip(
        message: tooltip,
        preferBelow: false,
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: bgColor,
          borderRadius: AppRadius.buttonAll,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.buttonAll,
            hoverColor: isActive ? null : context.colors.bgGlassHover,
            child: ExcludeSemantics(
              child: SizedBox(
                width: AppDimensions.collapsedNavItemSize,
                height: AppDimensions.collapsedNavItemSize,
                child: Icon(icon, size: AppDimensions.iconSize, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget Drawer para móvil — reutiliza la misma navegación del sidebar.
class AppDrawer extends StatelessWidget {
  final String currentPath;

  const AppDrawer({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.colors.bgSidebar,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16).copyWith(top: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ──
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/images/logo.png',
                          width: 32, height: 32, fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'TeDoo',
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(LucideIcons.x,
                          size: AppDimensions.iconSize, color: context.colors.textSecondary),
                      tooltip: 'Cerrar menú',
                    ),
                  ],
                ),
              ),

              // ── Nav Items ──
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _drawerItem(context, LucideIcons.layoutDashboard,
                          'Dashboard', RoutePaths.dashboard),
                      const SizedBox(height: 2),
                      _drawerItem(context, LucideIcons.fileText, 'Facturas',
                          RoutePaths.invoices),
                      const SizedBox(height: 2),
                      _drawerItem(context, LucideIcons.folderOpen, 'Documentos por Facturas',
                          RoutePaths.invoiceDocuments),
                      const SizedBox(height: 2),
                      _drawerItem(context, LucideIcons.shieldCheck,
                          'Compliance IA', RoutePaths.compliance),
                      const SizedBox(height: 2),
                      _drawerItem(context, LucideIcons.scrollText, 'Evidencias',
                          RoutePaths.audit),
                      const SizedBox(height: 2),
                      _drawerItem(context, LucideIcons.settings, 'Configuración',
                          RoutePaths.settings),
                    ],
                  ),
                ),
              ),

              // ── Footer ──
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: context.colors.borderSubtle),
                  ),
                ),
                padding: const EdgeInsets.only(top: 16),
                child: NavItem(
                  icon: LucideIcons.helpCircle,
                  label: 'Ayuda',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    String path,
  ) {
    bool isActive = currentPath.startsWith(path);
    if (label == 'Facturas' && currentPath.contains('documentos')) isActive = false;
    if (label == 'Documentos por Facturas' && !currentPath.contains('documentos')) isActive = false;
    return NavItem(
      icon: icon,
      label: label,
      isActive: isActive,
      onTap: () {
        Navigator.of(context).pop();
        context.go(path);
      },
    );
  }
}

class _NavDef {
  final IconData icon;
  final String label;
  final String path;
  const _NavDef(this.icon, this.label, this.path);
}
