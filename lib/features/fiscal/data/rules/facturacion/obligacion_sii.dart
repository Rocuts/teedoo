import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Obligación de Suministro Inmediato de Información (SII).
///
/// Las empresas con facturación superior a 6.000.000 EUR están
/// obligadas al SII, debiendo remitir los registros de facturación
/// a la AEAT en un plazo de 4 días naturales.
class ObligacionSiiRule implements IFiscalRule {
  /// Umbral de facturación para la obligación SII.
  static const double _umbralFacturacion = 6000000.0;

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'facturacion_obligacion_sii',
    name: 'Obligación SII (> 6M EUR)',
    description:
        'Empresas con facturación > 6M EUR deben utilizar el '
        'Suministro Inmediato de Información (SII) de la AEAT.',
    taxType: TaxType.iva,
    legalReference: 'Art. 62.6 RIVA',
    contributorType: ContributorType.ambos,
    fiscalYearFrom: 2017,
    defaultRisk: RiskLevel.high,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

    final revenue = context.totalRevenue;
    final obligado = revenue >= _umbralFacturacion;

    if (!obligado) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation:
            'No obligado al SII: facturación (${revenue.toStringAsFixed(2)} EUR) '
            'inferior al umbral de $_umbralFacturacion EUR.',
        legalReference: metadata.legalReference,
        metadata: {
          'facturacion': revenue,
          'umbral': _umbralFacturacion,
          'obligado': false,
        },
        evaluatedAt: now,
      );
    }

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: 0,
      riskLevel: RiskLevel.high,
      confidenceLevel: ConfidenceLevel.high,
      explanation:
          'OBLIGADO al SII: facturación (${revenue.toStringAsFixed(2)} EUR) '
          'supera el umbral de $_umbralFacturacion EUR. Debe remitir '
          'registros de facturación a la AEAT en 4 días naturales.',
      legalReference: metadata.legalReference,
      metadata: {
        'facturacion': revenue,
        'umbral': _umbralFacturacion,
        'obligado': true,
      },
      evaluatedAt: now,
    );
  }
}
