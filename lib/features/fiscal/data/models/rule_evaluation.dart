import 'fiscal_rule.dart';

/// Resultado de la evaluación de una regla fiscal contra un contexto.
///
/// Contiene si la regla aplica, el ahorro estimado, nivel de riesgo,
/// nivel de confianza, y una explicación textual del resultado.
class RuleEvaluation {
  final String ruleId;
  final String ruleName;
  final TaxType taxType;
  final bool applies;
  final double estimatedSaving;
  final RiskLevel riskLevel;
  final ConfidenceLevel confidenceLevel;
  final String explanation;
  final String legalReference;
  final String? aiExplanation;
  final Map<String, dynamic> metadata;
  final DateTime evaluatedAt;

  const RuleEvaluation({
    required this.ruleId,
    required this.ruleName,
    required this.taxType,
    required this.applies,
    required this.estimatedSaving,
    required this.riskLevel,
    required this.confidenceLevel,
    required this.explanation,
    required this.legalReference,
    this.aiExplanation,
    this.metadata = const {},
    required this.evaluatedAt,
  });

  /// Indica si la evaluación ha identificado un ahorro positivo.
  bool get hasSaving => applies && estimatedSaving > 0;

  /// Indica si es una evaluación de alto riesgo.
  bool get isHighRisk =>
      riskLevel == RiskLevel.high || riskLevel == RiskLevel.critical;

  RuleEvaluation copyWith({
    String? ruleId,
    String? ruleName,
    TaxType? taxType,
    bool? applies,
    double? estimatedSaving,
    RiskLevel? riskLevel,
    ConfidenceLevel? confidenceLevel,
    String? explanation,
    String? legalReference,
    String? aiExplanation,
    Map<String, dynamic>? metadata,
    DateTime? evaluatedAt,
  }) {
    return RuleEvaluation(
      ruleId: ruleId ?? this.ruleId,
      ruleName: ruleName ?? this.ruleName,
      taxType: taxType ?? this.taxType,
      applies: applies ?? this.applies,
      estimatedSaving: estimatedSaving ?? this.estimatedSaving,
      riskLevel: riskLevel ?? this.riskLevel,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      explanation: explanation ?? this.explanation,
      legalReference: legalReference ?? this.legalReference,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      metadata: metadata ?? this.metadata,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
    );
  }
}
