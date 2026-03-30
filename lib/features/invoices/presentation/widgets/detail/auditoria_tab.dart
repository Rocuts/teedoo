import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/glass_card.dart';

class AuditoriaTab extends StatelessWidget {
  const AuditoriaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      header: const GlassCardHeader(
        title: 'Registro de auditoría',
        subtitle: 'Historial completo de acciones sobre esta factura',
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
            _buildAuditEntry(
              context,
              dotColor: context.colors.accentBlue,
              action: 'Factura creada',
              user: 'Johan R.',
              time: '27 Feb 2026 · 15:42',
              showBorder: true,
            ),
            _buildAuditEntry(
              context,
              dotColor: context.colors.aiPurple,
              action: 'Compliance check ejecutado — Pass',
              user: 'Sistema IA',
              time: '27 Feb 2026 · 15:43',
              showBorder: true,
            ),
            _buildAuditEntry(
              context,
              dotColor: context.colors.statusSuccess,
              action: 'Factura enviada al SII',
              user: 'Johan R.',
              time: '27 Feb 2026 · 15:45',
              showBorder: true,
            ),
            _buildAuditEntry(
              context,
              dotColor: context.colors.statusSuccess,
              action: 'SII — Factura aceptada',
              user: 'AEAT',
              time: '27 Feb 2026 · 15:46',
              showBorder: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditEntry(
    BuildContext context, {
    required Color dotColor,
    required String action,
    required String user,
    required String time,
    required bool showBorder,
  }) {
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
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: AppTypography.bodySmallMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$user · $time',
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
