import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/models/fiscal_profile.dart';

/// Formulario editable del perfil fiscal.
class FiscalProfileForm extends StatelessWidget {
  final FiscalProfile profile;
  final ValueChanged<FiscalProfile> onChange;

  const FiscalProfileForm({
    super.key,
    required this.profile,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      header: const GlassCardHeader(
        title: 'Perfil Fiscal',
        subtitle: 'Configura tus datos fiscales para el análisis',
      ),
      content: GlassCardContent(child: _buildForm(context)),
    );
  }

  Widget _buildForm(BuildContext context) {
    final isCompact = context.isCompact;

    final dropdowns = [
      _buildDropdown<LegalForm>(
        context,
        label: 'Forma jurídica',
        value: profile.legalForm,
        items: const {
          LegalForm.autonomo: 'Autónomo',
          LegalForm.sociedadLimitada: 'S.L.',
          LegalForm.sociedadAnonima: 'S.A.',
          LegalForm.cooperativa: 'Cooperativa',
        },
        onChanged: (v) => onChange(profile.copyWith(legalForm: v)),
      ),
      _buildDropdown<FiscalRegime>(
        context,
        label: 'Régimen fiscal',
        value: profile.fiscalRegime,
        items: const {
          FiscalRegime.estimacionDirectaSimplificada: 'Directa simplificada',
          FiscalRegime.estimacionDirectaNormal: 'Directa normal',
          FiscalRegime.estimacionObjetiva: 'Objetiva',
          FiscalRegime.regimenGeneral: 'General',
        },
        onChanged: (v) => onChange(profile.copyWith(fiscalRegime: v)),
      ),
      _buildDropdown<IvaRegime>(
        context,
        label: 'Régimen IVA',
        value: profile.ivaRegime,
        items: const {
          IvaRegime.general: 'General',
          IvaRegime.simplificado: 'Simplificado',
          IvaRegime.recargo: 'Recargo equivalencia',
        },
        onChanged: (v) => onChange(profile.copyWith(ivaRegime: v)),
      ),
      _buildDropdown<String>(
        context,
        label: 'CCAA',
        value: profile.autonomousCommunity,
        items: const {
          'Madrid': 'Madrid',
          'Cataluña': 'Cataluña',
          'Andalucía': 'Andalucía',
          'Valencia': 'Valencia',
          'Otra': 'Otra',
        },
        onChanged: (v) => onChange(profile.copyWith(autonomousCommunity: v)),
      ),
    ];

    final textFields = [
      _buildTextField(
        context,
        label: 'CNAE',
        value: profile.iaeCode,
        onChanged: (v) => onChange(profile.copyWith(iaeCode: v)),
      ),
      _buildCurrencyField(
        context,
        label: 'Facturación anual',
        value: profile.annualRevenue,
        onChanged: (v) => onChange(profile.copyWith(annualRevenue: v)),
      ),
    ];

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...dropdowns.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: w,
            ),
          ),
          ...textFields.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: w,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < dropdowns.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.lg),
              Expanded(child: dropdowns[i]),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            for (int i = 0; i < textFields.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.lg),
              Expanded(child: textFields[i]),
            ],
            // Fill remaining space
            const Spacer(),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(
    BuildContext context, {
    required String label,
    required T value,
    required Map<T, String> items,
    required ValueChanged<T> onChanged,
  }) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.captionSmallBold.copyWith(
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: colors.bgInput,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: colors.borderSubtle),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: colors.bgSurface,
            style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: colors.textTertiary,
            ),
            items: items.entries
                .map(
                  (e) =>
                      DropdownMenuItem<T>(value: e.key, child: Text(e.value)),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.captionSmallBold.copyWith(
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: value,
          style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: colors.bgInput,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
              borderSide: BorderSide(color: colors.accentBlue),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCurrencyField(
    BuildContext context, {
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.captionSmallBold.copyWith(
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: value.toStringAsFixed(0),
          style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: colors.bgInput,
            suffixText: '€',
            suffixStyle: AppTypography.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
              borderSide: BorderSide(color: colors.accentBlue),
            ),
          ),
          onChanged: (v) {
            final parsed = double.tryParse(v);
            if (parsed != null) onChanged(parsed);
          },
        ),
      ],
    );
  }
}
