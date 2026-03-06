import 'package:flutter/material.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/glass_card.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final mainColumn = Column(
      children: [
        GlassCard(
          header: const GlassCardHeader(title: 'Emisor'),
          content: GlassCardContent(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Column(
              children: [
                _buildDetailRow(context, 'Razón social', receptorName),
                _buildDetailRow(context, 'NIF/CIF', receptorNif),
                _buildDetailRow(context, 'Dirección', receptorAddress),
              ],
            ),
          ),
        ),
      ],
    );

    final sideColumn = Column(
      children: [
        GlassCard(
          header: const GlassCardHeader(title: 'Desglose'),
          content: GlassCardContent(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Column(
              children: [
                _buildAmountRow(context, 'Base imponible', _formatCurrency(subtotal)),
                const SizedBox(height: 10),
                _buildAmountRow(context, 'IVA (21%)', _formatCurrency(taxAmount)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    color: context.colors.borderSubtle,
                    height: 1,
                  ),
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Column(
              children: [
                _buildDetailRow(context, 'Método', 'Transferencia bancaria'),
                _buildDetailRow(context, 'Vencimiento', '15 Mar 2026'),
                _buildDetailRow(context, 'Estado', 'Pendiente'),
                _buildDetailRow(context, 'IBAN', 'ES76 0182...'),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
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
          style: TextStyle(
            color: isBold
                ? context.colors.textPrimary
                : context.colors.textSecondary,
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? context.colors.textPrimary,
            fontSize: isBold ? 18 : 14,
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
