import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/mock/mock_data.dart';
import '../../data/models/invoice_model.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/navigation/app_topbar.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_toast.dart';
import '../widgets/liquidity_panel.dart';

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
  late final List<Invoice> _allInvoices;
  late final List<String> _tabLabels;
  late List<Invoice> _filteredInvoices;

  @override
  void initState() {
    super.initState();
    _allInvoices = MockData.invoices;
    _tabLabels = [
      'Todas (${_allInvoices.length})',
      'Borradores (${_allInvoices.where((i) => i.status == InvoiceStatus.draft).length})',
      'Enviadas (${_allInvoices.where((i) => i.status == InvoiceStatus.sent).length})',
      'Rechazadas (${_allInvoices.where((i) => i.status == InvoiceStatus.rejected).length})',
      'Pendientes (${_allInvoices.where((i) => i.status == InvoiceStatus.pendingReview).length})',
    ];
    _filteredInvoices = _allInvoices;
  }

  List<Invoice> _computeFiltered(int tab) {
    return switch (tab) {
      1 => _allInvoices.where((i) => i.status == InvoiceStatus.draft).toList(),
      2 => _allInvoices.where((i) => i.status == InvoiceStatus.sent).toList(),
      3 => _allInvoices.where((i) => i.status == InvoiceStatus.rejected).toList(),
      4 => _allInvoices.where((i) => i.status == InvoiceStatus.pendingReview).toList(),
      _ => _allInvoices,
    };
  }

  void _onTabChanged(int index) {
    if (index == _activeTab) return;
    setState(() {
      _activeTab = index;
      _filteredInvoices = _computeFiltered(index);
    });
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
                          style: AppTypography.h2.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Gestiona todas tus facturas electrónicas',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                label: 'Importar',
                                icon: LucideIcons.upload,
                                onPressed: () {
                                  GlassToast.show(
                                    context,
                                    message:
                                        'Abriendo ventana de importación masiva...',
                                    type: StatusType.info,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.buttonGap),
                            Expanded(
                              child: PrimaryButton(
                                label: 'Nueva factura',
                                icon: LucideIcons.plus,
                                onPressed: () =>
                                    context.go(RoutePaths.invoiceCreate),
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
                              const SizedBox(height: AppSpacing.xs),
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
                                  message:
                                      'Abriendo ventana de importación masiva...',
                                  type: StatusType.info,
                                );
                              },
                            ),
                            const SizedBox(width: AppSpacing.buttonGap),
                            PrimaryButton(
                              label: 'Nueva factura',
                              icon: LucideIcons.plus,
                              onPressed: () =>
                                  context.go(RoutePaths.invoiceCreate),
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
                            _buildTab(
                              _tabLabels[i],
                              index: i,
                              isActive: i == _activeTab,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),

                  // Liquidity Panel + Table
                  Expanded(
                    child: ListView(
                      children: [
                        const LiquidityPanel(),
                        const SizedBox(height: AppSpacing.s20),

                        // Table Card
                        SizedBox(
                          height: 520,
                          child: GlassCard(
                            child: Column(
                              children: [
                                // Search bar
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xl,
                                    vertical: AppSpacing.lg,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: context.colors.borderSubtle,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        LucideIcons.search,
                                        size: 16,
                                        color: context.colors.textTertiary,
                                      ),
                                      const SizedBox(
                                        width: AppSpacing.buttonGap,
                                      ),
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
                                          border: Border.all(
                                            color: context.colors.borderSubtle,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              LucideIcons.filter,
                                              size: 14,
                                              color:
                                                  context.colors.textTertiary,
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.sm,
                                            ),
                                            Text(
                                              'Filtros',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: context
                                                        .colors
                                                        .textSecondary,
                                                  ),
                                            ),
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
                                            width:
                                                770, // sum of fixed columns: 40+140+200+100+100+100+90
                                            child: Column(
                                              children: [
                                                // Table header
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal:
                                                            AppSpacing.xl,
                                                        vertical: AppSpacing.sm,
                                                      ),
                                                  color:
                                                      context.colors.bgSurface,
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(width: 40),
                                                      SizedBox(
                                                        width: 140,
                                                        child: Text(
                                                          'N\u00ba Factura',
                                                          style: AppTypography
                                                              .captionSmallBold
                                                              .copyWith(
                                                                color: context
                                                                    .colors
                                                                    .textTertiary,
                                                              ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          'Cliente',
                                                          style: AppTypography
                                                              .captionSmallBold
                                                              .copyWith(
                                                                color: context
                                                                    .colors
                                                                    .textTertiary,
                                                              ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 100,
                                                        child: Text(
                                                          'Monto',
                                                          style: AppTypography
                                                              .captionSmallBold
                                                              .copyWith(
                                                                color: context
                                                                    .colors
                                                                    .textTertiary,
                                                              ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 100,
                                                        child: Text(
                                                          'Estado',
                                                          style: AppTypography
                                                              .captionSmallBold
                                                              .copyWith(
                                                                color: context
                                                                    .colors
                                                                    .textTertiary,
                                                              ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 100,
                                                        child: Text(
                                                          'Compliance',
                                                          style: AppTypography
                                                              .captionSmallBold
                                                              .copyWith(
                                                                color: context
                                                                    .colors
                                                                    .textTertiary,
                                                              ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 90,
                                                        child: Text(
                                                          'Fecha',
                                                          style: AppTypography
                                                              .captionSmallBold
                                                              .copyWith(
                                                                color: context
                                                                    .colors
                                                                    .textTertiary,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Data rows
                                                Expanded(
                                                  child: ListView.builder(
                                                    itemCount: _filteredInvoices
                                                        .length,
                                                    itemBuilder: (context, index) {
                                                      final inv =
                                                          _filteredInvoices[index];
                                                      final dateFormat =
                                                          DateFormat(
                                                            'dd MMM yyyy',
                                                          );
                                                      final formattedDate =
                                                          dateFormat.format(
                                                            inv.issueDate,
                                                          );
                                                      final formattedCurrency =
                                                          NumberFormat.currency(
                                                            symbol: '\u20ac',
                                                            decimalDigits: 2,
                                                            locale: 'es_ES',
                                                          ).format(inv.total);

                                                      final row = _buildRow(
                                                        inv.id,
                                                        inv.number,
                                                        inv.receiverName,
                                                        formattedCurrency,
                                                        MockData.mapStatusToString(
                                                          inv.status,
                                                        ),
                                                        MockData.mapStatusToBadge(
                                                          inv.status,
                                                        ),
                                                        MockData.mapComplianceStatusToString(
                                                          inv.complianceStatus,
                                                        ),
                                                        MockData.mapComplianceStatusToBadge(
                                                          inv.complianceStatus,
                                                        ),
                                                        formattedDate,
                                                      );
                                                      if (index < 20) {
                                                        return row
                                                            .animate()
                                                            .fadeIn(
                                                              delay: Duration(
                                                                milliseconds:
                                                                    50 * index,
                                                              ),
                                                            )
                                                            .slideX(
                                                              begin: 0.05,
                                                              duration: 300.ms,
                                                              curve: Curves
                                                                  .easeOut,
                                                            );
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xl,
                                    vertical: AppSpacing.lg,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: context.colors.borderSubtle,
                                      ),
                                    ),
                                  ),
                                  child: context.isCompact
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Mostrando 1-${_filteredInvoices.length} de ${_filteredInvoices.length} facturas',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: context
                                                        .colors
                                                        .textTertiary,
                                                  ),
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.sm,
                                            ),
                                            Text(
                                              'Anterior  \u00b7  Siguiente',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: context
                                                        .colors
                                                        .textSecondary,
                                                  ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Mostrando 1-${_filteredInvoices.length} de ${_filteredInvoices.length} facturas',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: context
                                                        .colors
                                                        .textTertiary,
                                                  ),
                                            ),
                                            Text(
                                              'Anterior  \u00b7  Siguiente',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: context
                                                        .colors
                                                        .textSecondary,
                                                  ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: isActive
                  ? Border(
                      bottom: BorderSide(
                        color: context.colors.accentBlue,
                        width: 2,
                      ),
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ExcludeSemantics(
                child: Text(
                  label,
                  style:
                      (isActive
                              ? AppTypography.bodySmallMedium
                              : AppTypography.bodySmall)
                          .copyWith(
                            color: isActive
                                ? context.colors.accentBlue
                                : context.colors.textSecondary,
                          ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String invoiceId,
    String number,
    String client,
    String amount,
    String status,
    StatusType statusBadgeType,
    String compliance,
    StatusType complianceBadgeType,
    String date,
  ) {
    return InkWell(
      onTap: () => context.go(RoutePaths.invoiceDetail(invoiceId)),
      child: Container(
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
            const SizedBox(width: 40),
            SizedBox(
              width: 140,
              child: Text(
                number,
                style: AppTypography.bodySmallMedium.copyWith(
                  color: context.colors.accentBlue,
                ),
              ),
            ),
            Expanded(
              child: Text(
                client,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                amount,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: StatusBadge(label: status, type: statusBadgeType),
            ),
            SizedBox(
              width: 100,
              child: StatusBadge(label: compliance, type: complianceBadgeType),
            ),
            SizedBox(
              width: 90,
              child: Text(
                date,
                style: AppTypography.caption.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
