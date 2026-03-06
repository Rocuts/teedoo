import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/inputs/text_input.dart';
import '../../../../../shared/widgets/inputs/select_input.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../shared/widgets/buttons/secondary_button.dart';
import 'invoice_helpers.dart';

class StepTotales extends StatelessWidget {
  final double subtotal;
  final double taxAmount;
  final double total;
  final String? paymentMethod;
  final ValueChanged<String?> onPaymentMethodChanged;
  final TextEditingController dueDateController;
  final TextEditingController notesController;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const StepTotales({
    super.key,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
    required this.dueDateController,
    required this.notesController,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      header: const GlassCardHeader(
        title: 'Resumen de totales',
        subtitle: 'Verifica los importes y añade condiciones de pago',
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.bgInput,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: context.colors.borderSubtle),
              ),
              child: Column(
                children: [
                  buildTotalRow(context, 'Subtotal', formatCurrency(subtotal)),
                  const SizedBox(height: 12),
                  buildTotalRow(context, 'IVA (21%)', formatCurrency(taxAmount)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      color: context.colors.borderSubtle,
                      height: 1,
                    ),
                  ),
                  buildTotalRow(
                    context,
                    'Total',
                    formatCurrency(total),
                    isBold: true,
                    valueColor: context.colors.accentBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s28),

            Text(
              'Condiciones de pago',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            if (context.isCompact) ...[
              TeeDooSelect(
                label: 'Método de pago',
                placeholder: 'Seleccionar método',
                value: paymentMethod,
                options: const [
                  SelectOption(value: 'transfer', label: 'Transferencia bancaria'),
                  SelectOption(value: 'card', label: 'Tarjeta de crédito'),
                  SelectOption(value: 'direct_debit', label: 'Domiciliación'),
                  SelectOption(value: 'cash', label: 'Efectivo'),
                ],
                onChanged: onPaymentMethodChanged,
              ),
              const SizedBox(height: AppSpacing.s16),
              TeeDooTextField(
                label: 'Fecha de vencimiento',
                placeholder: 'DD/MM/AAAA',
                controller: dueDateController,
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: TeeDooSelect(
                      label: 'Método de pago',
                      placeholder: 'Seleccionar método',
                      value: paymentMethod,
                      options: const [
                        SelectOption(value: 'transfer', label: 'Transferencia bancaria'),
                        SelectOption(value: 'card', label: 'Tarjeta de crédito'),
                        SelectOption(value: 'direct_debit', label: 'Domiciliación'),
                        SelectOption(value: 'cash', label: 'Efectivo'),
                      ],
                      onChanged: onPaymentMethodChanged,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: TeeDooTextField(
                      label: 'Fecha de vencimiento',
                      placeholder: 'DD/MM/AAAA',
                      controller: dueDateController,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.s16),
            TeeDooTextField(
              label: 'Notas',
              placeholder: 'Notas o comentarios adicionales (opcional)',
              controller: notesController,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: GlassCardActions(
        children: [
          SecondaryButton(
            label: 'Anterior',
            onPressed: onPrev,
          ),
          const SizedBox(width: AppSpacing.buttonGap),
          PrimaryButton(
            label: 'Siguiente: Revisión',
            icon: LucideIcons.arrowRight,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
