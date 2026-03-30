import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';

/// Datos de una fila de factura para [InvoiceTable].
class InvoiceTableRow {
  final String id;
  final String client;
  final String amount;
  final String statusLabel;
  final StatusType statusType;
  final String date;
  final VoidCallback? onTap;

  const InvoiceTableRow({
    required this.id,
    required this.client,
    required this.amount,
    required this.statusLabel,
    required this.statusType,
    required this.date,
    this.onTap,
  });
}

/// Tabla reutilizable de facturas.
///
/// Extraída de [InvoicesListScreen] para uso en listado,
/// dashboard y otros contextos.
class InvoiceTable extends StatelessWidget {
  final List<InvoiceTableRow> rows;
  final bool showSearch;
  final bool showPagination;
  final String? paginationText;

  const InvoiceTable({
    super.key,
    required this.rows,
    this.showSearch = true,
    this.showPagination = true,
    this.paginationText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        if (showSearch)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.colors.borderSubtle),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.search,
                  size: 16,
                  color: context.colors.textTertiary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Buscar facturas...',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(color: context.colors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.filter,
                        size: 14,
                        color: context.colors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Filtros',
                        style: AppTypography.caption.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Table header
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          color: context.colors.bgSurface,
          child: Row(
            children: [
              const SizedBox(width: AppDimensions.tableCheckboxColumnWidth),
              SizedBox(
                width: 140,
                child: Text(
                  'Nº Factura',
                  style: AppTypography.captionSmallBold.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Cliente',
                  style: AppTypography.captionSmallBold.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  'Monto',
                  style: AppTypography.captionSmallBold.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  'Estado',
                  style: AppTypography.captionSmallBold.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  'Compliance',
                  style: AppTypography.captionSmallBold.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                child: Text(
                  'Fecha',
                  style: AppTypography.captionSmallBold.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Rows
        Expanded(
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) => _buildRow(context, rows[index]),
          ),
        ),

        // Pagination
        if (showPagination)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: context.colors.borderSubtle),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  paginationText ??
                      'Mostrando 1-${rows.length} de ${rows.length} facturas',
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
                Text(
                  'Anterior  ·  Siguiente',
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, InvoiceTableRow row) {
    return GestureDetector(
      onTap: row.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.colors.borderSubtle),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppDimensions.tableCheckboxColumnWidth),
            SizedBox(
              width: 140,
              child: Text(
                row.id,
                style: AppTypography.bodySmallMedium.copyWith(
                  color: context.colors.accentBlue,
                ),
              ),
            ),
            Expanded(
              child: Text(
                row.client,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                row.amount,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                row.statusLabel,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: StatusBadge(label: row.statusLabel, type: row.statusType),
            ),
            SizedBox(
              width: 90,
              child: Text(
                row.date,
                style: TextStyle(
                  color: context.colors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
