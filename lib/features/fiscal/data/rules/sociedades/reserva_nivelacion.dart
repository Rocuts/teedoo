import 'dart:math' as math;

import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Reserva de nivelación (Art. 105 LIS).
///
/// Reducción de hasta el 10% de la base imponible con un máximo
/// de 1.000.000 EUR. Solo para ERD (entidades de reducida dimensión,
/// cifra de negocios < 10M EUR). Se revierte en 5 años si no se
/// compensan bases negativas.
class ReservaNivelacionRule implements IFiscalRule {
  /// Porcentaje máximo de reducción sobre la BI.
  static const double _porcentajeMax = 10.0;

  /// Importe máximo de la reserva.
  static const double _importeMax = 1000000.0;

  /// Umbral de cifra de negocios para ERD.
  static const double _umbralERD = 10000000.0;

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'sociedades_reserva_nivelacion',
    name: 'Reserva de nivelación',
    description:
        'Reducción de hasta el 10% de la BI (máx. 1M EUR) para '
        'entidades de reducida dimensión. Reversión en 5 años.',
    taxType: TaxType.sociedades,
    legalReference: 'Art. 105 LIS',
    contributorType: ContributorType.sociedad,
    fiscalYearFrom: 2015,
    defaultRisk: RiskLevel.medium,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

    if (context.profile.isAutonomo) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: false,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'No aplica: solo para sociedades.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    final revenue = context.totalRevenue;
    if (revenue >= _umbralERD) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: false,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation:
            'No aplica: cifra de negocios (${revenue.toStringAsFixed(2)} EUR) '
            'supera el umbral ERD de $_umbralERD EUR.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    final profit = context.estimatedProfit;
    if (profit <= 0) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'Base imponible negativa: no se puede aplicar reserva.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    final reduccion = math.min(profit * (_porcentajeMax / 100), _importeMax);
    final saving = reduccion * 0.25;

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: math.max(0, saving),
      riskLevel: RiskLevel.medium,
      confidenceLevel: ConfidenceLevel.medium,
      explanation:
          'Ahorro estimado: ${saving.toStringAsFixed(2)} EUR. '
          'Reducción de ${reduccion.toStringAsFixed(2)} EUR '
          '($_porcentajeMax% de BI, máx. $_importeMax EUR). '
          'Se revierte en 5 años si no se compensan bases negativas.',
      legalReference: metadata.legalReference,
      metadata: {
        'cifraNegocios': revenue,
        'baseImponible': profit,
        'reduccion': reduccion,
        'porcentajeMax': _porcentajeMax,
        'importeMax': _importeMax,
      },
      evaluatedAt: now,
    );
  }
}
