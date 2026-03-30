import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/fiscal_rule.dart';

/// Matriz de distribución de riesgo.
class RiskMatrix extends StatelessWidget {
  final Map<RiskLevel, int> distribution;

  const RiskMatrix({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxCount = distribution.values.fold(0, (m, v) => v > m ? v : m);

    final levels = [
      (RiskLevel.low, 'Bajo', colors.statusSuccess),
      (RiskLevel.medium, 'Medio', colors.statusWarning),
      (RiskLevel.high, 'Alto', colors.statusError),
      (RiskLevel.critical, 'Crítico', colors.statusError),
    ];

    return Column(
      children: [
        for (final (level, label, color) in levels) ...[
          _buildBar(context, label, distribution[level] ?? 0, maxCount, color),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _buildBar(
    BuildContext context,
    String label,
    int count,
    int maxCount,
    Color color,
  ) {
    final colors = context.colors;
    final fraction = maxCount > 0 ? count / maxCount : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.smAll,
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: AppRadius.smAll,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  height: 20,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: fraction,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.6),
                        borderRadius: AppRadius.smAll,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: AppTypography.captionSmallBold.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
