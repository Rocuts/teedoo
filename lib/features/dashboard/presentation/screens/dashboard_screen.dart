import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/navigation/app_topbar.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../widgets/monthly_revenue_chart.dart';
import '../widgets/invoice_status_panel.dart';
import '../../../../shared/widgets/glass_toast.dart';
import '../../../../shared/widgets/badges/status_badge.dart';

/// Pantalla de Dashboard.
///
/// Ref Pencil: Dashboard (vbTTy) — 1440x900
/// - Topbar con breadcrumbs
/// - Header: "Dashboard" + acciones
/// - KPI Row (4 cards)
/// - Bottom Row: Gráfico Ingresos + Estado Facturas
/// - Bottom Row: Gráfico Ingresos + Estado Facturas
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Listen to Voice Agent's Active Widget ID ──
    final activeWidgetId = ref.watch(aiVoiceProvider).activeWidgetId;

    return Column(
      children: [
        // ── Topbar ──
        const AppTopbar(
          breadcrumbs: [
            BreadcrumbItem(label: 'Dashboard'),
            BreadcrumbItem(label: 'Overview'),
          ],
        ),

        // ── Content ──
        Expanded(
          child: ClipRect(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.contentPaddingH,
                vertical: context.contentPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Page Header ──
                  _buildPageHeader(context),
                  const SizedBox(height: AppSpacing.s24),

                  // ── KPI Row ──
                  _buildKpiRow(context, activeWidgetId),
                  const SizedBox(height: AppSpacing.s20),

                  // ── Bottom Row: Chart + Status ──
                  _buildBottomRow(context, activeWidgetId),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Page Header (responsive) ──
  Widget _buildPageHeader(BuildContext context) {
    final isCompact = context.isCompact;

    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: isCompact ? 20 : 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Resumen de actividad \u00b7 Espa\u00f1a',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );

    final actions = isCompact
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                label: 'Nueva',
                icon: LucideIcons.plus,
                onPressed: () => context.go(RoutePaths.invoiceCreate),
              ),
              const SizedBox(width: 8),
              SecondaryButton(
                label: 'Exportar',
                icon: LucideIcons.download,
                onPressed: () {
                  GlassToast.show(
                    context,
                    message: 'Generando exportaci\u00f3n del dashboard...',
                    type: StatusType.info,
                  );
                },
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                label: 'Nueva factura',
                icon: LucideIcons.plus,
                onPressed: () => context.go(RoutePaths.invoiceCreate),
              ),
              const SizedBox(width: 12),
              SecondaryButton(
                label: 'Exportar',
                icon: LucideIcons.download,
                onPressed: () {
                  GlassToast.show(
                    context,
                    message: 'Generando exportaci\u00f3n del dashboard...',
                    type: StatusType.info,
                  );
                },
              ),
            ],
          );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleColumn,
          const SizedBox(height: 12),
          actions,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: titleColumn),
        actions,
      ],
    );
  }

  // ── KPI Row (responsive: 1-col compact, 2x2 medium, 4-in-row expanded) ──
  Widget _buildKpiRow(BuildContext context, String? activeWidgetId) {
    final kpiCards = [
      _buildKpiCard(
        context,
        id: 'emitted_kpi',
        activeId: activeWidgetId,
        label: 'Facturas Emitidas',
        value: MockData.dashboardKpis['emitted']!['value']!,
        trend: MockData.dashboardKpis['emitted']!['trend']!,
        trendColor: context.colors.statusSuccess,
        icon: LucideIcons.fileText,
        iconBgColor: context.colors.statusInfoBg,
        iconColor: context.colors.statusInfo,
        delay: 0.ms,
      ),
      _buildKpiCard(
        context,
        id: 'revenue_kpi',
        activeId: activeWidgetId,
        label: 'Ingresos del Mes',
        value: MockData.dashboardKpis['revenue']!['value']!,
        trend: MockData.dashboardKpis['revenue']!['trend']!,
        trendColor: context.colors.statusSuccess,
        icon: LucideIcons.dollarSign,
        iconBgColor: context.colors.statusSuccessBg,
        iconColor: context.colors.statusSuccess,
        delay: 100.ms,
      ),
      _buildKpiCard(
        context,
        id: 'pending_kpi',
        activeId: activeWidgetId,
        label: 'Pendientes de Cobro',
        value: MockData.dashboardKpis['pending']!['value']!,
        trend: MockData.dashboardKpis['pending']!['trend']!,
        trendColor: context.colors.textTertiary,
        icon: LucideIcons.clock,
        iconBgColor: context.colors.statusWarningBg,
        iconColor: context.colors.statusWarning,
        delay: 200.ms,
      ),
      _buildKpiCard(
        context,
        id: 'overdue_kpi',
        activeId: activeWidgetId,
        label: 'Facturas Vencidas',
        value: MockData.dashboardKpis['overdue']!['value']!,
        trend: MockData.dashboardKpis['overdue']!['trend']!,
        trendColor: context.colors.statusError,
        icon: LucideIcons.alertTriangle,
        iconBgColor: context.colors.statusErrorBg,
        iconColor: context.colors.statusError,
        delay: 300.ms,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Compact: single column, each card full width
        if (context.isCompact) {
          return Column(
            children: [
              for (int i = 0; i < kpiCards.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.lg),
                SizedBox(width: double.infinity, child: kpiCards[i]),
              ],
            ],
          );
        }

        // Medium: 2x2 grid
        if (context.isMedium) {
          return Wrap(
            spacing: AppSpacing.s16,
            runSpacing: AppSpacing.s16,
            children: kpiCards
                .map((card) => SizedBox(
                      width: (constraints.maxWidth - AppSpacing.s16) / 2,
                      child: card,
                    ))
                .toList(),
          );
        }

        // Expanded: 4 in a single row
        return Row(
          children: [
            for (int i = 0; i < kpiCards.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.s16),
              Expanded(child: kpiCards[i]),
            ],
          ],
        );
      },
    );
  }

  // ── Bottom Row: Chart + Status (responsive) ──
  Widget _buildBottomRow(BuildContext context, String? activeWidgetId) {
    final revenueChart = const MonthlyRevenueChart()
        .animate()
        .fade(delay: 400.ms)
        .slideY(begin: 0.05, duration: 500.ms)
        .animate(target: activeWidgetId == 'revenue_chart' ? 1.0 : 0.0)
        .shimmer(duration: 1200.ms, color: Colors.white24)
        .scaleXY(begin: 1.0, end: 1.02, curve: Curves.easeOutBack);

    final statusPanel = const InvoiceStatusPanel()
        .animate()
        .fade(delay: 500.ms)
        .slideY(begin: 0.05, duration: 500.ms)
        .animate(target: activeWidgetId == 'invoice_status_panel' ? 1.0 : 0.0)
        .shimmer(duration: 1200.ms, color: Colors.white24)
        .scaleXY(begin: 1.0, end: 1.02, curve: Curves.easeOutBack);

    // Compact & Medium: stack vertically
    if (context.isCompact || context.isMedium) {
      return Column(
        children: [
          revenueChart,
          const SizedBox(height: AppSpacing.s20),
          statusPanel,
        ],
      );
    }

    // Expanded: side by side (2:1 ratio)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: revenueChart),
        const SizedBox(width: AppSpacing.s20),
        Expanded(child: statusPanel),
      ],
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String id,
    required String? activeId,
    required String label,
    required String value,
    required String trend,
    required Color trendColor,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    Duration delay = Duration.zero,
  }) {
    final isActive = id == activeId;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top: label + icon ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Value ──
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ── Trend ──
            Text(
              trend,
              style: TextStyle(
                color: trendColor,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ).animate().fade(delay: delay).slideY(begin: 0.1, duration: 400.ms)
       .animate(target: isActive ? 1.0 : 0.0)
       .shimmer(duration: 1000.ms, color: Colors.white24)
       .scaleXY(begin: 1.0, end: 1.05, curve: Curves.easeOutBack);
  }
}
