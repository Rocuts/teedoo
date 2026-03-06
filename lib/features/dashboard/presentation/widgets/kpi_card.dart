import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
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
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(trendIcon, size: 14, color: trendColor),
                const SizedBox(width: 6),
                Text(
                  trend,
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
