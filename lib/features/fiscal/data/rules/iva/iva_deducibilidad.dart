import '../../models/expense_classification.dart';
import '../../models/fiscal_profile.dart';
import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Deducibilidad del IVA soportado en gastos.
///
/// Art. 92-97 LIVA: El IVA soportado en facturas recibidas es
/// deducible cuando el gasto está afecto a la actividad económica,
/// la factura cumple requisitos formales, y se está en régimen
/// general o prorrata.
///
/// Verifica cada gasto clasificado y calcula el total de IVA
/// soportado deducible, aplicando prorrata si corresponde.
class IvaDeducibilidadGastoRule implements IFiscalRule {
  /// Tipos de IVA vigentes en España.
  static const double _tipoGeneral = 21.0;
  static const double _tipoReducido = 10.0;
  static const double _tipoSuperReducido = 4.0;

  /// Tasas de IVA válidas para verificar facturas.
  static const List<double> _validRates = [
    _tipoGeneral,
    _tipoReducido,
    _tipoSuperReducido,
    0.0,
  ];

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'iva_deducibilidad_gasto',
    name: 'Deducibilidad IVA soportado',
    description:
        'Verifica si el IVA soportado en facturas recibidas es '
        'deducible según Art. 92-97 LIVA y calcula el total '
        'de IVA deducible del período.',
    taxType: TaxType.iva,
    legalReference: 'Art. 92-97 LIVA',
    contributorType: ContributorType.ambos,
    fiscalYearFrom: 1993,
    defaultRisk: RiskLevel.low,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

    // Verificar régimen de IVA: exento no deduce
    if (context.profile.ivaRegime == IvaRegime.exento) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: false,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation:
            'No aplica: el contribuyente está en régimen exento de IVA. '
            'Las actividades exentas (Art. 20 LIVA) no generan derecho '
            'a deducción del IVA soportado.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Verificar que hay facturas recibidas
    if (context.receivedInvoices.isEmpty) {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: true,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'No hay facturas recibidas en el período.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Calcular IVA soportado total
    final totalIvaSoportado = context.totalIvaSoportado;

    // Calcular IVA deducible según clasificación de gastos
    double ivaDeducible = 0;
    int deducibleCount = 0;
    int nonDeducibleCount = 0;
    int requiresAnalysisCount = 0;

    for (final classification in context.expenseClassifications) {
      switch (classification.deductibility) {
        case Deductibility.totalmenteDeducible:
          ivaDeducible += classification.ivaDeducible;
          deducibleCount++;
        case Deductibility.parcialmenteDeducible:
          ivaDeducible += classification.ivaDeducible;
          deducibleCount++;
        case Deductibility.noDeducible:
          nonDeducibleCount++;
        case Deductibility.requiereAnalisis:
          requiresAnalysisCount++;
      }
    }

    // Aplicar prorrata si corresponde (régimen de prorrata)
    double prorataPercentage = 100.0;
    if (context.profile.ivaRegime == IvaRegime.prorata) {
      final totalOps = context.totalRevenue;
      // La prorrata general es: operaciones con derecho a deducción /
      // volumen total de operaciones * 100, redondeado al entero superior
      if (totalOps > 0) {
        prorataPercentage = (context.totalRevenue / totalOps * 100)
            .ceilToDouble();
        // En prorrata general se aplica el porcentaje provisional del año
        // anterior o el definitivo si se está regularizando
        ivaDeducible = ivaDeducible * (prorataPercentage / 100);
      }
    }

    // Si no hay clasificaciones pero sí facturas, estimar con IVA soportado
    if (context.expenseClassifications.isEmpty &&
        context.receivedInvoices.isNotEmpty) {
      ivaDeducible = totalIvaSoportado;
      deducibleCount = context.receivedInvoices.length;
    }

    // Determinar nivel de confianza
    final confidenceLevel = requiresAnalysisCount == 0
        ? ConfidenceLevel.high
        : requiresAnalysisCount <= 3
        ? ConfidenceLevel.medium
        : ConfidenceLevel.low;

    // Verificar coherencia de tasas de IVA en facturas
    int invalidRateCount = 0;
    for (final invoice in context.receivedInvoices) {
      for (final line in invoice.lines) {
        if (!_validRates.contains(line.taxRate)) {
          invalidRateCount++;
        }
      }
    }

    final riskLevel = invalidRateCount > 0 ? RiskLevel.medium : RiskLevel.low;

    final warnings = <String>[];
    if (invalidRateCount > 0) {
      warnings.add(
        '$invalidRateCount líneas con tipo de IVA no estándar detectadas.',
      );
    }
    if (requiresAnalysisCount > 0) {
      warnings.add(
        '$requiresAnalysisCount gastos requieren análisis manual para '
        'confirmar deducibilidad.',
      );
    }

    final warningText = warnings.isNotEmpty
        ? ' Avisos: ${warnings.join(' ')}'
        : '';

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: ivaDeducible,
      riskLevel: riskLevel,
      confidenceLevel: confidenceLevel,
      explanation:
          'IVA soportado total: ${totalIvaSoportado.toStringAsFixed(2)} EUR. '
          'IVA deducible: ${ivaDeducible.toStringAsFixed(2)} EUR '
          '($deducibleCount facturas deducibles, '
          '$nonDeducibleCount no deducibles).'
          '$warningText',
      legalReference: metadata.legalReference,
      metadata: {
        'totalIvaSoportado': totalIvaSoportado,
        'ivaDeducible': ivaDeducible,
        'deducibleCount': deducibleCount,
        'nonDeducibleCount': nonDeducibleCount,
        'requiresAnalysisCount': requiresAnalysisCount,
        'invalidRateCount': invalidRateCount,
        'prorataPercentage': prorataPercentage,
        'ivaRegime': context.profile.ivaRegime.name,
      },
      evaluatedAt: now,
    );
  }
}
