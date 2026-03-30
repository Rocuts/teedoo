import 'dart:math' as math;

import '../../models/expense_classification.dart';
import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Deducción por seguro de enfermedad (Art. 30.2.5 LIRPF).
///
/// Los autónomos en estimación directa pueden deducir las primas
/// de seguro de enfermedad del titular, cónyuge e hijos menores
/// de 25 años. Límite: 500 EUR por persona/año (1.500 EUR si
/// discapacidad ≥ 33%).
class DeduccionSeguroEnfermedadRule implements IFiscalRule {
  /// Límite por persona y año.
  static const double _limitePersona = 500.0;

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'irpf_deduccion_seguro_enfermedad',
    name: 'Deducción seguro enfermedad',
    description:
        'Deducción de primas de seguro de enfermedad: '
        '$_limitePersona EUR/persona/año para autónomos.',
    taxType: TaxType.irpf,
    legalReference: 'Art. 30.2.5 LIRPF',
    contributorType: ContributorType.autonomo,
    fiscalYearFrom: 2015,
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

    // Buscar gastos de seguros
    final insuranceExpenses = context.expenseClassifications
        .where((e) => e.category == ExpenseCategory.seguros)
        .toList();

    if (insuranceExpenses.isEmpty) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: _limitePersona,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.low,
        explanation:
            'Oportunidad: puede deducir hasta $_limitePersona EUR/persona/año '
            'en seguro de enfermedad. No se detectan gastos de seguros, '
            'considere contratar uno.',
        legalReference: metadata.legalReference,
        metadata: {'limitePersona': _limitePersona, 'detectado': false},
        evaluatedAt: now,
      );
    }

    final totalSeguros = insuranceExpenses.fold(
      0.0,
      (sum, e) => sum + e.deductibleAmount + e.nonDeductibleAmount,
    );

    // Limitar a 500 EUR por persona (asumimos 1 persona)
    final deducible = math.min(totalSeguros, _limitePersona);

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: deducible,
      riskLevel: RiskLevel.low,
      confidenceLevel: ConfidenceLevel.medium,
      explanation:
          'Gasto deducible en seguro de enfermedad: '
          '${deducible.toStringAsFixed(2)} EUR. '
          'Total seguros: ${totalSeguros.toStringAsFixed(2)} EUR '
          '(${insuranceExpenses.length} facturas). '
          'Límite: $_limitePersona EUR/persona/año.',
      legalReference: metadata.legalReference,
      metadata: {
        'totalSeguros': totalSeguros,
        'deducible': deducible,
        'limitePersona': _limitePersona,
        'invoiceCount': insuranceExpenses.length,
      },
      evaluatedAt: now,
    );
  }
}
