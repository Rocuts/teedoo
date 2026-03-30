import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';

/// Topbar principal de la aplicación.
///
/// Responsive:
/// - Compact: hamburger menu + título, acciones colapsadas a iconos
/// - Medium/Expanded: breadcrumbs completos + todas las acciones
class AppTopbar extends ConsumerWidget {
  final List<BreadcrumbItem> breadcrumbs;

  const AppTopbar({super.key, this.breadcrumbs = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = context.isCompact;

    return Container(
      height: AppDimensions.topbarHeight,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 24),
      decoration: BoxDecoration(
        color: context.colors.bgTopbar,
        border: Border(bottom: BorderSide(color: context.colors.borderSubtle)),
      ),
      child: Row(
        children: [
          // ── Hamburger (compact only) ──
          if (isCompact) ...[
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(
                LucideIcons.menu,
                size: AppDimensions.iconSize,
                color: context.colors.textPrimary,
              ),
              tooltip: 'Menú',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: AppDimensions.touchTargetSize,
                minHeight: AppDimensions.touchTargetSize,
              ),
            ),
            const SizedBox(width: 4),
          ],

          // ── Breadcrumbs / Title ──
          Expanded(
            child: isCompact
                ? _buildCompactTitle(context)
                : _buildBreadcrumbs(context),
          ),

          // ── Actions ──
          if (isCompact)
            _buildCompactActions(context, ref)
          else
            _buildFullActions(context, ref),
        ],
      ),
    );
  }

  Widget _buildCompactTitle(BuildContext context) {
    final title = breadcrumbs.isNotEmpty ? breadcrumbs.last.label : '';
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: context.colors.textPrimary,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < breadcrumbs.length; i++) ...[
          if (i > 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '/',
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textTertiary,
                ),
              ),
            ),
          ],
          if (i == breadcrumbs.length - 1)
            Flexible(
              child: Text(
                breadcrumbs[i].label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            Flexible(
              child: Semantics(
                button: true,
                label: 'Ir a ${breadcrumbs[i].label}',
                child: InkWell(
                  onTap: breadcrumbs[i].onTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Text(
                    breadcrumbs[i].label,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  /// Acciones completas en desktop/tablet.
  Widget _buildFullActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Lang selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colors.borderSubtle),
          ),
          child: Row(
            children: [
              Text(
                'ES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                LucideIcons.chevronDown,
                size: 12,
                color: context.colors.textTertiary,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Search
        IconButton(
          onPressed: () {},
          icon: Icon(
            LucideIcons.search,
            size: 20,
            color: context.colors.textSecondary,
          ),
          tooltip: 'Buscar',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        const SizedBox(width: 8),

        // Notifications
        IconButton(
          onPressed: () {},
          icon: Icon(
            LucideIcons.bell,
            size: 20,
            color: context.colors.textSecondary,
          ),
          tooltip: 'Notificaciones',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        const SizedBox(width: 8),

        // Theme switcher
        _ThemeSwitcher(ref: ref),
        const SizedBox(width: 12),

        // Avatar
        _buildAvatar(context),
      ],
    );
  }

  /// Acciones mínimas en móvil.
  Widget _buildCompactActions(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            LucideIcons.bell,
            size: 20,
            color: context.colors.textSecondary,
          ),
          tooltip: 'Notificaciones',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        const SizedBox(width: 4),
        _ThemeSwitcher(ref: ref),
        const SizedBox(width: 8),
        _buildAvatar(context),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: AppDimensions.avatarSize,
      height: AppDimensions.avatarSize,
      decoration: BoxDecoration(
        color: context.colors.accentBlue,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'JR',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Item de breadcrumb.
class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbItem({required this.label, this.onTap});
}

/// Botón con popup para cambiar entre temas (dark/light/auto).
class _ThemeSwitcher extends StatelessWidget {
  final WidgetRef ref;

  const _ThemeSwitcher({required this.ref});

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(themeModeProvider);

    return PopupMenuButton<AppThemeMode>(
      tooltip: 'Cambiar tema',
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colors.borderSubtle),
      ),
      color: context.colors.bgSurface,
      onSelected: (mode) {
        ref.read(themeModeProvider.notifier).state = mode;
      },
      itemBuilder: (context) => [
        _buildItem(
          context,
          AppThemeMode.dark,
          LucideIcons.moon,
          'Oscuro',
          current,
        ),
        _buildItem(
          context,
          AppThemeMode.light,
          LucideIcons.sun,
          'Claro',
          current,
        ),
        _buildItem(
          context,
          AppThemeMode.system,
          LucideIcons.monitor,
          'Auto',
          current,
        ),
      ],
      child: Container(
        width: AppDimensions.avatarSize,
        height: AppDimensions.avatarSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.borderSubtle),
        ),
        child: Icon(
          _iconForMode(current),
          size: 16,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }

  PopupMenuEntry<AppThemeMode> _buildItem(
    BuildContext context,
    AppThemeMode mode,
    IconData icon,
    String label,
    AppThemeMode current,
  ) {
    final isActive = mode == current;
    return PopupMenuItem<AppThemeMode>(
      value: mode,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive
                ? context.colors.accentBlue
                : context.colors.textSecondary,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? context.colors.accentBlue
                  : context.colors.textPrimary,
            ),
          ),
          const Spacer(),
          if (isActive)
            Icon(LucideIcons.check, size: 14, color: context.colors.accentBlue),
        ],
      ),
    );
  }

  IconData _iconForMode(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.dark => LucideIcons.moon,
      AppThemeMode.light => LucideIcons.sun,
      AppThemeMode.system => LucideIcons.monitor,
    };
  }
}
