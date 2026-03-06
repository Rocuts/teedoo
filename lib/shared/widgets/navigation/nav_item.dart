import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_radius.dart';

/// Item de navegación del sidebar.
///
/// Ref Pencil: Component/NavItem/Default (Ozp2c) y Active (J4nna)
/// - Width: fill
/// - Radius: 10px
/// - Padding: 10/14
/// - Gap: 12
/// - Default: icon text-tertiary, label text-secondary
/// - Active: fill accent-blue-subtle, icon+label accent-blue, fontWeight 500
class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? context.colors.accentBlue : context.colors.textTertiary;
    final labelColor = isActive ? context.colors.accentBlue : context.colors.textSecondary;
    final bgColor = isActive ? context.colors.accentBlueSubtle : Colors.transparent;
    final fontWeight = isActive ? FontWeight.w500 : FontWeight.w400;

    return Semantics(
      button: true,
      label: label,
      selected: isActive,
      child: Material(
        color: bgColor,
        borderRadius: AppRadius.buttonAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.buttonAll,
          hoverColor: isActive ? null : context.colors.bgGlassHover,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Icon(icon, size: 20, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: fontWeight,
                        color: labelColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
