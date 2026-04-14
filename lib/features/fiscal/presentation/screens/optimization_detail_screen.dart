import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/fiscal_explanation_service.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/navigation/app_topbar.dart';
import '../../data/models/fiscal_profile.dart';
import '../../data/models/fiscal_rule.dart';
import '../../data/models/optimization_report.dart';
import '../../data/models/tax_optimization.dart';
import '../../providers/fiscal_provider.dart';
import '../widgets/ai_explanation_card.dart';

/// Pantalla de detalle de una optimización fiscal.
class OptimizationDetailScreen extends ConsumerStatefulWidget {
  final String optimizationId;

  const OptimizationDetailScreen({super.key, required this.optimizationId});

  @override
  ConsumerState<OptimizationDetailScreen> createState() =>
      _OptimizationDetailScreenState();
}

class _OptimizationDetailScreenState
    extends ConsumerState<OptimizationDetailScreen> {
  bool _isGenerating = false;

  TaxOptimization? _findOptimization(FiscalAnalysisState state) {
    if (state.report == null) return null;
    try {
      return state.report!.optimizations.firstWhere(
        (o) => o.id == widget.optimizationId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _generateExplanation(TaxOptimization opt) async {
    setState(() => _isGenerating = true);

    try {
      final profile = ref.read(fiscalProfileProvider);

      // Llamar al servicio de explicaciones (OpenAI con validación)
      FiscalExplanationService? service;
      try {
        service = ref.read(fiscalExplanationServiceProvider);
      } catch (_) {}

      String? explanation;

      if (service != null) {
        explanation = await service.explain(
          ruleName: opt.title,
          ruleExplanation: opt.description,
          legalReference: opt.legalReference,
          estimatedSaving: opt.estimatedSaving,
          fiscalYear: profile.fiscalYear,
          autonomousCommunity: profile.autonomousCommunity,
          confidenceLevel: opt.confidenceLevel.name,
          riskLevel: opt.riskLevel.name,
          actionRequired: opt.actionRequired,
        );
      }

      // Fallback: justificación local si OpenAI no responde
      explanation ??= _buildLocalFallback(opt, profile);

      // Actualizar la optimización en el estado del provider
      final state = ref.read(fiscalAnalysisProvider);
      final report = state.report;
      if (report != null) {
        final updatedOpts = report.optimizations.map((o) {
          if (o.id == opt.id) return o.copyWith(aiExplanation: explanation);
          return o;
        }).toList();

        final updatedReport = OptimizationReport(
          id: report.id,
          userId: report.userId,
          fiscalYear: report.fiscalYear,
          summary: report.summary,
          evaluations: report.evaluations,
          optimizations: updatedOpts,
          generatedAt: report.generatedAt,
          processingTime: report.processingTime,
        );

        ref.read(fiscalAnalysisProvider.notifier).setReport(updatedReport);
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  String _buildLocalFallback(TaxOptimization opt, FiscalProfile profile) {
    final saving = opt.estimatedSaving.toStringAsFixed(2);
    final form = profile.legalForm == LegalForm.autonomo
        ? 'autónomo persona física'
        : 'sociedad';
    return '''Se ha detectado una oportunidad de ahorro fiscal de $saving EUR aplicable a su situación como $form.

Fundamento legal: ${opt.legalReference}. ${opt.description}

${opt.actionRequired ?? 'Consulte con su asesor fiscal la aplicación de esta deducción.'}

Este análisis es orientativo y no sustituye el asesoramiento fiscal profesional.''';
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(fiscalAnalysisProvider);
    final optimization = _findOptimization(analysisState);

    if (optimization == null) {
      return Column(
        children: [
          AppTopbar(
            breadcrumbs: [
              BreadcrumbItem(
                label: 'Fiscal',
                onTap: () => context.go(RoutePaths.fiscal),
              ),
              const BreadcrumbItem(label: 'No encontrada'),
            ],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.searchX,
                    size: 48,
                    color: context.colors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Optimización no encontrada',
                    style: AppTypography.body.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SecondaryButton(
                    label: 'Volver',
                    icon: LucideIcons.arrowLeft,
                    onPressed: () => context.go(RoutePaths.fiscal),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        AppTopbar(
          breadcrumbs: [
            BreadcrumbItem(
              label: 'Fiscal',
              onTap: () => context.go(RoutePaths.fiscal),
            ),
            BreadcrumbItem(
              label: 'Optimización',
              onTap: () => context.go(RoutePaths.fiscal),
            ),
            BreadcrumbItem(label: optimization.title),
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
                  _buildHeader(context, optimization),
                  const SizedBox(height: AppSpacing.s24),

                  // ── Content ──
                  if (context.isExpanded)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildMainColumn(context, optimization),
                        ),
                        const SizedBox(width: AppSpacing.s20),
                        Expanded(child: _buildSidebar(context, optimization)),
                      ],
                    )
                  else ...[
                    _buildMainColumn(context, optimization),
                    const SizedBox(height: AppSpacing.s20),
                    _buildSidebar(context, optimization),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, TaxOptimization optimization) {
    final isCompact = context.isCompact;

    final confidenceBadge = switch (optimization.confidenceLevel) {
      ConfidenceLevel.high => const StatusBadge(
        label: 'Confirmada',
        type: StatusType.success,
      ),
      ConfidenceLevel.medium => const StatusBadge(
        label: 'Probable',
        type: StatusType.info,
      ),
      ConfidenceLevel.low => const StatusBadge(
        label: 'Posible',
        type: StatusType.warning,
      ),
    };

    final riskBadge = switch (optimization.riskLevel) {
      RiskLevel.low => const StatusBadge(
        label: 'Bajo riesgo',
        type: StatusType.success,
      ),
      RiskLevel.medium => const StatusBadge(
        label: 'Riesgo medio',
        type: StatusType.warning,
      ),
      RiskLevel.high => const StatusBadge(
        label: 'Alto riesgo',
        type: StatusType.error,
      ),
      RiskLevel.critical => const StatusBadge(
        label: 'Crítico',
        type: StatusType.error,
      ),
    };

    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          optimization.title,
          style: (isCompact ? AppTypography.h3 : AppTypography.h2).copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            _buildTaxBadge(context, optimization.taxType),
            confidenceBadge,
            riskBadge,
          ],
        ),
      ],
    );

    final backButton = SecondaryButton(
      label: 'Volver',
      icon: LucideIcons.arrowLeft,
      onPressed: () => context.go(RoutePaths.fiscal),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          backButton,
          const SizedBox(height: AppSpacing.lg),
          titleSection,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleSection),
        const SizedBox(width: AppSpacing.lg),
        backButton,
      ],
    );
  }

  Widget _buildMainColumn(BuildContext context, TaxOptimization optimization) {
    return Column(
      children: [
        // ── Analysis ──
        _buildAnalysisCard(
          context,
          optimization,
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.03),
        const SizedBox(height: AppSpacing.s20),

        // ── Legal basis ──
        _buildLegalCard(
          context,
          optimization,
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.03),
        const SizedBox(height: AppSpacing.s20),

        // ── AI Explanation ──
        AiExplanationCard(
          optimization: optimization,
          isGenerating: _isGenerating,
          onGenerate: () => _generateExplanation(optimization),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.03),
      ],
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context,
    TaxOptimization optimization,
  ) {
    final colors = context.colors;

    // Description serves as conditions overview
    return GlassCard(
      header: const GlassCardHeader(title: 'Análisis Detallado'),
      content: GlassCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description as main analysis
            Text(
              optimization.description,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Conditions met
            Row(
              children: [
                Icon(
                  LucideIcons.checkCircle,
                  size: 16,
                  color: colors.statusSuccess,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Condiciones cumplidas',
                  style: AppTypography.bodySmallMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildConditionItem(
              context,
              icon: LucideIcons.checkCircle,
              color: colors.statusSuccess,
              text: 'Perfil fiscal compatible con la deducción',
            ),
            _buildConditionItem(
              context,
              icon: LucideIcons.checkCircle,
              color: colors.statusSuccess,
              text: 'Ejercicio fiscal ${DateTime.now().year} vigente',
            ),
            if (optimization.confidenceLevel == ConfidenceLevel.high)
              _buildConditionItem(
                context,
                icon: LucideIcons.checkCircle,
                color: colors.statusSuccess,
                text: 'Alta confianza en la evaluación',
              ),

            // Action required
            if (optimization.actionRequired != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 16,
                    color: colors.statusWarning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Acción requerida',
                    style: AppTypography.bodySmallMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.statusWarningBg,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: colors.statusWarning.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  optimization.actionRequired!,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConditionItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.s24),
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalCard(BuildContext context, TaxOptimization optimization) {
    final colors = context.colors;

    return GlassCard(
      header: const GlassCardHeader(title: 'Base Normativa'),
      content: GlassCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.scale, size: 16, color: colors.accentBlue),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    optimization.legalReference,
                    style: AppTypography.bodySmallMedium.copyWith(
                      color: colors.accentBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Esta optimización se basa en la normativa fiscal vigente. '
              'La referencia legal indicada establece las condiciones '
              'para la aplicación de esta deducción o beneficio fiscal.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, TaxOptimization optimization) {
    return Column(
      children: [
        // ── Savings ──
        _buildSavingsCard(
          context,
          optimization,
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.03),
        const SizedBox(height: AppSpacing.s20),

        // ── Traceability ──
        _buildTraceabilityCard(
          context,
          optimization,
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.03),
      ],
    );
  }

  Widget _buildSavingsCard(BuildContext context, TaxOptimization optimization) {
    final colors = context.colors;

    return GlassCard(
      header: const GlassCardHeader(title: 'Ahorro Estimado'),
      content: GlassCardContent(
        child: Center(
          child: Column(
            children: [
              Text(
                _formatCurrency(optimization.estimatedSaving),
                style: AppTypography.h1.copyWith(
                  color: colors.accentBlue,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ahorro potencial estimado',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTraceabilityCard(
    BuildContext context,
    TaxOptimization optimization,
  ) {
    return GlassCard(
      header: const GlassCardHeader(title: 'Trazabilidad'),
      content: GlassCardContent(
        child: Column(
          children: [
            _traceRow(context, 'Regla', optimization.ruleId),
            _traceRow(context, 'Título', optimization.title),
            _traceRow(
              context,
              'Confianza',
              switch (optimization.confidenceLevel) {
                ConfidenceLevel.high => 'Alta',
                ConfidenceLevel.medium => 'Media',
                ConfidenceLevel.low => 'Baja',
              },
            ),
            _traceRow(context, 'Riesgo', switch (optimization.riskLevel) {
              RiskLevel.low => 'Bajo',
              RiskLevel.medium => 'Medio',
              RiskLevel.high => 'Alto',
              RiskLevel.critical => 'Crítico',
            }),
            _traceRow(
              context,
              'Creada',
              _formatDateTime(optimization.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _traceRow(BuildContext context, String label, String value) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(color: colors.textTertiary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxBadge(BuildContext context, TaxType type) {
    final (label, color) = switch (type) {
      TaxType.irpf => ('IRPF', context.colors.statusSuccess),
      TaxType.iva => ('IVA', context.colors.accentBlue),
      TaxType.sociedades => ('IS', context.colors.statusWarning),
      _ => ('Otro', context.colors.textTertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.captionBold.copyWith(color: color),
      ),
    );
  }

  static String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
      buffer.write(intPart[i]);
    }
    return '$buffer,$decPart \u20ac';
  }

  static String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
