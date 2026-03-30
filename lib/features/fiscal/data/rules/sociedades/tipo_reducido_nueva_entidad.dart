import 'dart:math' as math;

import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Tipo reducido del 15% para entidades de nueva creación.
///
/// Art. 29.1 LIS: Las entidades de nueva creación tributan al 15%
/// durante el primer período impositivo en que la base imponible
/// resulte positiva y en el siguiente.
class TipoReducidoNuevaEntidadRule implements IFiscalRule {
  /// Tipo general del Impuesto de Sociedades.
  static const double _tipoGeneral = 25.0;

  /// Tipo reducido para nuevas entidades.
  static const double _tipoReducido = 15.0;

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'sociedades_tipo_reducido_nueva_entidad',
    name: 'Tipo reducido 15% nueva entidad',
    description:
        'Las entidades de nueva creación tributan al 15% durante '
        'el primer período con base imponible positiva y el siguiente.',
    taxType: TaxType.sociedades,
    legalReference: 'Art. 29.1 LIS',
    contributorType: ContributorType.sociedad,
    fiscalYearFrom: 2015,
    defaultRisk: RiskLevel.low,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

    // Solo aplica a sociedades
    if (context.profile.isAutonomo) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: false,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'No aplica: solo para sociedades de nueva creación.',
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
            'Base imponible negativa: no hay cuota sobre la que aplicar '
            'el tipo reducido.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Ahorro = diferencia entre tipo general y reducido sobre el beneficio
    const savingRate = _tipoGeneral - _tipoReducido;
    final estimatedSaving = profit * (savingRate / 100);

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: math.max(0, estimatedSaving),
      riskLevel: RiskLevel.low,
      confidenceLevel: ConfidenceLevel.medium,
      explanation:
          'Ahorro estimado: ${estimatedSaving.toStringAsFixed(2)} EUR. '
          'Diferencia entre tipo general ($_tipoGeneral%) y reducido '
          '($_tipoReducido%) sobre beneficio de '
          '${profit.toStringAsFixed(2)} EUR.',
      legalReference: metadata.legalReference,
      metadata: {
        'tipoGeneral': _tipoGeneral,
        'tipoReducido': _tipoReducido,
        'baseImponible': profit,
        'estimatedSaving': estimatedSaving,
      },
      evaluatedAt: now,
    );
  }
}
