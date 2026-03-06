import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_radius.dart';

/// Botón primario del Design System.
///
/// Ref Pencil: Component/Button/Primary (7EDG5)
/// - Fill: accent-blue
/// - Radius: 10px
/// - Padding: 10/20
/// - Text: 14px/500, text-on-accent
/// - Icon opcional (lucide, 16x16)
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colors.textOnAccent,
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 16, color: context.colors.textOnAccent),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textOnAccent,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: label,
      child: SizedBox(
        width: isExpanded ? double.infinity : null,
        height: 44,
        child: Material(
          color: onPressed != null ? context.colors.accentBlue : context.colors.accentBlue.withValues(alpha: 0.5),
          borderRadius: AppRadius.buttonAll,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: AppRadius.buttonAll,
            hoverColor: context.colors.accentBlueHover,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ExcludeSemantics(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
