import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/navigation/app_topbar.dart';
import '../../data/models/fiscal_rule.dart';
import '../../data/models/optimization_report.dart';
import '../../providers/fiscal_provider.dart';
import '../widgets/fiscal_profile_form.dart';
import '../widgets/optimizations_list.dart';
import '../widgets/savings_summary_panel.dart';
import '../widgets/tax_breakdown_chart.dart';

/// Pantalla principal de Optimización Fiscal.
class FiscalScreen extends ConsumerStatefulWidget {
  const FiscalScreen({super.key});

  @override
  ConsumerState<FiscalScreen> createState() => _FiscalScreenState();
}

class _FiscalScreenState extends ConsumerState<FiscalScreen> {
  TaxType? _selectedTax;

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(fiscalAnalysisProvider);
    final profile = ref.watch(fiscalProfileProvider);

    return Column(
      children: [
        const AppTopbar(
          breadcrumbs: [
            BreadcrumbItem(label: 'Fiscal'),
            BreadcrumbItem(label: 'Optimización'),
          ],
        ),
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
                  // ── Header ──
                  _buildPageHeader(context, analysisState),
                  const SizedBox(height: AppSpacing.s24),

                  // ── Profile Form ──
                  FiscalProfileForm(
                    profile: profile,
                    onChange: (updated) => ref
                        .read(fiscalProfileProvider.notifier)
                        .update((_) => updated),
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  // ── Content based on state ──
                  if (analysisState.isLoading) _buildLoadingState(context),

                  if (analysisState.error != null)
                    _buildErrorState(context, analysisState.error!),

                  if (!analysisState.isLoading &&
                      analysisState.report == null &&
                      analysisState.error == null)
                    _buildEmptyState(context),

                  if (analysisState.report != null)
                    _buildAnalysisResults(context, analysisState.report!),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader(BuildContext context, FiscalAnalysisState state) {
    final isCompact = context.isCompact;

    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optimización Fiscal',
          style: (isCompact ? AppTypography.h3 : AppTypography.h2).copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Análisis fiscal automatizado \u00b7 España 2026',
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );

    final button = PrimaryButton(
      label: state.isLoading ? 'Analizando...' : 'Analizar',
      icon: LucideIcons.sparkles,
      onPressed: state.isLoading
          ? null
          : () => ref.read(fiscalAnalysisProvider.notifier).runAnalysis(),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleColumn,
          const SizedBox(height: AppSpacing.lg),
          button,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: titleColumn),
        button,
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s48),
      child: Center(
        child: Column(
          children: [
            Icon(
              LucideIcons.calculator,
              size: 48,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Configura tu perfil fiscal y pulsa Analizar\n'
              'para detectar oportunidades de ahorro',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s48),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.aiPurple,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Ejecutando análisis fiscal...',
              style: AppTypography.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Row(
          children: [
            Icon(
              LucideIcons.alertTriangle,
              size: 20,
              color: context.colors.statusError,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                error,
                style: AppTypography.body.copyWith(
                  color: context.colors.statusError,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults(
    BuildContext context,
    OptimizationReport report,
  ) {
    final savingsByTax = <TaxType, double>{};
    for (final opt in report.optimizations) {
      savingsByTax[opt.taxType] =
          (savingsByTax[opt.taxType] ?? 0) + opt.estimatedSaving;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── KPIs ──
        SavingsSummaryPanel(
          summary: report.summary,
          optimizations: report.optimizations,
        ),
        const SizedBox(height: AppSpacing.s24),

        // ── Chart + List (responsive) ──
        if (context.isExpanded)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TaxBreakdownChart(
                  savingsByTax: savingsByTax,
                  selectedTax: _selectedTax,
                  onTaxSelected: (t) => setState(() => _selectedTax = t),
                ).animate().fadeIn(duration: 400.ms),
              ),
              const SizedBox(width: AppSpacing.s20),
              Expanded(
                child: OptimizationsList(
                  optimizations: report.optimizations,
                  filterTax: _selectedTax,
                  onTap: (id) => context.go(RoutePaths.optimizationDetail(id)),
                ),
              ),
            ],
          )
        else ...[
          TaxBreakdownChart(
            savingsByTax: savingsByTax,
            selectedTax: _selectedTax,
            onTaxSelected: (t) => setState(() => _selectedTax = t),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppSpacing.s20),
          OptimizationsList(
            optimizations: report.optimizations,
            filterTax: _selectedTax,
            onTap: (id) => context.go(RoutePaths.optimizationDetail(id)),
          ),
        ],
      ],
    );
  }
}
