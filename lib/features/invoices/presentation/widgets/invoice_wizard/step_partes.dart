import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/inputs/text_input.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import 'invoice_helpers.dart';

class StepPartes extends StatelessWidget {
  final String emisorName;
  final String emisorNif;
  final String emisorAddress;
  final TextEditingController receptorNameController;
  final TextEditingController receptorNifController;
  final TextEditingController receptorAddressController;
  final VoidCallback onNext;

  const StepPartes({
    super.key,
    required this.emisorName,
    required this.emisorNif,
    required this.emisorAddress,
    required this.receptorNameController,
    required this.receptorNifController,
    required this.receptorAddressController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      header: const GlassCardHeader(
        title: 'Datos de las partes',
        subtitle: 'Información del emisor y receptor de la factura',
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.s20,
          AppSpacing.s24,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emisor',
              style: AppTypography.h4.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            if (context.isCompact) ...[
              buildReadOnlyField(context, 'Razón social', emisorName),
              const SizedBox(height: AppSpacing.s16),
              buildReadOnlyField(context, 'NIF/CIF', emisorNif),
            ] else
              Row(
                children: [
                  Expanded(
                    child: buildReadOnlyField(
                      context,
                      'Razón social',
                      emisorName,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: buildReadOnlyField(context, 'NIF/CIF', emisorNif),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.s16),
            buildReadOnlyField(context, 'Dirección', emisorAddress),
            const SizedBox(height: AppSpacing.s28),

            Container(height: 1, color: context.colors.borderSubtle),
            const SizedBox(height: AppSpacing.s24),

            Text(
              'Receptor',
              style: AppTypography.h4.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            if (context.isCompact) ...[
              TeeDooTextField(
                label: 'Razón social',
                placeholder: 'Nombre de la empresa',
                controller: receptorNameController,
              ),
              const SizedBox(height: AppSpacing.s16),
              TeeDooTextField(
                label: 'NIF/CIF',
                placeholder: 'Ej: A98765432',
                controller: receptorNifController,
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: TeeDooTextField(
                      label: 'Razón social',
                      placeholder: 'Nombre de la empresa',
                      controller: receptorNameController,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: TeeDooTextField(
                      label: 'NIF/CIF',
                      placeholder: 'Ej: A98765432',
                      controller: receptorNifController,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.s16),
            TeeDooTextField(
              label: 'Dirección',
              placeholder: 'Dirección completa del receptor',
              controller: receptorAddressController,
            ),
          ],
        ),
      ),
      actions: GlassCardActions(
        children: [
          PrimaryButton(
            label: 'Siguiente: Líneas',
            icon: LucideIcons.arrowRight,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
