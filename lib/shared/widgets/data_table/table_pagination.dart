import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Paginación para tablas del Design System.
///
/// - "Mostrando X-Y de Z" text left (12px text-tertiary)
/// - Page buttons right: Previous/Next with arrow icons
/// - Ghost button style for pagination buttons
class TablePagination extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int>? onPageChanged;

  const TablePagination({
    super.key,
    required this.currentPage,
    required this.totalItems,
    this.pageSize = 10,
    this.onPageChanged,
  });

  int get _totalPages => (totalItems / pageSize).ceil();
  int get _startItem => totalItems == 0 ? 0 : (currentPage - 1) * pageSize + 1;
  int get _endItem => (currentPage * pageSize).clamp(0, totalItems);
  bool get _hasPrevious => currentPage > 1;
  bool get _hasNext => currentPage < _totalPages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Info text (left) ──
          Text(
            'Mostrando $_startItem-$_endItem de $totalItems',
            style: TextStyle(
              fontSize: 12,
              color: context.colors.textTertiary,
            ),
          ),

          // ── Page buttons (right) ──
          Row(
            children: [
              _PaginationButton(
                icon: LucideIcons.chevronLeft,
                label: 'Anterior',
                onTap: _hasPrevious
                    ? () => onPageChanged?.call(currentPage - 1)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              _PaginationButton(
                icon: LucideIcons.chevronRight,
                label: 'Siguiente',
                iconRight: true,
                onTap: _hasNext
                    ? () => onPageChanged?.call(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool iconRight;
  final VoidCallback? onTap;

  const _PaginationButton({
    required this.icon,
    required this.label,
    this.iconRight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final color = isDisabled
        ? context.colors.textTertiary.withValues(alpha: 0.5)
        : context.colors.textSecondary;

    final iconWidget = Icon(icon, size: 14, color: color);
    final textWidget = Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.buttonAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.buttonAll,
        hoverColor: isDisabled ? null : context.colors.bgGlassHover,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: iconRight
                ? [textWidget, const SizedBox(width: 4), iconWidget]
                : [iconWidget, const SizedBox(width: 4), textWidget],
          ),
        ),
      ),
    );
  }
}
