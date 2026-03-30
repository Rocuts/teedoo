import 'dart:math' as math;

import '../../models/expense_classification.dart';
import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: IVA vehículo — presunción de afectación 50%.
///
/// Art. 95.Tres.2 LIVA: Los turismos y remolques se presumen
/// afectos a la actividad al 50%. Solo se puede deducir el 50%
/// del IVA soportado salvo prueba de afectación superior.
class IvaVehiculoAfectacionRule implements IFiscalRule {
  /// Presunción legal de afectación.
  static const double _presuncionAfectacion = 50.0;

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'iva_vehiculo_afectacion',
    name: 'IVA vehículo — afectación 50%',
    description:
        'Los turismos se presumen afectos al 50%. Solo se deduce '
        'el 50% del IVA soportado (Art. 95.Tres.2 LIVA).',
    taxType: TaxType.iva,
    legalReference: 'Art. 95.Tres.2 LIVA',
    contributorType: ContributorType.ambos,
    fiscalYearFrom: 1993,
    defaultRisk: RiskLevel.medium,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

    // Buscar gastos de vehículo
    final vehicleExpenses = context.expenseClassifications
        .where((e) => e.category == ExpenseCategory.vehiculo)
        .toList();

    if (vehicleExpenses.isEmpty) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'No se detectan gastos de vehículo en el período.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Calcular IVA soportado en vehículos
    double totalIvaVehiculo = 0;
    double totalBaseVehiculo = 0;
    for (final expense in vehicleExpenses) {
      totalIvaVehiculo +=
          expense.ivaDeducible +
          (expense.ivaDeducible / (expense.deductiblePercentage / 100) -
              expense.ivaDeducible);
      totalBaseVehiculo +=
          expense.deductibleAmount + expense.nonDeductibleAmount;
    }

    // IVA deducible = 50% del total
    final ivaDeducible = totalIvaVehiculo * (_presuncionAfectacion / 100);

    final riskLevel =
        vehicleExpenses.any(
          (e) => e.deductiblePercentage > _presuncionAfectacion,
        )
        ? RiskLevel.high
        : RiskLevel.medium;

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: math.max(0, ivaDeducible),
      riskLevel: riskLevel,
      confidenceLevel: ConfidenceLevel.medium,
      explanation:
          'IVA deducible en vehículos: ${ivaDeducible.toStringAsFixed(2)} EUR '
          '($_presuncionAfectacion% de ${totalIvaVehiculo.toStringAsFixed(2)} EUR). '
          '${vehicleExpenses.length} facturas de vehículo, '
          'base imponible total: ${totalBaseVehiculo.toStringAsFixed(2)} EUR. '
          '${riskLevel == RiskLevel.high ? "ATENCIÓN: se detectan deducciones superiores al 50% presunto." : ""}',
      legalReference: metadata.legalReference,
      metadata: {
        'totalIvaVehiculo': totalIvaVehiculo,
        'totalBaseVehiculo': totalBaseVehiculo,
        'ivaDeducible': ivaDeducible,
        'presuncionAfectacion': _presuncionAfectacion,
        'invoiceCount': vehicleExpenses.length,
      },
      evaluatedAt: now,
    );
  }
}
