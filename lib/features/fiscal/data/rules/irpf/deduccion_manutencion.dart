import 'dart:math' as math;

import '../../models/expense_classification.dart';
import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Deducción por gastos de manutención (Art. 19.2 LIRPF).
///
/// Los autónomos en estimación directa pueden deducir gastos de
/// manutención: 26,67 EUR/día en España y 48,08 EUR/día en el
/// extranjero. Requisito: pago electrónico y establecimiento de
/// hostelería o restauración.
class DeduccionManutencionRule implements IFiscalRule {
  /// Límite diario España.
  static const double _limiteDiaEspana = 26.67;

  /// Límite diario extranjero.
  static const double _limiteDiaExtranjero = 48.08;

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'irpf_deduccion_manutencion',
    name: 'Deducción gastos manutención',
    description:
        'Deducción de gastos de manutención: $_limiteDiaEspana EUR/día '
        'España, $_limiteDiaExtranjero EUR/día extranjero. '
        'Pago electrónico obligatorio.',
    taxType: TaxType.irpf,
    legalReference: 'Art. 19.2 LIRPF',
    contributorType: ContributorType.autonomo,
    fiscalYearFrom: 2018,
    defaultRisk: RiskLevel.low,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

    if (!context.profile.isAutonomo || !context.profile.isEstimacionDirecta) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: false,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'No aplica: solo para autónomos en estimación directa.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Buscar gastos de dietas y viajes
    final dietExpenses = context.expenseClassifications
        .where(
          (e) =>
              e.category == ExpenseCategory.dietas ||
              e.category == ExpenseCategory.viajes,
        )
        .toList();

    if (dietExpenses.isEmpty) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.medium,
        explanation:
            'Aplica pero no se detectan gastos de manutención/dietas '
            'en el período.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    final totalDietas = dietExpenses.fold(
      0.0,
      (sum, e) => sum + e.deductibleAmount + e.nonDeductibleAmount,
    );

    // Estimar días de actividad con dietas (aprox por importe)
    final diasEstimados = (totalDietas / _limiteDiaEspana).ceil();
    final limiteDeducible = diasEstimados * _limiteDiaEspana;
    final deducible = math.min(totalDietas, limiteDeducible);

    final confidenceLevel = dietExpenses.length >= 5
        ? ConfidenceLevel.high
        : ConfidenceLevel.medium;

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: deducible,
      riskLevel: RiskLevel.low,
      confidenceLevel: confidenceLevel,
      explanation:
          'Gasto deducible en manutención: ${deducible.toStringAsFixed(2)} EUR. '
          'Basado en ${dietExpenses.length} facturas, '
          'estimados $diasEstimados días de actividad. '
          'Límite: $_limiteDiaEspana EUR/día (España).',
      legalReference: metadata.legalReference,
      metadata: {
        'totalDietas': totalDietas,
        'diasEstimados': diasEstimados,
        'limiteDeducible': limiteDeducible,
        'deducible': deducible,
        'invoiceCount': dietExpenses.length,
      },
      evaluatedAt: now,
    );
  }
}
