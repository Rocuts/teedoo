import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Datos de un tab individual.
class InvoiceTabItem {
  final String label;
  final Widget? icon;

  const InvoiceTabItem({required this.label, this.icon});
}

/// Tab bar reutilizable para facturas.
///
/// Usado tanto en [InvoicesListScreen] como en [InvoiceDetailScreen].
/// - Active tab: bottom border 2px accent-blue, text accent-blue 13px 500
/// - Inactive: text-secondary 13px
class InvoiceTabs extends StatelessWidget {
  final List<InvoiceTabItem> tabs;
  final int activeIndex;
  final ValueChanged<int>? onTabChanged;

  const InvoiceTabs({
    super.key,
    required this.tabs,
    required this.activeIndex,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.borderSubtle)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            _buildTab(context, tabs[i], isActive: i == activeIndex, index: i),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    InvoiceTabItem tab, {
    required bool isActive,
    required int index,
  }) {
    return GestureDetector(
      onTap: onTabChanged != null ? () => onTabChanged!(index) : null,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: isActive
                  ? Border(
                      bottom: BorderSide(
                        color: context.colors.accentBlue,
                        width: 2,
                      ),
                    )
                  : null,
            ),
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tab.icon != null) ...[
                  tab.icon!,
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  tab.label,
                  style:
                      (isActive
                              ? AppTypography.bodySmallMedium
                              : AppTypography.bodySmall)
                          .copyWith(
                            color: isActive
                                ? context.colors.accentBlue
                                : context.colors.textSecondary,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
