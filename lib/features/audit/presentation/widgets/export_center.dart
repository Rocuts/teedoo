import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/ghost_button.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Centro de exportación con opciones CSV, JSON y PDF.
///
/// Ref Pencil: Audit screen — Right column, "Centro de exportación" card.
class ExportCenter extends StatelessWidget {
  const ExportCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      header: const GlassCardHeader(title: 'Centro de exportaci\u00f3n'),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.lg,
          AppSpacing.s24,
          AppSpacing.s20,
        ),
        child: Column(
          children: [
            _ExportOption(
              icon: LucideIcons.fileSpreadsheet,
              title: 'CSV / Excel',
              subtitle: 'Datos tabulares',
              onExport: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            _ExportOption(
              icon: LucideIcons.braces,
              title: 'JSON',
              subtitle: 'Para integraci\u00f3n',
              onExport: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            _ExportOption(
              icon: LucideIcons.fileText,
              title: 'PDF',
              subtitle: 'Reporte formal',
              onExport: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onExport;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.colors.textSecondary),
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
                  subtitle,
                  style: AppTypography.captionSmall.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          GhostButton(label: 'Exportar', onPressed: onExport),
        ],
      ),
    );
  }
}
