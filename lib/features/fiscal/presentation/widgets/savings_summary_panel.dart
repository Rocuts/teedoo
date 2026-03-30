import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/models/optimization_report.dart';
import '../../data/models/tax_optimization.dart';
import '../../data/models/fiscal_rule.dart';

/// Panel de KPIs de ahorro fiscal.
class SavingsSummaryPanel extends StatelessWidget {
  final ReportSummary summary;
  final List<TaxOptimization> optimizations;

  const SavingsSummaryPanel({
    super.key,
    required this.summary,
    required this.optimizations,
  });

  int get _confirmedCount => optimizations
      .where((o) => o.confidenceLevel == ConfidenceLevel.high)
      .length;

  int get _reviewCount => optimizations
      .where(
        (o) =>
            o.confidenceLevel != ConfidenceLevel.high ||
            o.riskLevel != RiskLevel.low,
      )
      .length;

  @override
  Widget build(BuildContext context) {
    final kpiCards = [
      _KpiDef(
        label: 'Ahorro total estimado',
        value: _formatCurrency(summary.totalEstimatedSaving),
        icon: LucideIcons.piggyBank,
        color: context.colors.statusSuccess,
        bgColor: context.colors.statusSuccessBg,
        delay: 0.ms,
      ),
      _KpiDef(
        label: 'Optimizaciones encontradas',
        value: '${optimizations.length}',
        icon: LucideIcons.lightbulb,
        color: context.colors.accentBlue,
        bgColor: context.colors.accentBlueSubtle,
        delay: 100.ms,
      ),
      _KpiDef(
        label: 'Confirmadas',
        value: '$_confirmedCount',
        icon: LucideIcons.checkCircle,
        color: context.colors.statusSuccess,
        bgColor: context.colors.statusSuccessBg,
        delay: 200.ms,
      ),
      _KpiDef(
        label: 'Requieren revisión',
        value: '$_reviewCount',
        icon: LucideIcons.alertTriangle,
        color: context.colors.statusWarning,
        bgColor: context.colors.statusWarningBg,
        delay: 300.ms,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (context.isCompact) {
          return Column(
            children: [
              for (int i = 0; i < kpiCards.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: _buildCard(context, kpiCards[i]),
                ),
              ],
            ],
          );
        }

        if (context.isMedium) {
          return Wrap(
            spacing: AppSpacing.s16,
            runSpacing: AppSpacing.s16,
            children: kpiCards
                .map(
                  (kpi) => SizedBox(
                    width: (constraints.maxWidth - AppSpacing.s16) / 2,
                    child: _buildCard(context, kpi),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: [
            for (int i = 0; i < kpiCards.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.s16),
              Expanded(child: _buildCard(context, kpiCards[i])),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, _KpiDef kpi) {
    return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      kpi.label,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: AppSpacing.s36,
                    height: AppSpacing.s36,
                    decoration: BoxDecoration(
                      color: kpi.bgColor,
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Icon(kpi.icon, size: 18, color: kpi.color),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  kpi.value,
                  style: AppTypography.h1.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fade(delay: kpi.delay)
        .slideY(
          begin: AppMotion.slideEntryOffset,
          duration: AppMotion.durationSlow,
        );
  }

  static String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
      buffer.write(intPart[i]);
    }
    return '$buffer,$decPart \u20ac';
  }
}

class _KpiDef {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Duration delay;

  const _KpiDef({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.delay,
  });
}
