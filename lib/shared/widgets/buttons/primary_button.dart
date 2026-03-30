import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Botón primario del Design System.
///
/// Ref Pencil: Component/Button/Primary (7EDG5)
/// - Fill: accent-blue
/// - Radius: 10px
/// - Padding: 10/20
/// - Text: 14px/500, text-on-accent
/// - Icon opcional (lucide, 16x16)
///
/// Uses tactile feedback (scale + opacity) instead of Material ripple.
class PrimaryButton extends StatefulWidget {
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
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

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
        if (widget.isLoading) ...[
          SizedBox(
            width: AppDimensions.iconSizeSmall,
            height: AppDimensions.iconSizeSmall,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.textOnAccent,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: AppDimensions.iconSizeSmall,
            color: colors.textOnAccent,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          widget.label,
          style: AppTypography.buttonMedium.copyWith(
            color: colors.textOnAccent,
          ),
        ),
      ],
    );

    Color bgColor;
    if (!_enabled) {
      bgColor = colors.accentBlue.withValues(alpha: 0.5);
    } else if (_isPressed) {
      bgColor = colors.accentBlue.withValues(alpha: 0.9);
    } else if (_isHovered) {
      bgColor = colors.accentBlueHover;
    } else {
      bgColor = colors.accentBlue;
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
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: AppRadius.buttonAll,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.lg,
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
