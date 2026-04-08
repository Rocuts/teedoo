import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/badges/status_badge.dart';
import '../../../../../shared/widgets/badges/ai_badge.dart';

class ComplianceTab extends StatelessWidget {
  const ComplianceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.aiPurpleBg,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: context.colors.aiPurpleBorder),
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.sparkles,
                  size: 20,
                  color: context.colors.aiPurple,
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compliance Check - IA',
                      style: AppTypography.h4.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Análisis automático de conformidad normativa',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const AIBadge(label: 'IA Compliance'),
              const SizedBox(width: AppSpacing.lg),
              const StatusBadge(label: 'Pass', type: StatusType.success),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        GlassCard(
          header: const GlassCardHeader(
            title: 'Resultados del análisis',
            subtitle: 'Verificaciones realizadas por el motor de compliance',
          ),
          content: GlassCardContent(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24,
              AppSpacing.xl,
              AppSpacing.s24,
              AppSpacing.s20,
            ),
            child: Column(
              children: [
                _buildComplianceCheck(
                  context,
                  icon: LucideIcons.checkCircle,
                  color: context.colors.statusSuccess,
                  title: 'Estructura FacturaE válida',
                  description: 'Todos los campos obligatorios están presentes',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildComplianceCheck(
                  context,
                  icon: LucideIcons.checkCircle,
                  color: context.colors.statusSuccess,
                  title: 'NIF del emisor verificado',
                  description: 'B****678 — Registro mercantil validado',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildComplianceCheck(
                  context,
                  icon: LucideIcons.checkCircle,
                  color: context.colors.statusSuccess,
                  title: 'NIF del receptor verificado',
                  description: 'A****432 — Registro mercantil validado',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildComplianceCheck(
                  context,
                  icon: LucideIcons.checkCircle,
                  color: context.colors.statusSuccess,
                  title: 'Cálculos de IVA correctos',
                  description:
                      'Base imponible, tipo impositivo y cuotas verificadas',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildComplianceCheck(
                  context,
                  icon: LucideIcons.checkCircle,
                  color: context.colors.statusSuccess,
                  title: 'Compatible con SII',
                  description:
                      'La factura cumple los requisitos del SII de la AEAT',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComplianceCheck(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmallMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textSecondary,
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
