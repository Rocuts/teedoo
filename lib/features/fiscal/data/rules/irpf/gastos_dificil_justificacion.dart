import 'dart:math' as math;

import '../../models/fiscal_profile.dart';
import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Gastos de difícil justificación (Art. 30.2.4 LIRPF).
///
/// En estimación directa simplificada se puede deducir un 5% del
/// rendimiento neto positivo como gastos de difícil justificación,
/// con un máximo de 2.000 EUR anuales.
class GastosDificilJustificacionRule implements IFiscalRule {
  /// Porcentaje aplicable sobre el rendimiento neto.
  static const double _porcentaje = 5.0;

  /// Importe máximo anual.
  static const double _importeMax = 2000.0;

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'irpf_gastos_dificil_justificacion',
    name: 'Gastos de difícil justificación 5%',
    description:
        'Deducción del 5% del rendimiento neto (máx. 2.000 EUR) '
        'en estimación directa simplificada.',
    taxType: TaxType.irpf,
    legalReference: 'Art. 30.2.4 LIRPF',
    contributorType: ContributorType.autonomo,
    fiscalYearFrom: 2018,
    defaultRisk: RiskLevel.low,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

    if (!context.profile.isAutonomo) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: false,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'No aplica: solo para autónomos.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Solo en estimación directa simplificada
    if (context.profile.fiscalRegime !=
        FiscalRegime.estimacionDirectaSimplificada) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: false,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'No aplica: solo en estimación directa simplificada.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    final rendimientoNeto = context.estimatedProfit;
    if (rendimientoNeto <= 0) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'Rendimiento neto negativo: no se genera deducción.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    final deduccion = math.min(
      rendimientoNeto * (_porcentaje / 100),
      _importeMax,
    );

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: deduccion,
      riskLevel: RiskLevel.low,
      confidenceLevel: ConfidenceLevel.high,
      explanation:
          'Deducción automática: ${deduccion.toStringAsFixed(2)} EUR. '
          '$_porcentaje% del rendimiento neto '
          '(${rendimientoNeto.toStringAsFixed(2)} EUR), '
          'máximo $_importeMax EUR/año. Se aplica sin necesidad de '
          'justificación documental.',
      legalReference: metadata.legalReference,
      metadata: {
        'rendimientoNeto': rendimientoNeto,
        'porcentaje': _porcentaje,
        'deduccion': deduccion,
        'importeMax': _importeMax,
      },
      evaluatedAt: now,
    );
  }
}
