import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Botón ghost del Design System.
///
/// Ref Pencil: Component/Button/Ghost (GZcYc)
/// - Fill: transparent
/// - Radius: 10px
/// - Text: 14px/500, text-secondary
/// - Icon opcional (lucide, 16x16)
///
/// Uses tactile feedback (scale + opacity) instead of Material ripple.
class GhostButton extends StatefulWidget {
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
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  bool get _enabled => widget.onPressed != null;

  void _handleTapDown(TapDownDetails _) {
    if (!_enabled) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_enabled) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (!_enabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = widget.foregroundColor ?? colors.textSecondary;

    Color bgColor;
    if (_isPressed) {
      bgColor = colors.bgGlassHover.withValues(alpha: 0.8);
    } else if (_isHovered) {
      bgColor = colors.bgGlassHover;
    } else {
      bgColor = Colors.transparent;
    }

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: Duration(milliseconds: _isPressed ? 100 : 150),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: _isPressed ? 0.9 : 1.0,
              duration: Duration(milliseconds: _isPressed ? 100 : 150),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: AppRadius.buttonAll,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: AppDimensions.iconSizeSmall,
                          color: color,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        widget.label,
                        style: AppTypography.buttonMedium.copyWith(
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
