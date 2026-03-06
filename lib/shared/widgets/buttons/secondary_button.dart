import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_radius.dart';

/// Botón secundario del Design System.
///
/// Ref Pencil: Component/Button/Secondary (aynEt)
/// - Fill: bg-glass
/// - Stroke: 1px border-subtle
/// - Radius: 10px
/// - Text: 14px/500, text-primary
/// - Icon opcional (lucide, 16x16)
class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isExpanded;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: context.colors.textPrimary),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: SizedBox(
        width: isExpanded ? double.infinity : null,
        height: 44,
        child: Material(
          color: context.colors.bgGlass,
          borderRadius: AppRadius.buttonAll,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.buttonAll,
            hoverColor: context.colors.bgGlassHover,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: AppRadius.buttonAll,
                border: Border.all(color: context.colors.borderSubtle),
              ),
              child: ExcludeSemantics(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
