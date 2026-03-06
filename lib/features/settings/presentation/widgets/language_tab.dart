import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Tab de idioma y regi\u00f3n.
///
/// Permite seleccionar el idioma de la interfaz, zona horaria,
/// formato de fecha y formato num\u00e9rico.
class LanguageTab extends StatelessWidget {
  const LanguageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Idioma y regi\u00f3n',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Configura el idioma y las preferencias regionales de tu cuenta',
          style: TextStyle(
            fontSize: 13,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        // Language selector card
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Idioma de la interfaz',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Row(
                children: [
                  _buildLanguageOption(context,
                    label: 'Espa\u00f1ol',
                    code: 'ES',
                    isActive: true,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _buildLanguageOption(context,
                    label: 'English',
                    code: 'EN',
                    isActive: false,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        // Region settings card
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuraci\u00f3n regional',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildRegionRow(context,
                icon: LucideIcons.clock,
                label: 'Zona horaria',
                value: 'Europe/Madrid (UTC+1)',
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildRegionRow(context,
                icon: LucideIcons.calendar,
                label: 'Formato de fecha',
                value: 'DD/MM/AAAA',
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildRegionRow(context,
                icon: LucideIcons.hash,
                label: 'Formato num\u00e9rico',
                value: '1.234,56',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        // Preview card
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vista previa de formatos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildPreviewRow(context,'Fecha:', '25/02/2026'),
              const SizedBox(height: AppSpacing.md),
              _buildPreviewRow(context,'Hora:', '14:30'),
              const SizedBox(height: AppSpacing.md),
              _buildPreviewRow(context,'Moneda:', '\u20ac12.345,67'),
              const SizedBox(height: AppSpacing.md),
              _buildPreviewRow(context,'N\u00famero:', '1.234.567,89'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(BuildContext context, {
    required String label,
    required String code,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? context.colors.accentBlueSubtle
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: isActive
              ? context.colors.accentBlue
              : context.colors.borderSubtle,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            code,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? context.colors.accentBlue
                  : context.colors.textTertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? context.colors.accentBlue
                  : context.colors.textSecondary,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: AppSpacing.md),
            Icon(
              LucideIcons.check,
              size: 14,
              color: context.colors.accentBlue,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegionRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colors.textTertiary),
        const SizedBox(width: AppSpacing.xl),
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.colors.bgInput,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              border: Border.all(color: context.colors.borderSubtle),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.textTertiary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
