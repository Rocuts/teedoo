import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Botón secundario del Design System.
///
/// Ref Pencil: Component/Button/Secondary (aynEt)
/// - Fill: bg-glass
/// - Stroke: 1px border-subtle
/// - Radius: 10px
/// - Text: 14px/500, text-primary
/// - Icon opcional (lucide, 16x16)
///
/// Uses tactile feedback (scale + opacity) instead of Material ripple.
class SecondaryButton extends StatefulWidget {
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
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
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

    final Widget child = Row(
      mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: AppDimensions.iconSizeSmall,
            color: colors.textPrimary,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          widget.label,
          style: AppTypography.buttonMedium.copyWith(color: colors.textPrimary),
        ),
      ],
    );

    Color bgColor;
    if (_isPressed) {
      bgColor = colors.bgGlass.withValues(alpha: 0.9);
    } else if (_isHovered) {
      bgColor = colors.bgGlassHover;
    } else {
      bgColor = colors.bgGlass;
    }

    Color borderColor;
    if (_isPressed) {
      borderColor = colors.accentBlue.withValues(alpha: 0.4);
    } else if (_isHovered) {
      borderColor = colors.borderSubtle.withValues(alpha: 0.8);
    } else {
      borderColor = colors.borderSubtle;
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
              child: SizedBox(
                width: widget.isExpanded ? double.infinity : null,
                height: AppDimensions.buttonHeight,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: AppRadius.buttonAll,
                    border: Border.all(color: borderColor),
                  ),
                  child: ExcludeSemantics(child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
