import '../data/models/fiscal_rule.dart';
import '../data/models/rule_evaluation.dart';

/// Calculadora de riesgo y confianza para evaluaciones fiscales.
///
/// Proporciona métodos estáticos para calcular el nivel de riesgo
/// agregado y la confianza global de un conjunto de evaluaciones.
class RiskScorer {
  RiskScorer._();

  /// Pesos numéricos para cada nivel de riesgo.
  static const Map<RiskLevel, int> _riskWeights = {
    RiskLevel.low: 1,
    RiskLevel.medium: 3,
    RiskLevel.high: 7,
    RiskLevel.critical: 10,
  };

  /// Pesos numéricos para cada nivel de confianza.
  static const Map<ConfidenceLevel, int> _confidenceWeights = {
    ConfidenceLevel.high: 3,
    ConfidenceLevel.medium: 2,
    ConfidenceLevel.low: 1,
  };

  /// Calcula el nivel de riesgo agregado de un conjunto de evaluaciones.
  ///
  /// Pondera el riesgo de cada evaluación que aplica y tiene ahorro,
  /// por el ahorro estimado, y retorna el nivel de riesgo resultante.
  static RiskLevel computeRisk(List<RuleEvaluation> evaluations) {
    final applicable = evaluations.where((e) => e.applies).toList();

    if (applicable.isEmpty) return RiskLevel.low;

    // Si alguna evaluación es crítica, el riesgo global es crítico
    if (applicable.any((e) => e.riskLevel == RiskLevel.critical)) {
      return RiskLevel.critical;
    }

    // Calcular riesgo ponderado por ahorro
    double totalWeight = 0;
    double weightedRisk = 0;

    for (final eval in applicable) {
      final saving = eval.estimatedSaving.abs();
      final weight = saving > 0 ? saving : 1.0;
      final riskValue = _riskWeights[eval.riskLevel] ?? 1;

      weightedRisk += riskValue * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) return RiskLevel.low;

    final averageRisk = weightedRisk / totalWeight;

    if (averageRisk >= 7) return RiskLevel.critical;
    if (averageRisk >= 4) return RiskLevel.high;
    if (averageRisk >= 2) return RiskLevel.medium;
    return RiskLevel.low;
  }

  /// Calcula el nivel de confianza agregado de un conjunto de evaluaciones.
  ///
  /// Retorna el nivel de confianza mínimo entre todas las evaluaciones
  /// que aplican y tienen ahorro, ponderado por el ahorro.
  static ConfidenceLevel computeConfidence(List<RuleEvaluation> evaluations) {
    final withSaving = evaluations.where((e) => e.hasSaving).toList();

    if (withSaving.isEmpty) return ConfidenceLevel.high;

    double totalWeight = 0;
    double weightedConfidence = 0;

    for (final eval in withSaving) {
      final saving = eval.estimatedSaving.abs();
      final weight = saving > 0 ? saving : 1.0;
      final confValue = _confidenceWeights[eval.confidenceLevel] ?? 1;

      weightedConfidence += confValue * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) return ConfidenceLevel.high;

    final averageConfidence = weightedConfidence / totalWeight;

    if (averageConfidence >= 2.5) return ConfidenceLevel.high;
    if (averageConfidence >= 1.5) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }

  /// Calcula una puntuación de riesgo numérica (0-100) para una evaluación.
  ///
  /// 0 = sin riesgo, 100 = riesgo máximo.
  static double computeRiskScore(RuleEvaluation evaluation) {
    final riskValue = _riskWeights[evaluation.riskLevel] ?? 1;
    final confidenceValue = _confidenceWeights[evaluation.confidenceLevel] ?? 1;

    // Mayor riesgo y menor confianza = mayor puntuación
    final riskFactor = riskValue / 10.0;
    final confidenceFactor = 1.0 - (confidenceValue / 3.0);

    return ((riskFactor * 0.7 + confidenceFactor * 0.3) * 100).clamp(
      0.0,
      100.0,
    );
  }
}
