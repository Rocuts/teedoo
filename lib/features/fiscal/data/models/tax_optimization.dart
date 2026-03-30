import 'fiscal_rule.dart';

/// Estado del proceso de optimización fiscal.
enum OptimizationStatus { pending, inProgress, completed, error }

/// Optimización fiscal individual.
///
/// Representa una oportunidad de ahorro fiscal concreta, incluyendo
/// su estado, tipo de impuesto, ahorro estimado, y si ya ha sido
/// aplicada por el contribuyente.
class TaxOptimization {
  final String id;
  final String ruleId;
  final String title;
  final String description;
  final TaxType taxType;
  final double estimatedSaving;
  final RiskLevel riskLevel;
  final ConfidenceLevel confidenceLevel;
  final OptimizationStatus status;
  final String legalReference;
  final String? aiExplanation;
  final String? actionRequired;
  final bool isApplied;
  final DateTime? appliedAt;
  final DateTime createdAt;

  const TaxOptimization({
    required this.id,
    required this.ruleId,
    required this.title,
    required this.description,
    required this.taxType,
    required this.estimatedSaving,
    required this.riskLevel,
    required this.confidenceLevel,
    this.status = OptimizationStatus.pending,
    required this.legalReference,
    this.aiExplanation,
    this.actionRequired,
    this.isApplied = false,
    this.appliedAt,
    required this.createdAt,
  });

  /// Indica si la optimización es de bajo riesgo y alta confianza.
  bool get isSafeToApply =>
      riskLevel == RiskLevel.low && confidenceLevel == ConfidenceLevel.high;

  TaxOptimization copyWith({
    String? id,
    String? ruleId,
    String? title,
    String? description,
    TaxType? taxType,
    double? estimatedSaving,
    RiskLevel? riskLevel,
    ConfidenceLevel? confidenceLevel,
    OptimizationStatus? status,
    String? legalReference,
    String? aiExplanation,
    String? actionRequired,
    bool? isApplied,
    DateTime? appliedAt,
    DateTime? createdAt,
  }) {
    return TaxOptimization(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      title: title ?? this.title,
      description: description ?? this.description,
      taxType: taxType ?? this.taxType,
      estimatedSaving: estimatedSaving ?? this.estimatedSaving,
      riskLevel: riskLevel ?? this.riskLevel,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      status: status ?? this.status,
      legalReference: legalReference ?? this.legalReference,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      actionRequired: actionRequired ?? this.actionRequired,
      isApplied: isApplied ?? this.isApplied,
      appliedAt: appliedAt ?? this.appliedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
