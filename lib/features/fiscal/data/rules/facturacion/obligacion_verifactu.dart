import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Obligación VeriFactu (plazos 2027).
///
/// El sistema VeriFactu (RD 1007/2023) obliga a los programas
/// de facturación a generar registros de facturación verificables.
/// Entrada en vigor: 1 de julio de 2025 para desarrolladores,
/// 1 de enero de 2026 para obligados tributarios.
/// Plazo final de adaptación: 2027.
class ObligacionVerifactuRule implements IFiscalRule {
  @override
  FiscalRule get metadata => FiscalRule(
    id: 'facturacion_obligacion_verifactu',
    name: 'Obligación VeriFactu 2027',
    description:
        'Sistema VeriFactu de facturación verificable. '
        'Adaptación obligatoria con plazos hasta 2027.',
    taxType: TaxType.iva,
    legalReference: 'RD 1007/2023 (VeriFactu)',
    contributorType: ContributorType.ambos,
    fiscalYearFrom: 2025,
    defaultRisk: RiskLevel.medium,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

    final year = context.fiscalYear;

    // En 2026 estamos en período transitorio
    final riskLevel = year >= 2027 ? RiskLevel.high : RiskLevel.medium;

    final totalInvoices =
        context.issuedInvoices.length + context.receivedInvoices.length;

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: 0,
      riskLevel: riskLevel,
      confidenceLevel: ConfidenceLevel.high,
      explanation:
          'VeriFactu: sistema de facturación verificable obligatorio. '
          '${year < 2027 ? "En período transitorio (plazo final: 1 enero 2027). " : "PLAZO VENCIDO: adaptación obligatoria. "}'
          'Afecta a $totalInvoices facturas del período. '
          'El software de facturación debe generar registros con '
          'hash encadenado y firma electrónica.',
      legalReference: metadata.legalReference,
      metadata: {
        'fiscalYear': year,
        'enPlazo': year < 2027,
        'totalFacturas': totalInvoices,
      },
      evaluatedAt: now,
    );
  }
}
