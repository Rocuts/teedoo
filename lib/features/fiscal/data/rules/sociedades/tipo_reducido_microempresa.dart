import 'dart:math' as math;

import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Tipo reducido para microempresas (DA 12 LIS).
///
/// DA 12 LIS (vigente 2026): Sociedades con cifra de negocios
/// inferior a 1.000.000 EUR tributan al 19% sobre los primeros
/// 50.000 EUR de base imponible y al 21% por el resto.
class TipoReducidoMicroempresaRule implements IFiscalRule {
  /// Umbral de cifra de negocios para microempresa.
  static const double _umbralCifraNegocios = 1000000.0;

  /// Tipo general del IS.
  static const double _tipoGeneral = 25.0;

  /// Tipo reducido tramo 1 (hasta 50.000 EUR).
  static const double _tipoTramo1 = 19.0;

  /// Tipo reducido tramo 2 (resto).
  static const double _tipoTramo2 = 21.0;

  /// Límite del primer tramo.
  static const double _limiteTramo1 = 50000.0;

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'sociedades_tipo_reducido_microempresa',
    name: 'Tipo reducido microempresa DA 12 LIS',
    description:
        'Sociedades con cifra de negocios < 1M EUR tributan al '
        '19% (primeros 50.000 EUR) y 21% (resto) en 2026.',
    taxType: TaxType.sociedades,
    legalReference: 'DA 12 LIS',
    contributorType: ContributorType.sociedad,
    fiscalYearFrom: 2023,
    defaultRisk: RiskLevel.low,
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
    if (revenue >= _umbralCifraNegocios) {
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
            'supera el umbral de $_umbralCifraNegocios EUR.',
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
        explanation: 'Base imponible negativa: no hay cuota.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Cuota con tipo general
    final cuotaGeneral = profit * (_tipoGeneral / 100);

    // Cuota con tipo reducido microempresa
    final baseTramo1 = math.min(profit, _limiteTramo1);
    final baseTramo2 = math.max(0.0, profit - _limiteTramo1);
    final cuotaReducida =
        baseTramo1 * (_tipoTramo1 / 100) + baseTramo2 * (_tipoTramo2 / 100);

    final saving = cuotaGeneral - cuotaReducida;

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: math.max(0, saving),
      riskLevel: RiskLevel.low,
      confidenceLevel: ConfidenceLevel.high,
      explanation:
          'Ahorro estimado: ${saving.toStringAsFixed(2)} EUR. '
          'Cuota general (25%): ${cuotaGeneral.toStringAsFixed(2)} EUR vs '
          'cuota reducida (19%/21%): ${cuotaReducida.toStringAsFixed(2)} EUR '
          'sobre beneficio de ${profit.toStringAsFixed(2)} EUR.',
      legalReference: metadata.legalReference,
      metadata: {
        'cifraNegocios': revenue,
        'baseImponible': profit,
        'cuotaGeneral': cuotaGeneral,
        'cuotaReducida': cuotaReducida,
        'baseTramo1': baseTramo1,
        'baseTramo2': baseTramo2,
      },
      evaluatedAt: now,
    );
  }
}
