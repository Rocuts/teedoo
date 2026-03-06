import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/badges/status_badge.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../shared/widgets/buttons/secondary_button.dart';
import 'invoice_line_data.dart';
import 'invoice_helpers.dart';

class StepRevision extends StatelessWidget {
  final String emisorName;
  final String emisorNif;
  final String emisorAddress;
  final String receptorName;
  final String receptorNif;
  final String receptorAddress;
  final List<InvoiceLineData> lines;
  final double subtotal;
  final double taxAmount;
  final double total;
  final double Function(int index) lineTotal;
  final bool isSaving;
  final VoidCallback onPrev;
  final VoidCallback onSubmit;

  const StepRevision({
    super.key,
    required this.emisorName,
    required this.emisorNif,
    required this.emisorAddress,
    required this.receptorName,
    required this.receptorNif,
    required this.receptorAddress,
    required this.lines,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    required this.lineTotal,
    required this.isSaving,
    required this.onPrev,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          header: const GlassCardHeader(
            title: 'Revisión final',
            subtitle: 'Verifique todos los datos antes de emitir la factura',
          ),
          content: GlassCardContent(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parties
                if (context.isCompact) ...[
                  _buildReviewSection(context, 'Emisor', [
                    _buildReviewRow(context, 'Razón social', emisorName),
                    _buildReviewRow(context, 'NIF/CIF', emisorNif),
                    _buildReviewRow(context, 'Dirección', emisorAddress),
                  ]),
                  const SizedBox(height: AppSpacing.s16),
                  _buildReviewSection(context, 'Receptor', [
                    _buildReviewRow(context, 'Razón social', receptorName),
                    _buildReviewRow(context, 'NIF/CIF', receptorNif),
                    _buildReviewRow(context, 'Dirección', receptorAddress),
                  ]),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildReviewSection(context, 'Emisor', [
                          _buildReviewRow(context, 'Razón social', emisorName),
                          _buildReviewRow(context, 'NIF/CIF', emisorNif),
                          _buildReviewRow(context, 'Dirección', emisorAddress),
                        ]),
                      ),
                      const SizedBox(width: AppSpacing.s24),
                      Expanded(
                        child: _buildReviewSection(context, 'Receptor', [
                          _buildReviewRow(context, 'Razón social', receptorName),
                          _buildReviewRow(context, 'NIF/CIF', receptorNif),
                          _buildReviewRow(context, 'Dirección', receptorAddress),
                        ]),
                      ),
                    ],
                  ),
                const SizedBox(height: AppSpacing.s24),

                Container(height: 1, color: context.colors.borderSubtle),
                const SizedBox(height: AppSpacing.s24),

                // Lines table
                Text(
                  'Líneas de factura',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                _buildLinesTableHeader(context),

                for (int i = 0; i < lines.length; i++)
                  _buildLineTableRow(context, i),
                const SizedBox(height: AppSpacing.s20),

                // Totals
                Align(
                  alignment: context.isCompact
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: SizedBox(
                    width: context.isCompact ? double.infinity : 280,
                    child: Column(
                      children: [
                        buildTotalRow(context, 'Subtotal', formatCurrency(subtotal)),
                        const SizedBox(height: 8),
                        buildTotalRow(context, 'IVA (21%)', formatCurrency(taxAmount)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
                ),
                const SizedBox(height: AppSpacing.s24),

                // Compliance badge preview
                Container(height: 1, color: context.colors.borderSubtle),
                const SizedBox(height: AppSpacing.s20),
                Row(
                  children: [
                    Icon(
                      LucideIcons.shieldCheck,
                      size: 18,
                      color: context.colors.statusSuccess,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Compliance check pendiente',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const StatusBadge(
                      label: 'Pending',
                      type: StatusType.info,
                    ),
                  ],
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
                label: isSaving ? 'Emitiendo...' : 'Emitir factura',
                icon: isSaving ? LucideIcons.loader : LucideIcons.check,
                onPressed: isSaving ? () {} : onSubmit,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinesTableHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Descripción',
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Cant.',
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              'Precio',
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              'IVA',
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              'Total',
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineTableRow(BuildContext context, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              lines[index].description,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              lines[index].quantity,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              '\u20ac${lines[index].unitPrice}',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${lines[index].taxRate}%',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              formatCurrency(lineTotal(index)),
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context, String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.bgInput,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildReviewRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
