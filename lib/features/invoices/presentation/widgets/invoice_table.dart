import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.colors.borderSubtle),
              ),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.search, size: 16, color: context.colors.textTertiary),
                const SizedBox(width: 12),
                Text(
                  'Buscar facturas...',
                  style: TextStyle(color: context.colors.textTertiary, fontSize: 13),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.colors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.filter, size: 14, color: context.colors.textTertiary),
                      const SizedBox(width: 6),
                      Text(
                        'Filtros',
                        style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: context.colors.bgSurface,
          child: Row(
            children: [
              const SizedBox(width: AppDimensions.tableCheckboxColumnWidth),
              SizedBox(
                width: 140,
                child: Text(
                  'Nº Factura',
                  style: TextStyle(
                    color: context.colors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Cliente',
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
                  'Monto',
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
                  'Estado',
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
                  'Compliance',
                  style: TextStyle(
                    color: context.colors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                child: Text(
                  'Fecha',
                  style: TextStyle(
                    color: context.colors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: context.colors.borderSubtle),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  paginationText ?? 'Mostrando 1-${rows.length} de ${rows.length} facturas',
                  style: TextStyle(color: context.colors.textTertiary, fontSize: 12),
                ),
                Text(
                  'Anterior  ·  Siguiente',
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
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
          border: Border(bottom: BorderSide(color: context.colors.borderSubtle)),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppDimensions.tableCheckboxColumnWidth),
            SizedBox(
              width: 140,
              child: Text(
                row.id,
                style: TextStyle(
                  color: context.colors.accentBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                row.client,
                style: TextStyle(color: context.colors.textPrimary, fontSize: 13),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                row.amount,
                style: TextStyle(color: context.colors.textPrimary, fontSize: 13),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                row.statusLabel,
                style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
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
                style: TextStyle(color: context.colors.textTertiary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
