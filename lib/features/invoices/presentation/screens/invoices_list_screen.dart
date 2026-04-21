import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/session/data_source.dart';
import '../../../../core/session/data_source_provider.dart';
import '../../data/invoices_repository.dart';
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
import '../../../../shared/widgets/active_backend_chip.dart';
import '../../../../shared/widgets/db_target_selector.dart';
import '../widgets/liquidity_panel.dart';

/// Pantalla de listado de facturas.
///
/// Ref Pencil: Invoices - List (StxCE) — 1440x900
class InvoicesListScreen extends ConsumerStatefulWidget {
  const InvoicesListScreen({super.key});

  @override
  ConsumerState<InvoicesListScreen> createState() =>
      _InvoicesListScreenState();
}

class _InvoicesListScreenState extends ConsumerState<InvoicesListScreen> {
  int _activeTab = 0;

  List<Invoice> _computeFiltered(List<Invoice> all, int tab) {
    return switch (tab) {
      1 => all.where((i) => i.status == InvoiceStatus.draft).toList(),
      2 => all.where((i) => i.status == InvoiceStatus.sent).toList(),
      3 => all.where((i) => i.status == InvoiceStatus.rejected).toList(),
      4 =>
        all.where((i) => i.status == InvoiceStatus.pendingReview).toList(),
      _ => all,
    };
  }

  List<String> _buildTabLabels(List<Invoice> all) => [
    'Todas (${all.length})',
    'Borradores (${all.where((i) => i.status == InvoiceStatus.draft).length})',
    'Enviadas (${all.where((i) => i.status == InvoiceStatus.sent).length})',
    'Rechazadas (${all.where((i) => i.status == InvoiceStatus.rejected).length})',
    'Pendientes (${all.where((i) => i.status == InvoiceStatus.pendingReview).length})',
  ];

  void _onTabChanged(int index) {
    if (index == _activeTab) return;
    setState(() => _activeTab = index);
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesListProvider);

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
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.s20),
                  invoicesAsync.when(
                    data: (invoices) => Expanded(
                      child: _buildContent(invoices),
                    ),
                    loading: () => const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => Expanded(
                      child: _buildError(err),
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

  Widget _buildHeader(BuildContext context) {
    if (context.isCompact) {
      return Column(
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
          const Align(
            alignment: Alignment.centerLeft,
            child: DbTargetSelector(compact: true),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Align(
            alignment: Alignment.centerLeft,
            child: ActiveBackendChip(),
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
                      message: 'Abriendo ventana de importación masiva...',
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
                  onPressed: () => context.go(RoutePaths.invoiceCreate),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Facturas',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const ActiveBackendChip(),
                ],
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
            const DbTargetSelector(),
            const SizedBox(width: AppSpacing.lg),
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
            const SizedBox(width: AppSpacing.buttonGap),
            PrimaryButton(
              label: 'Nueva factura',
              icon: LucideIcons.plus,
              onPressed: () => context.go(RoutePaths.invoiceCreate),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(List<Invoice> all) {
    final tabLabels = _buildTabLabels(all);
    final filtered = _computeFiltered(all, _activeTab);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                for (int i = 0; i < tabLabels.length; i++)
                  _buildTab(
                    tabLabels[i],
                    index: i,
                    isActive: i == _activeTab,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s20),
        Expanded(
          child: ListView(
            children: [
              const LiquidityPanel(),
              const SizedBox(height: AppSpacing.s20),
              SizedBox(
                height: 520,
                child: GlassCard(
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      Expanded(child: _buildTable(filtered)),
                      _buildPagination(filtered.length),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
              'No se pudieron cargar las facturas',
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
              onPressed: () => ref.invalidate(invoicesListProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
          const SizedBox(width: AppSpacing.buttonGap),
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
                const SizedBox(width: AppSpacing.sm),
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
    );
  }

  Widget _buildTable(List<Invoice> filtered) {
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: SizedBox(
              width: 770,
              child: Column(
                children: [
                  _buildTableHeader(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final inv = filtered[index];
                        final dateFormat = DateFormat('dd MMM yyyy');
                        final formattedDate =
                            dateFormat.format(inv.issueDate);
                        final formattedCurrency = NumberFormat.currency(
                          symbol: '€',
                          decimalDigits: 2,
                          locale: 'es_ES',
                        ).format(inv.total);

                        final row = _buildRow(
                          inv.id,
                          inv.number,
                          inv.receiverName,
                          formattedCurrency,
                          MockData.mapStatusToString(inv.status),
                          MockData.mapStatusToBadge(inv.status),
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
                                delay: Duration(milliseconds: 50 * index),
                              )
                              .slideX(
                                begin: 0.05,
                                duration: 300.ms,
                                curve: Curves.easeOut,
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
    );
  }

  Widget _buildEmptyState() {
    final source = ref.read(dataSourceProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.inbox,
              size: 40,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No hay facturas en ${source.label}',
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Prueba a cambiar de backend o a ejecutar el seed.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      color: context.colors.bgSurface,
      child: Row(
        children: [
          const SizedBox(width: 40),
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
    );
  }

  Widget _buildPagination(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
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
                  'Mostrando 1-$count de $count facturas',
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Anterior  ·  Siguiente',
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mostrando 1-$count de $count facturas',
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
                  style: (isActive
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
