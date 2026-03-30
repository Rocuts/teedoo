import 'fiscal_rule.dart';
import 'rule_evaluation.dart';
import 'tax_optimization.dart';

/// Resumen ejecutivo del informe de optimización.
class ReportSummary {
  final double totalEstimatedSaving;
  final double irpfSaving;
  final double ivaSaving;
  final int rulesEvaluated;
  final int rulesApplicable;
  final int highConfidenceCount;
  final int lowRiskCount;
  final RiskLevel overallRisk;

  const ReportSummary({
    required this.totalEstimatedSaving,
    required this.irpfSaving,
    required this.ivaSaving,
    required this.rulesEvaluated,
    required this.rulesApplicable,
    required this.highConfidenceCount,
    required this.lowRiskCount,
    required this.overallRisk,
  });

  /// Porcentaje de reglas que aplican sobre el total evaluado.
  double get applicabilityRate =>
      rulesEvaluated > 0 ? rulesApplicable / rulesEvaluated * 100 : 0;

  ReportSummary copyWith({
    double? totalEstimatedSaving,
    double? irpfSaving,
    double? ivaSaving,
    int? rulesEvaluated,
    int? rulesApplicable,
    int? highConfidenceCount,
    int? lowRiskCount,
    RiskLevel? overallRisk,
  }) {
    return ReportSummary(
      totalEstimatedSaving: totalEstimatedSaving ?? this.totalEstimatedSaving,
      irpfSaving: irpfSaving ?? this.irpfSaving,
      ivaSaving: ivaSaving ?? this.ivaSaving,
      rulesEvaluated: rulesEvaluated ?? this.rulesEvaluated,
      rulesApplicable: rulesApplicable ?? this.rulesApplicable,
      highConfidenceCount: highConfidenceCount ?? this.highConfidenceCount,
      lowRiskCount: lowRiskCount ?? this.lowRiskCount,
      overallRisk: overallRisk ?? this.overallRisk,
    );
  }
}

/// Informe completo de optimización fiscal.
///
/// Contiene el resumen ejecutivo, todas las evaluaciones de reglas,
/// las optimizaciones concretas, y metadatos del informe.
class OptimizationReport {
  final String id;
  final String userId;
  final int fiscalYear;
  final ReportSummary summary;
  final List<RuleEvaluation> evaluations;
  final List<TaxOptimization> optimizations;
  final DateTime generatedAt;
  final Duration processingTime;

  const OptimizationReport({
    required this.id,
    required this.userId,
    required this.fiscalYear,
    required this.summary,
    required this.evaluations,
    required this.optimizations,
    required this.generatedAt,
    required this.processingTime,
  });

  /// Evaluaciones que aplican y tienen ahorro.
  List<RuleEvaluation> get applicableEvaluations =>
      evaluations.where((e) => e.hasSaving).toList();

  /// Optimizaciones ordenadas por ahorro estimado descendente.
  List<TaxOptimization> get optimizationsByImpact =>
      List.of(optimizations)
        ..sort((a, b) => b.estimatedSaving.compareTo(a.estimatedSaving));

  /// Optimizaciones seguras (bajo riesgo, alta confianza).
  List<TaxOptimization> get safeOptimizations =>
      optimizations.where((o) => o.isSafeToApply).toList();

  OptimizationReport copyWith({
    String? id,
    String? userId,
    int? fiscalYear,
    ReportSummary? summary,
    List<RuleEvaluation>? evaluations,
    List<TaxOptimization>? optimizations,
    DateTime? generatedAt,
    Duration? processingTime,
  }) {
    return OptimizationReport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fiscalYear: fiscalYear ?? this.fiscalYear,
      summary: summary ?? this.summary,
      evaluations: evaluations ?? this.evaluations,
      optimizations: optimizations ?? this.optimizations,
      generatedAt: generatedAt ?? this.generatedAt,
      processingTime: processingTime ?? this.processingTime,
    );
  }
}
