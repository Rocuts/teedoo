import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
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
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          children: [
            _ExportOption(
              icon: LucideIcons.fileSpreadsheet,
              title: 'CSV / Excel',
              subtitle: 'Datos tabulares',
              onExport: () {},
            ),
            const SizedBox(height: 10),
            _ExportOption(
              icon: LucideIcons.braces,
              title: 'JSON',
              subtitle: 'Para integraci\u00f3n',
              onExport: () {},
            ),
            const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.colors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          GhostButton(
            label: 'Exportar',
            onPressed: onExport,
          ),
        ],
      ),
    );
  }
}
