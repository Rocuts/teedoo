import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/mock/mock_data.dart';
import '../../data/models/invoice_model.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/navigation/app_topbar.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_toast.dart';

/// Pantalla de listado de facturas.
///
/// Ref Pencil: Invoices - List (StxCE) — 1440x900
class InvoicesListScreen extends StatefulWidget {
  const InvoicesListScreen({super.key});

  @override
  State<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends State<InvoicesListScreen> {
  int _activeTab = 0;
  List<Invoice> get _allInvoices => MockData.invoices;
  
  List<Invoice> get _filteredInvoices {
    switch (_activeTab) {
      case 1:
        return _allInvoices.where((i) => i.status == InvoiceStatus.draft).toList();
      case 2:
        return _allInvoices.where((i) => i.status == InvoiceStatus.sent).toList();
      case 3:
        return _allInvoices.where((i) => i.status == InvoiceStatus.rejected).toList();
      case 4:
        return _allInvoices.where((i) => i.status == InvoiceStatus.pendingReview).toList();
      default:
        return _allInvoices;
    }
  }

  List<String> get _tabLabels {
    return [
      'Todas (${_allInvoices.length})',
      'Borradores (${_allInvoices.where((i) => i.status == InvoiceStatus.draft).length})',
      'Enviadas (${_allInvoices.where((i) => i.status == InvoiceStatus.sent).length})',
      'Rechazadas (${_allInvoices.where((i) => i.status == InvoiceStatus.rejected).length})',
      'Pendientes (${_allInvoices.where((i) => i.status == InvoiceStatus.pendingReview).length})',
    ];
  }

  void _onTabChanged(int index) {
    if (index == _activeTab) return;
    setState(() => _activeTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTopbar(
          breadcrumbs: [
            BreadcrumbItem(
              label: 'Facturas',
              onTap: () => context.go(RoutePaths.invoices),
            ),
            const BreadcrumbItem(label: 'Bandeja'),
          ],
        ),
        Expanded(
          child: ClipRect(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.contentPaddingH,
                vertical: context.contentPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  if (context.isCompact) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Facturas',
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gestiona todas tus facturas electrónicas',
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                label: 'Importar',
                                icon: LucideIcons.upload,
                                onPressed: () {
                                  GlassToast.show(
                                    context,
                                    message: 'Abriendo ventana de importación masiva...',
                                    type: StatusType.info,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PrimaryButton(
                                label: 'Nueva factura',
                                icon: LucideIcons.plus,
                                onPressed: () => context.go(RoutePaths.invoiceCreate),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Facturas',
                                style: TextStyle(
                                  color: context.colors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gestiona todas tus facturas electrónicas',
                                style: TextStyle(
                                  color: context.colors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SecondaryButton(
                              label: 'Importar',
                              icon: LucideIcons.upload,
                              onPressed: () {
                                GlassToast.show(
                                  context,
                                  message: 'Abriendo ventana de importación masiva...',
                                  type: StatusType.info,
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            PrimaryButton(
                              label: 'Nueva factura',
                              icon: LucideIcons.plus,
                              onPressed: () => context.go(RoutePaths.invoiceCreate),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s20),

                  // Tabs
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: context.colors.borderSubtle),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 0; i < _tabLabels.length; i++)
                            _buildTab(_tabLabels[i], index: i, isActive: i == _activeTab),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),

                  // Table Card
                  Expanded(
                    child: GlassCard(
                      child: Column(
                        children: [
                          // Search bar
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
                                      Text('Filtros', style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Table header + data rows (horizontally scrollable)
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: SizedBox(
                                      width: 770, // sum of fixed columns: 40+140+200+100+100+100+90
                                      child: Column(
                                        children: [
                                          // Table header
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            color: context.colors.bgSurface,
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 40),
                                                SizedBox(width: 140, child: Text('N\u00ba Factura', style: TextStyle(color: context.colors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600))),
                                                Expanded(child: Text('Cliente', style: TextStyle(color: context.colors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600))),
                                                SizedBox(width: 100, child: Text('Monto', style: TextStyle(color: context.colors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600))),
                                                SizedBox(width: 100, child: Text('Estado', style: TextStyle(color: context.colors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600))),
                                                SizedBox(width: 100, child: Text('Compliance', style: TextStyle(color: context.colors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600))),
                                                SizedBox(width: 90, child: Text('Fecha', style: TextStyle(color: context.colors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600))),
                                              ],
                                            ),
                                          ),

                                          // Data rows
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: _filteredInvoices.length,
                                              itemBuilder: (context, index) {
                                                final inv = _filteredInvoices[index];
                                                final dateFormat = DateFormat('dd MMM yyyy');
                                                final formattedDate = dateFormat.format(inv.issueDate);
                                                final formattedCurrency = NumberFormat.currency(symbol: '\u20ac', decimalDigits: 2, locale: 'es_ES').format(inv.total);

                                                final row = _buildRow(
                                                  inv.number,
                                                  inv.receiverName,
                                                  formattedCurrency,
                                                  MockData.mapStatusToString(inv.status),
                                                  MockData.mapStatusToBadge(inv.status),
                                                  MockData.mapComplianceStatusToString(inv.complianceStatus),
                                                  MockData.mapComplianceStatusToBadge(inv.complianceStatus),
                                                  formattedDate,
                                                );
                                                if (index < 20) {
                                                  return row.animate()
                                                   .fadeIn(delay: Duration(milliseconds: 50 * index))
                                                   .slideX(begin: 0.05, duration: 300.ms, curve: Curves.easeOut);
                                                }
                                                return row;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Pagination
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: context.colors.borderSubtle),
                              ),
                            ),
                            child: context.isCompact
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Mostrando 1-${_filteredInvoices.length} de ${_filteredInvoices.length} facturas',
                                        style: TextStyle(color: context.colors.textTertiary, fontSize: 12),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Anterior  \u00b7  Siguiente',
                                        style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Mostrando 1-${_filteredInvoices.length} de ${_filteredInvoices.length} facturas',
                                        style: TextStyle(color: context.colors.textTertiary, fontSize: 12),
                                      ),
                                      Text(
                                        'Anterior  \u00b7  Siguiente',
                                        style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, {required int index, bool isActive = false}) {
    return Semantics(
      button: true,
      label: label,
      selected: isActive,
      child: InkWell(
        onTap: () => _onTabChanged(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: isActive
                  ? Border(bottom: BorderSide(color: context.colors.accentBlue, width: 2))
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ExcludeSemantics(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    color: isActive ? context.colors.accentBlue : context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String id, String client, String amount, String status, StatusType statusBadgeType, String compliance, StatusType complianceBadgeType, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.borderSubtle)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          SizedBox(
            width: 140,
            child: Text(id, style: TextStyle(color: context.colors.accentBlue, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(client, style: TextStyle(color: context.colors.textPrimary, fontSize: 13))),
          SizedBox(width: 100, child: Text(amount, style: TextStyle(color: context.colors.textPrimary, fontSize: 13))),
          SizedBox(width: 100, child: StatusBadge(label: status, type: statusBadgeType)),
          SizedBox(width: 100, child: StatusBadge(label: compliance, type: complianceBadgeType)),
          SizedBox(width: 90, child: Text(date, style: TextStyle(color: context.colors.textTertiary, fontSize: 12))),
        ],
      ),
    );
  }
}
