import 'package:flutter/material.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../data/models/invoice_line.dart';
import '../../../data/models/invoice_model.dart';

class ResumenTab extends StatelessWidget {
  final String emisorName;
  final String emisorNif;
  final String emisorAddress;
  final String receptorName;
  final String receptorNif;
  final String receptorAddress;
  final double subtotal;
  final double taxAmount;
  final double total;
  final PaymentTerm? paymentTerm;
  final String? paymentMethod;
  final String? paymentIban;
  final String? dueDate;
  final String? notes;
  final List<InvoiceLine>? lines;

  const ResumenTab({
    super.key,
    required this.emisorName,
    required this.emisorNif,
    required this.emisorAddress,
    required this.receptorName,
    required this.receptorNif,
    required this.receptorAddress,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    this.paymentTerm,
    this.paymentMethod,
    this.paymentIban,
    this.dueDate,
    this.notes,
    this.lines,
  });

  @override
  Widget build(BuildContext context) {
    final mainColumn = Column(
      children: [
        GlassCard(
          header: const GlassCardHeader(title: 'Emisor'),
          content: GlassCardContent(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24,
              AppSpacing.xl,
              AppSpacing.s24,
              AppSpacing.s20,
            ),
            child: Column(
              children: [
                _buildDetailRow(context, 'Razón social', emisorName),
                _buildDetailRow(context, 'NIF/CIF', emisorNif),
                _buildDetailRow(context, 'Dirección', emisorAddress),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        GlassCard(
          header: const GlassCardHeader(title: 'Receptor'),
          content: GlassCardContent(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24,
              AppSpacing.xl,
              AppSpacing.s24,
              AppSpacing.s20,
            ),
            child: Column(
              children: [
                _buildDetailRow(context, 'Razón social', receptorName),
                _buildDetailRow(context, 'NIF/CIF', receptorNif),
                _buildDetailRow(context, 'Dirección', receptorAddress),
              ],
            ),
          ),
        ),
        if (lines != null && lines!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s16),
          GlassCard(
            header: const GlassCardHeader(title: 'Líneas de factura'),
            content: GlassCardContent(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.xl,
                AppSpacing.s24,
                AppSpacing.s20,
              ),
              child: Column(
                children: [
                  // Header row
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Descripción',
                          style: AppTypography.captionSmallBold.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          'Uds.',
                          textAlign: TextAlign.right,
                          style: AppTypography.captionSmallBold.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          'Precio',
                          textAlign: TextAlign.right,
                          style: AppTypography.captionSmallBold.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          'IVA',
                          textAlign: TextAlign.right,
                          style: AppTypography.captionSmallBold.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          'Total',
                          textAlign: TextAlign.right,
                          style: AppTypography.captionSmallBold.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Divider(
                      color: context.colors.borderSubtle,
                      height: 1,
                    ),
                  ),
                  // Line items
                  for (final line in lines!) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              line.description,
                              style: AppTypography.bodySmall.copyWith(
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${line.quantity}',
                              textAlign: TextAlign.right,
                              style: AppTypography.bodySmall.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              _formatCurrency(line.unitPrice),
                              textAlign: TextAlign.right,
                              style: AppTypography.bodySmall.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${line.taxRate.toStringAsFixed(0)}%',
                              textAlign: TextAlign.right,
                              style: AppTypography.bodySmall.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              _formatCurrency(line.total),
                              textAlign: TextAlign.right,
                              style: AppTypography.bodySmallMedium.copyWith(
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (notes != null && notes!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s16),
          GlassCard(
            header: const GlassCardHeader(title: 'Notas'),
            content: GlassCardContent(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.xl,
                AppSpacing.s24,
                AppSpacing.s20,
              ),
              child: Text(
                notes!,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    final sideColumn = Column(
      children: [
        GlassCard(
          header: const GlassCardHeader(title: 'Desglose'),
          content: GlassCardContent(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24,
              AppSpacing.xl,
              AppSpacing.s24,
              AppSpacing.s20,
            ),
            child: Column(
              children: [
                _buildAmountRow(
                  context,
                  'Base imponible',
                  _formatCurrency(subtotal),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildAmountRow(
                  context,
                  'IVA (21%)',
                  _formatCurrency(taxAmount),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Divider(color: context.colors.borderSubtle, height: 1),
                ),
                _buildAmountRow(
                  context,
                  'Total',
                  _formatCurrency(total),
                  isBold: true,
                  valueColor: context.colors.accentBlue,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        GlassCard(
          header: const GlassCardHeader(title: 'Pago'),
          content: GlassCardContent(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24,
              AppSpacing.xl,
              AppSpacing.s24,
              AppSpacing.s20,
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  context,
                  'Condición',
                  paymentTerm == PaymentTerm.contado ? 'Contado' : 'Crédito',
                ),
                _buildDetailRow(
                  context,
                  'Método',
                  paymentMethod ?? 'No especificado',
                ),
                if (dueDate != null)
                  _buildDetailRow(context, 'Vencimiento', dueDate!),
                if (paymentIban != null)
                  _buildDetailRow(context, 'IBAN', paymentIban!),
              ],
            ),
          ),
        ),
      ],
    );

    if (context.isExpanded) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: mainColumn),
          const SizedBox(width: AppSpacing.s20),
          SizedBox(width: 340, child: sideColumn),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mainColumn,
        const SizedBox(height: AppSpacing.s16),
        sideColumn,
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmallMedium.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isBold ? AppTypography.bodyMedium : AppTypography.bodySmall)
              .copyWith(
                color: isBold
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
              ),
        ),
        Text(
          value,
          style: (isBold ? AppTypography.logo : AppTypography.bodyMedium)
              .copyWith(
                color: valueColor ?? context.colors.textPrimary,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }

    return '\u20ac$buffer,$decPart';
  }
}
