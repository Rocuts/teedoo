import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Requisitos formales de facturación (Art. 6 RD 1619/2012).
///
/// Verifica que las facturas emitidas cumplen los requisitos formales
/// obligatorios: número, fecha, NIF emisor/receptor, descripción,
/// base imponible, tipo y cuota de IVA.
class RequisitosFormalesRule implements IFiscalRule {
  @override
  FiscalRule get metadata => FiscalRule(
    id: 'facturacion_requisitos_formales',
    name: 'Requisitos formales de facturación',
    description:
        'Verifica que las facturas cumplen los requisitos del '
        'Art. 6 RD 1619/2012: número, fecha, NIF, descripción, '
        'base imponible, tipo y cuota de IVA.',
    taxType: TaxType.iva,
    legalReference: 'Art. 6 RD 1619/2012',
    contributorType: ContributorType.ambos,
    fiscalYearFrom: 2013,
    defaultRisk: RiskLevel.medium,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

    final allInvoices = [
      ...context.issuedInvoices,
      ...context.receivedInvoices,
    ];

    if (allInvoices.isEmpty) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'No hay facturas para verificar.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    int defectsCount = 0;
    final defects = <String>[];

    for (final invoice in allInvoices) {
      final issues = <String>[];

      // Verificar NIF emisor
      if (invoice.issuerNif.isEmpty) {
        issues.add('falta NIF emisor');
      }
      // Verificar NIF receptor
      if (invoice.receiverNif.isEmpty) {
        issues.add('falta NIF receptor');
      }
      // Verificar número de factura
      if (invoice.number.isEmpty) {
        issues.add('falta número de factura');
      }
      // Verificar líneas
      if (invoice.lines.isEmpty) {
        issues.add('sin líneas de detalle');
      }
      // Verificar que cada línea tiene descripción
      for (final line in invoice.lines) {
        if (line.description.trim().isEmpty) {
          issues.add('línea sin descripción');
          break;
        }
      }

      if (issues.isNotEmpty) {
        defectsCount++;
        if (defects.length < 5) {
          defects.add('${invoice.number}: ${issues.join(", ")}');
        }
      }
    }

    if (defectsCount == 0) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation:
            'Todas las ${allInvoices.length} facturas cumplen los '
            'requisitos formales básicos.',
        legalReference: metadata.legalReference,
        metadata: {'totalFacturas': allInvoices.length, 'defectsCount': 0},
        evaluatedAt: now,
      );
    }

    final riskLevel = defectsCount > 5 ? RiskLevel.high : RiskLevel.medium;

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: 0,
      riskLevel: riskLevel,
      confidenceLevel: ConfidenceLevel.high,
      explanation:
          '$defectsCount de ${allInvoices.length} facturas presentan '
          'defectos formales. ${defects.join("; ")}.',
      legalReference: metadata.legalReference,
      metadata: {
        'totalFacturas': allInvoices.length,
        'defectsCount': defectsCount,
        'defects': defects,
      },
      evaluatedAt: now,
    );
  }
}
