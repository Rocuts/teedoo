import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Datos de un item de actividad reciente.
class ActivityItemData {
  final Color dotColor;
  final String title;
  final String time;

  const ActivityItemData({
    required this.dotColor,
    required this.title,
    required this.time,
  });
}

/// Widget de item individual de actividad reciente.
///
/// Extraído del Dashboard para reutilización.
class ActivityItem extends StatelessWidget {
  final ActivityItemData data;
  final bool showBorder;

  const ActivityItem({super.key, required this.data, this.showBorder = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: context.colors.borderSubtle))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: data.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTypography.bodySmallMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.time,
                  style: AppTypography.captionSmall.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista de actividad reciente.
///
/// Muestra múltiples [ActivityItem] en un Column.
class RecentActivityList extends StatelessWidget {
  final List<ActivityItemData> items;

  const RecentActivityList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          ActivityItem(data: items[i], showBorder: i < items.length - 1),
      ],
    );
  }
}
