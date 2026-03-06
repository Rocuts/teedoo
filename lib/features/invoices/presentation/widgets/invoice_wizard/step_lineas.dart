import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../../shared/widgets/buttons/ghost_button.dart';
import 'invoice_line_data.dart';
import 'invoice_helpers.dart';

class StepLineas extends StatelessWidget {
  final List<InvoiceLineData> lines;
  final VoidCallback onAddLine;
  final void Function(int index) onRemoveLine;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onChanged;
  final double Function(int index) lineTotal;

  const StepLineas({
    super.key,
    required this.lines,
    required this.onAddLine,
    required this.onRemoveLine,
    required this.onNext,
    required this.onPrev,
    required this.onChanged,
    required this.lineTotal,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      header: const GlassCardHeader(
        title: 'Líneas de factura',
        subtitle: 'Añade los productos o servicios a facturar',
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Column(
                      children: [
                        _buildTableHeader(context),
                        for (int i = 0; i < lines.length; i++) _buildLineRow(context, i),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.s16),

            Align(
              alignment: Alignment.centerLeft,
              child: GhostButton(
                label: 'Añadir línea',
                icon: LucideIcons.plus,
                foregroundColor: context.colors.accentBlue,
                onPressed: onAddLine,
              ),
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
            label: 'Siguiente: Totales',
            icon: LucideIcons.arrowRight,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 280,
            child: Text(
              'Descripción',
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              'Cantidad',
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              'Precio unit.',
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              'IVA %',
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              'Total',
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLineRow(BuildContext context, int index) {
    final line = lines[index];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          SizedBox(
            width: 280,
            child: buildCompactInput(
              context,
              value: line.descriptionController.text,
              controller: line.descriptionController,
              onChanged: (v) {
                line.description = v;
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: buildCompactInput(
              context,
              value: line.quantityController.text,
              controller: line.quantityController,
              onChanged: (v) {
                line.quantity = v;
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: buildCompactInput(
              context,
              value: line.unitPriceController.text,
              controller: line.unitPriceController,
              prefix: '\u20ac',
              onChanged: (v) {
                line.unitPrice = v;
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: buildCompactInput(
              context,
              value: line.taxRateController.text,
              controller: line.taxRateController,
              suffix: '%',
              onChanged: (v) {
                line.taxRate = v;
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.colors.bgInput,
                borderRadius: AppRadius.inputAll,
                border: Border.all(color: context.colors.borderSubtle),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                formatCurrency(lineTotal(index)),
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            label: 'Eliminar línea ${index + 1}',
            enabled: lines.length > 1,
            child: InkWell(
              onTap: lines.length > 1 ? () => onRemoveLine(index) : null,
              borderRadius: BorderRadius.circular(4),
              child: ExcludeSemantics(
                child: Icon(
                  LucideIcons.trash2,
                  size: 16,
                  color: lines.length > 1
                      ? context.colors.statusError
                      : context.colors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
