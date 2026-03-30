import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/inputs/text_input.dart';

/// Card de numeraci\u00f3n de facturas.
///
/// Ref Pencil: Settings - Organization / Card 4
/// Configura el prefijo y la secuencia de numeraci\u00f3n.
class NumberingCard extends StatelessWidget {
  final String invoicePrefix;
  final String nextNumber;
  final ValueChanged<String>? onPrefixChanged;
  final ValueChanged<String>? onNumberChanged;

  const NumberingCard({
    super.key,
    required this.invoicePrefix,
    required this.nextNumber,
    this.onPrefixChanged,
    this.onNumberChanged,
  });

  String get _preview => '$invoicePrefix$nextNumber';

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Numeraci\u00f3n de facturas',
            style: AppTypography.h4.copyWith(color: context.colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),

          // Description
          Text(
            'Configura el formato y la secuencia de numeraci\u00f3n '
            'para tus facturas electr\u00f3nicas.',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Form row: Prefix + Next number
          Row(
            children: [
              Expanded(
                child: TeeDooTextField(
                  label: 'Prefijo',
                  controller: TextEditingController(text: invoicePrefix),
                  onChanged: onPrefixChanged,
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: TeeDooTextField(
                  label: 'Siguiente n\u00famero',
                  controller: TextEditingController(text: nextNumber),
                  onChanged: onNumberChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),

          // Preview row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: context.colors.bgInput,
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                Text(
                  'Vista previa:',
                  style: AppTypography.captionMedium.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  _preview,
                  style: AppTypography.button.copyWith(
                    color: context.colors.accentBlue,
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
