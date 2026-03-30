import 'dart:math' as math;

import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Deducción de suministros de la vivienda habitual.
///
/// Art. 30.2.5.b) LIRPF: Los autónomos que trabajan desde casa
/// pueden deducir el 30% de la proporción de la vivienda dedicada
/// a la actividad sobre los gastos de suministros (luz, agua, gas,
/// telefonía e internet).
///
/// Requisito: trabajar desde casa y estar en estimación directa.
class DeduccionSuministrosViviendaRule implements IFiscalRule {
  /// Porcentaje fijo que aplica la AEAT sobre la proporción
  /// de la vivienda afecta (30% según Art. 30.2.5.b LIRPF).
  static const double _porcentajeFijo = 30.0;

  /// Porcentaje mínimo de vivienda afecta que se acepta.
  static const double _minHomePercentage = 5.0;

  /// Porcentaje máximo de vivienda afecta razonable.
  static const double _maxHomePercentage = 50.0;

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'irpf_deduccion_suministros_vivienda',
    name: 'Deducción suministros vivienda habitual',
    description:
        'Deducción del 30% de los suministros proporcionalmente al '
        'espacio de la vivienda afecto a la actividad económica.',
    taxType: TaxType.irpf,
    legalReference: 'Art. 30.2.5.b) LIRPF',
    contributorType: ContributorType.autonomo,
    fiscalYearFrom: 2018,
    defaultRisk: RiskLevel.low,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

    // Verificar que es autónomo en estimación directa
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

    // Verificar que trabaja desde casa
    if (!context.profile.worksFromHome) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: false,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation:
            'No aplica: el contribuyente no ha declarado trabajar '
            'desde su vivienda habitual.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Obtener porcentaje de vivienda afecta
    final homePercentage = context.profile.homeOfficePercentage ?? 0;
    if (homePercentage < _minHomePercentage) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: false,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.medium,
        explanation:
            'No aplica: porcentaje de vivienda afecta ($homePercentage%) '
            'inferior al mínimo razonable ($_minHomePercentage%).',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Limitar al máximo razonable para evitar riesgo fiscal
    final effectivePercentage = math.min(homePercentage, _maxHomePercentage);

    // Calcular total de suministros del período
    final supplyExpenses = context.homeSupplyExpenses;
    final totalSupplies = supplyExpenses.fold(
      0.0,
      (sum, e) => sum + e.deductibleAmount + e.nonDeductibleAmount,
    );

    if (totalSupplies <= 0) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.medium,
        explanation:
            'La regla aplica pero no se han detectado gastos de '
            'suministros clasificados en el período.',
        legalReference: metadata.legalReference,
        metadata: {
          'homePercentage': effectivePercentage,
          'fixedPercentage': _porcentajeFijo,
        },
        evaluatedAt: now,
      );
    }

    // Cálculo: Total suministros * (% vivienda afecta / 100) * (30 / 100)
    final deductibleBase =
        totalSupplies * (effectivePercentage / 100) * (_porcentajeFijo / 100);

    // Determinar riesgo según el porcentaje declarado
    final riskLevel = effectivePercentage > 40
        ? RiskLevel.medium
        : RiskLevel.low;

    final confidenceLevel = supplyExpenses.length >= 6
        ? ConfidenceLevel.high
        : ConfidenceLevel.medium;

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: deductibleBase,
      riskLevel: riskLevel,
      confidenceLevel: confidenceLevel,
      explanation:
          'Gasto deducible en suministros: ${deductibleBase.toStringAsFixed(2)} EUR. '
          'Calculado como $totalSupplies EUR x ${effectivePercentage.toStringAsFixed(0)}% '
          '(vivienda afecta) x $_porcentajeFijo% (porcentaje fijo LIRPF). '
          'Basado en ${supplyExpenses.length} facturas de suministros.',
      legalReference: metadata.legalReference,
      metadata: {
        'totalSupplies': totalSupplies,
        'homePercentage': effectivePercentage,
        'fixedPercentage': _porcentajeFijo,
        'deductibleBase': deductibleBase,
        'invoiceCount': supplyExpenses.length,
      },
      evaluatedAt: now,
    );
  }
}
