import 'dart:math' as math;

import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Reserva de capitalización (Art. 25 LIS).
///
/// Reducción del 10% del incremento de fondos propios en la base
/// imponible, siempre que se dote una reserva indisponible durante
/// 5 años. No puede generar base imponible negativa.
class ReservaCapitalizacionRule implements IFiscalRule {
  /// Porcentaje de reducción sobre el incremento de fondos propios.
  static const double _porcentajeReduccion = 10.0;

  /// Años de indisponibilidad de la reserva.
  static const int _anosIndisponibilidad = 5;

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'sociedades_reserva_capitalizacion',
    name: 'Reserva de capitalización',
    description:
        'Reducción del 10% del incremento de fondos propios en la '
        'base imponible del IS. Requiere reserva indisponible 5 años.',
    taxType: TaxType.sociedades,
    legalReference: 'Art. 25 LIS',
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
        explanation:
            'No hay beneficio: la reducción no puede generar base negativa.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Estimamos el incremento de fondos propios como el beneficio retenido
    // (simplificación: en producción vendría de la contabilidad real)
    final incrementoFP = profit;
    final reduccion = incrementoFP * (_porcentajeReduccion / 100);

    // La reducción no puede superar la base imponible
    final reduccionEfectiva = math.min(reduccion, profit);

    // Ahorro = reducción * tipo IS (25%)
    final saving = reduccionEfectiva * 0.25;

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
          'Reducción del $_porcentajeReduccion% sobre incremento de '
          'fondos propios estimado en ${incrementoFP.toStringAsFixed(2)} EUR. '
          'Requiere dotar reserva indisponible $_anosIndisponibilidad años.',
      legalReference: metadata.legalReference,
      metadata: {
        'incrementoFondosPropios': incrementoFP,
        'reduccion': reduccionEfectiva,
        'porcentaje': _porcentajeReduccion,
        'anosIndisponibilidad': _anosIndisponibilidad,
      },
      evaluatedAt: now,
    );
  }
}
