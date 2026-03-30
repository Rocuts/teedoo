import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/models/tax_optimization.dart';

/// Card de explicación IA para una optimización.
class AiExplanationCard extends StatelessWidget {
  final TaxOptimization optimization;
  final VoidCallback? onGenerate;
  final bool isGenerating;

  const AiExplanationCard({
    super.key,
    required this.optimization,
    this.onGenerate,
    this.isGenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final explanation = optimization.aiExplanation;

    if (explanation == null) {
      return GlassCard(
        header: const GlassCardHeader(title: 'Explicación'),
        content: GlassCardContent(
          child: Center(
            child: Column(
              children: [
                Icon(LucideIcons.sparkles, size: 32, color: colors.aiPurple),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Genera una explicación detallada con IA',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: isGenerating ? 'Generando...' : 'Generar explicación',
                  icon: LucideIcons.sparkles,
                  onPressed: isGenerating ? null : onGenerate,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GlassCard(
      header: const GlassCardHeader(title: 'Explicación'),
      content: GlassCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusBadge(label: 'Generada por IA', type: StatusType.info),
            const SizedBox(height: AppSpacing.lg),
            Text(
              explanation,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Esta explicación ha sido generada por inteligencia artificial '
              'y tiene carácter orientativo. Consulte con su asesor fiscal '
              'antes de tomar decisiones.',
              style: AppTypography.captionSmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
