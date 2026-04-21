import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../data/invoices_repository.dart';
import '../../data/models/invoice_model.dart';
import '../../../../shared/widgets/active_backend_chip.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/navigation/app_topbar.dart';
import '../widgets/invoice_tabs.dart';
import '../widgets/detail/detail_header.dart';
import '../widgets/detail/resumen_tab.dart';
import '../widgets/detail/datos_estructurados_tab.dart';
import '../widgets/detail/adjuntos_tab.dart';
import '../widgets/detail/compliance_tab.dart';
import '../widgets/detail/auditoria_tab.dart';

/// Pantalla de detalle de factura.
///
/// Ref Pencil: Invoice - Detail (lLtlh) — 1440x900
/// Tabs: Resumen | Datos estructurados | Adjuntos | Compliance IA | Auditoría
class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  int _activeTab = 0;
  final _scrollController = ScrollController();

  void _onTabChanged(int index) {
    if (index == _activeTab) return;
    setState(() => _activeTab = index);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(invoiceByIdProvider(widget.invoiceId));

    return Column(
      children: [
        AppTopbar(
          breadcrumbs: [
            BreadcrumbItem(
              label: 'Facturas',
              onTap: () => context.go(RoutePaths.invoices),
            ),
            BreadcrumbItem(
              label: invoiceAsync.maybeWhen(
                data: (inv) => inv.number,
                orElse: () => '…',
              ),
            ),
          ],
        ),
        Expanded(
          child: invoiceAsync.when(
            data: (inv) => _buildLoaded(inv),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (err, _) => _buildError(err),
          ),
        ),
      ],
    );
  }

  Widget _buildLoaded(Invoice inv) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es');

    return ClipRect(
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: context.contentPaddingH,
          vertical: context.contentPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DetailHeader(
                    invoiceNumber: inv.number,
                    status: inv.status,
                    complianceStatus: inv.complianceStatus,
                  ),
                ),
                const ActiveBackendChip(),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),
            InvoiceTabs(
              tabs: [
                const InvoiceTabItem(label: 'Resumen'),
                const InvoiceTabItem(label: 'Datos estructurados'),
                const InvoiceTabItem(label: 'Adjuntos'),
                InvoiceTabItem(
                  label: 'Compliance IA',
                  icon: Icon(
                    LucideIcons.sparkles,
                    size: 14,
                    color: context.colors.aiPurple,
                  ),
                ),
                const InvoiceTabItem(label: 'Auditoría'),
              ],
              activeIndex: _activeTab,
              onTabChanged: _onTabChanged,
            ),
            const SizedBox(height: AppSpacing.s24),
            KeyedSubtree(
              key: ValueKey<int>(_activeTab),
              child: switch (_activeTab) {
                0 => ResumenTab(
                  emisorName: inv.issuerName,
                  emisorNif: inv.issuerNif,
                  emisorAddress: inv.issuerAddress ?? '',
                  receptorName: inv.receiverName,
                  receptorNif: inv.receiverNif,
                  receptorAddress: inv.receiverAddress ?? '',
                  subtotal: inv.subtotal,
                  taxAmount: inv.taxAmount,
                  total: inv.total,
                  paymentTerm: inv.paymentTerm,
                  paymentMethod: inv.paymentMethod,
                  paymentIban: inv.paymentIban,
                  dueDate: inv.dueDate != null
                      ? dateFormat.format(inv.dueDate!)
                      : null,
                  notes: inv.notes,
                  lines: inv.lines,
                ),
                1 => const DatosEstructuradosTab(),
                2 => const AdjuntosTab(),
                3 => const ComplianceTab(),
                4 => const AuditoriaTab(),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 40,
              color: context.colors.statusError,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No se pudo cargar la factura',
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$err',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Reintentar',
              icon: LucideIcons.refreshCw,
              onPressed: () =>
                  ref.invalidate(invoiceByIdProvider(widget.invoiceId)),
            ),
          ],
        ),
      ),
    );
  }
}
