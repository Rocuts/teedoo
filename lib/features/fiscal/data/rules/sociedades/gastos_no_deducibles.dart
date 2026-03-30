import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Gastos no deducibles (Art. 15 LIS).
///
/// Art. 15 LIS establece los gastos no deducibles en el IS:
/// multas, sanciones, donativos (salvo mecenazgo), retribución
/// de fondos propios, pérdidas del juego, gastos con paraísos
/// fiscales, y operaciones vinculadas fuera de mercado.
class GastosNoDeduciblesRule implements IFiscalRule {
  /// Palabras clave que indican gastos potencialmente no deducibles.
  static const List<String> _keywordsMultas = [
    'multa',
    'sancion',
    'sanción',
    'penalizacion',
    'penalización',
    'recargo',
  ];

  static const List<String> _keywordsDonativos = [
    'donativo',
    'donacion',
    'donación',
    'regalo',
    'obsequio',
  ];

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'sociedades_gastos_no_deducibles',
    name: 'Gastos no deducibles Art. 15 LIS',
    description:
        'Detecta gastos que no son fiscalmente deducibles: multas, '
        'sanciones, donativos y retribución de fondos propios.',
    taxType: TaxType.sociedades,
    legalReference: 'Art. 15 LIS',
    contributorType: ContributorType.ambos,
    fiscalYearFrom: 2015,
    defaultRisk: RiskLevel.high,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

    if (context.receivedInvoices.isEmpty) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'No hay facturas recibidas para analizar.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    double importeMultas = 0;
    double importeDonativos = 0;
    int multasCount = 0;
    int donativosCount = 0;

    for (final invoice in context.receivedInvoices) {
      for (final line in invoice.lines) {
        final desc = line.description.toLowerCase();
        final lineTotal = line.quantity * line.unitPrice;

        if (_keywordsMultas.any(desc.contains)) {
          importeMultas += lineTotal;
          multasCount++;
        }
        if (_keywordsDonativos.any(desc.contains)) {
          importeDonativos += lineTotal;
          donativosCount++;
        }
      }
    }

    final totalNoDeducible = importeMultas + importeDonativos;

    if (totalNoDeducible <= 0) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation:
            'No se detectan gastos potencialmente no deducibles en las '
            'facturas del período.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Riesgo: si se están deduciendo estos gastos, podrían ajustar
    final riskLevel = totalNoDeducible > 1000
        ? RiskLevel.high
        : RiskLevel.medium;

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: 0,
      riskLevel: riskLevel,
      confidenceLevel: ConfidenceLevel.medium,
      explanation:
          'Se detectan ${totalNoDeducible.toStringAsFixed(2)} EUR en gastos '
          'potencialmente no deducibles: '
          '${importeMultas > 0 ? "$multasCount multas/sanciones (${importeMultas.toStringAsFixed(2)} EUR)" : ""}'
          '${importeMultas > 0 && importeDonativos > 0 ? ", " : ""}'
          '${importeDonativos > 0 ? "$donativosCount donativos (${importeDonativos.toStringAsFixed(2)} EUR)" : ""}. '
          'Verificar que no se incluyen como gasto deducible.',
      legalReference: metadata.legalReference,
      metadata: {
        'importeMultas': importeMultas,
        'importeDonativos': importeDonativos,
        'multasCount': multasCount,
        'donativosCount': donativosCount,
        'totalNoDeducible': totalNoDeducible,
      },
      evaluatedAt: now,
    );
  }
}
