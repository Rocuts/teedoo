import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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
    final activeWidgetId = ref.watch(
      aiVoiceProvider.select((s) => s.activeWidgetId),
    );

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
          style: (isCompact ? AppTypography.h3 : AppTypography.h2).copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Resumen de actividad \u00b7 Espa\u00f1a',
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
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
              const SizedBox(width: AppSpacing.sm),
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
              const SizedBox(width: AppSpacing.buttonGap),
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
          const SizedBox(height: AppSpacing.lg),
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
                .map(
                  (card) => SizedBox(
                    width: (constraints.maxWidth - AppSpacing.s16) / 2,
                    child: card,
                  ),
                )
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
        .fade(delay: AppMotion.durationSlow)
        .slideY(
          begin: AppMotion.slideEntryOffset,
          duration: AppMotion.durationSlow,
        )
        .animate(target: activeWidgetId == 'revenue_chart' ? 1.0 : 0.0)
        .scaleXY(
          begin: 1.0,
          end: AppMotion.scaleActive,
          duration: 600.ms,
          curve: Curves.easeOutBack,
        )
        .custom(
          duration: 600.ms,
          builder: (context, value, child) => DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardAll,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentBlue.withValues(alpha: 0.3 * value),
                  blurRadius: 20 * value,
                  spreadRadius: 2 * value,
                ),
              ],
            ),
            child: child,
          ),
        );

    final statusPanel = const InvoiceStatusPanel()
        .animate()
        .fade(delay: AppMotion.durationSlow)
        .slideY(
          begin: AppMotion.slideEntryOffset,
          duration: AppMotion.durationSlow,
        )
        .animate(target: activeWidgetId == 'invoice_status_panel' ? 1.0 : 0.0)
        .scaleXY(
          begin: 1.0,
          end: AppMotion.scaleActive,
          duration: 600.ms,
          curve: Curves.easeOutBack,
        )
        .custom(
          duration: 600.ms,
          builder: (context, value, child) => DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardAll,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentBlue.withValues(alpha: 0.3 * value),
                  blurRadius: 20 * value,
                  spreadRadius: 2 * value,
                ),
              ],
            ),
            child: child,
          ),
        );

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
          padding: const EdgeInsets.all(AppSpacing.s20),
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
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: AppSpacing.s36,
                    height: AppSpacing.s36,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // ── Value ──
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: AppTypography.h1.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // ── Trend ──
              Text(
                trend,
                style: AppTypography.caption.copyWith(color: trendColor),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
        .animate()
        .fade(delay: delay)
        .slideY(begin: 0.1, duration: AppMotion.durationSlow)
        .animate(target: isActive ? 1.0 : 0.0)
        .scaleXY(
          begin: 1.0,
          end: 1.05,
          duration: 600.ms,
          curve: Curves.easeOutBack,
        )
        .custom(
          duration: 600.ms,
          builder: (context, value, child) => DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardAll,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentBlue.withValues(alpha: 0.3 * value),
                  blurRadius: 20 * value,
                  spreadRadius: 2 * value,
                ),
              ],
            ),
            child: child,
          ),
        );
  }
}
