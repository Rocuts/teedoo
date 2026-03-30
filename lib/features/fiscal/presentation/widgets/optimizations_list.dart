import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/models/fiscal_rule.dart';
import '../../data/models/tax_optimization.dart';

/// Lista de optimizaciones fiscales detectadas.
class OptimizationsList extends StatelessWidget {
  final List<TaxOptimization> optimizations;
  final TaxType? filterTax;
  final ValueChanged<String> onTap;

  const OptimizationsList({
    super.key,
    required this.optimizations,
    this.filterTax,
    required this.onTap,
  });

  List<TaxOptimization> get _filtered {
    var list = List.of(optimizations);
    if (filterTax != null) {
      list = list.where((o) => o.taxType == filterTax).toList();
    }
    list.sort((a, b) => b.estimatedSaving.compareTo(a.estimatedSaving));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return GlassCard(
      header: GlassCardHeader(
        title: 'Oportunidades Detectadas',
        subtitle: filterTax != null
            ? 'Filtradas por ${_taxLabel(filterTax!)}'
            : null,
        trailing: Text(
          '${filtered.length}',
          style: AppTypography.h4.copyWith(color: context.colors.accentBlue),
        ),
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.xl,
          AppSpacing.s24,
          AppSpacing.s20,
        ),
        child: filtered.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: Center(
                  child: Text(
                    'No hay optimizaciones para este filtro',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  for (int i = 0; i < filtered.length; i++)
                    _OptimizationRow(
                      optimization: filtered[i],
                      onTap: () => onTap(filtered[i].id),
                      delay: Duration(milliseconds: i * 50),
                    ),
                ],
              ),
      ),
    );
  }

  static String _taxLabel(TaxType type) {
    return switch (type) {
      TaxType.irpf => 'IRPF',
      TaxType.iva => 'IVA',
      TaxType.sociedades => 'Impuesto de Sociedades',
      _ => type.name.toUpperCase(),
    };
  }
}

class _OptimizationRow extends StatelessWidget {
  final TaxOptimization optimization;
  final VoidCallback onTap;
  final Duration delay;

  const _OptimizationRow({
    required this.optimization,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final confidenceBadge = switch (optimization.confidenceLevel) {
      ConfidenceLevel.high => const StatusBadge(
        label: 'Confirmada',
        type: StatusType.success,
      ),
      ConfidenceLevel.medium => const StatusBadge(
        label: 'Probable',
        type: StatusType.info,
      ),
      ConfidenceLevel.low => const StatusBadge(
        label: 'Posible',
        type: StatusType.warning,
      ),
    };

    final riskBadge = switch (optimization.riskLevel) {
      RiskLevel.low => const StatusBadge(
        label: 'Bajo',
        type: StatusType.success,
      ),
      RiskLevel.medium => const StatusBadge(
        label: 'Medio',
        type: StatusType.warning,
      ),
      RiskLevel.high => const StatusBadge(
        label: 'Alto',
        type: StatusType.error,
      ),
      RiskLevel.critical => const StatusBadge(
        label: 'Crítico',
        type: StatusType.error,
      ),
    };

    return InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.borderSubtle)),
            ),
            child: Row(
              children: [
                // Tax icon
                _buildTaxIcon(context, optimization.taxType),
                const SizedBox(width: AppSpacing.lg),

                // Title + badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        optimization.title,
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          confidenceBadge,
                          riskBadge,
                          if (optimization.riskLevel != RiskLevel.low ||
                              optimization.confidenceLevel !=
                                  ConfidenceLevel.high)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.alertCircle,
                                  size: 12,
                                  color: colors.statusWarning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Revisar',
                                  style: AppTypography.captionSmall.copyWith(
                                    color: colors.statusWarning,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Savings amount
                const SizedBox(width: AppSpacing.lg),
                Text(
                  _formatCurrency(optimization.estimatedSaving),
                  style: AppTypography.h4.copyWith(
                    color: colors.statusSuccess,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: colors.textTertiary,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fade(delay: delay, duration: AppMotion.durationNormal)
        .slideX(begin: 0.02, delay: delay, duration: AppMotion.durationNormal);
  }

  Widget _buildTaxIcon(BuildContext context, TaxType type) {
    final (icon, color) = switch (type) {
      TaxType.irpf => (LucideIcons.receipt, context.colors.statusSuccess),
      TaxType.iva => (LucideIcons.percent, context.colors.accentBlue),
      TaxType.sociedades => (
        LucideIcons.building,
        context.colors.statusWarning,
      ),
      _ => (LucideIcons.fileText, context.colors.textTertiary),
    };

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.mdAll,
      ),
      child: Icon(icon, size: 18, color: color),
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
