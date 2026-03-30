import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';

/// KPI card widget extraído del Dashboard.
///
/// Muestra un valor principal, subtítulo y tendencia
/// con icono y color indicativos.
class KpiCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trend;
  final Color trendColor;
  final IconData trendIcon;

  const KpiCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trend,
    required this.trendColor,
    required this.trendIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.h1.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(trendIcon, size: 14, color: trendColor),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  trend,
                  style: AppTypography.caption.copyWith(color: trendColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
