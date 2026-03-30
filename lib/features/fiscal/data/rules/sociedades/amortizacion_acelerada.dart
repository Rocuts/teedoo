import 'dart:math' as math;

import '../../models/expense_classification.dart';
import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Amortización acelerada para pymes (Art. 103 LIS).
///
/// Las ERD (cifra de negocios < 10M EUR) pueden aplicar el doble
/// del coeficiente lineal máximo de amortización (coeficiente x2).
/// Aplica a elementos nuevos del inmovilizado material e intangible.
class AmortizacionAceleradaRule implements IFiscalRule {
  /// Multiplicador de amortización para pymes.
  static const double _multiplicador = 2.0;

  /// Umbral de cifra de negocios para ERD.
  static const double _umbralERD = 10000000.0;

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'sociedades_amortizacion_acelerada',
    name: 'Amortización acelerada pymes',
    description:
        'Las ERD pueden amortizar al doble del coeficiente lineal '
        'máximo (x2) los elementos nuevos del inmovilizado.',
    taxType: TaxType.sociedades,
    legalReference: 'Art. 103 LIS',
    contributorType: ContributorType.ambos,
    fiscalYearFrom: 2015,
    defaultRisk: RiskLevel.low,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

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

    // Detectar gastos amortizables (amortización, software, equipos)
    final amortizableExpenses = context.expenseClassifications
        .where(
          (e) =>
              e.category == ExpenseCategory.amortizacion ||
              e.category == ExpenseCategory.software,
        )
        .toList();

    if (amortizableExpenses.isEmpty) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.medium,
        explanation:
            'Aplica pero no se detectan gastos de inmovilizado amortizable '
            'en el período.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Estimación: la amortización acelerada adelanta gasto fiscal
    // Ahorro diferido = base amortizable * coeficiente adicional * tipo IS
    final totalAmortizable = amortizableExpenses.fold(
      0.0,
      (sum, e) => sum + e.deductibleAmount + e.nonDeductibleAmount,
    );

    // Estimamos un coeficiente base del 20% (equipos informáticos)
    // La aceleración permite el doble → 20% extra deducible este año
    final amortizacionExtra = totalAmortizable * 0.20;
    final tipoIS = context.profile.isAutonomo ? 0.30 : 0.25;
    final saving = amortizacionExtra * tipoIS;

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: math.max(0, saving),
      riskLevel: RiskLevel.low,
      confidenceLevel: ConfidenceLevel.medium,
      explanation:
          'Ahorro estimado: ${saving.toStringAsFixed(2)} EUR. '
          'Amortización acelerada (x$_multiplicador) sobre '
          '${totalAmortizable.toStringAsFixed(2)} EUR de activos '
          'amortizables (${amortizableExpenses.length} partidas).',
      legalReference: metadata.legalReference,
      metadata: {
        'totalAmortizable': totalAmortizable,
        'amortizacionExtra': amortizacionExtra,
        'multiplicador': _multiplicador,
        'partidasCount': amortizableExpenses.length,
      },
      evaluatedAt: now,
    );
  }
}
