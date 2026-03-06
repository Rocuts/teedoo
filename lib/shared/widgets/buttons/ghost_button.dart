import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_radius.dart';

/// Botón ghost del Design System.
///
/// Ref Pencil: Component/Button/Ghost (GZcYc)
/// - Fill: transparent
/// - Radius: 10px
/// - Text: 14px/500, text-secondary
/// - Icon opcional (lucide, 16x16)
class GhostButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? foregroundColor;

  const GhostButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? context.colors.textSecondary;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.buttonAll,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.buttonAll,
          hoverColor: context.colors.bgGlassHover,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color,
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
