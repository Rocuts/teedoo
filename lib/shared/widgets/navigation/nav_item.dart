import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Item de navegación del sidebar.
///
/// Ref Pencil: Component/NavItem/Default (Ozp2c) y Active (J4nna)
/// - Width: fill
/// - Radius: 10px
/// - Padding: 10/14
/// - Gap: 12
/// - Default: icon text-tertiary, label text-secondary
/// - Active: fill accent-blue-subtle, icon+label accent-blue, fontWeight 500
///
/// Uses tactile feedback (scale + opacity) instead of Material ripple.
class NavItem extends StatefulWidget {
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
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool _isPressed = false;
  bool _isHovered = false;

  bool get _enabled => widget.onTap != null;

  void _handleTapDown(TapDownDetails _) {
    if (!_enabled) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_enabled) return;
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!_enabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final iconColor = widget.isActive ? colors.accentBlue : colors.textTertiary;
    final labelColor = widget.isActive
        ? colors.accentBlue
        : colors.textSecondary;
    final fontWeight = widget.isActive ? FontWeight.w500 : FontWeight.w400;

    Color bgColor;
    if (widget.isActive) {
      bgColor = colors.accentBlueSubtle;
    } else if (_isPressed) {
      bgColor = colors.bgGlassHover.withValues(alpha: 0.8);
    } else if (_isHovered) {
      bgColor = colors.bgGlassHover;
    } else {
      bgColor = Colors.transparent;
    }

    return Semantics(
      button: true,
      label: widget.label,
      selected: widget.isActive,
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
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                child: ExcludeSemantics(
                  child: Row(
                    children: [
                      Icon(
                        widget.icon,
                        size: AppDimensions.iconSize,
                        color: iconColor,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: AppTypography.body.copyWith(
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
        ),
      ),
    );
  }
}
