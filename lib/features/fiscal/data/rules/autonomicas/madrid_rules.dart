import '../../models/expense_classification.dart';
import '../../models/fiscal_rule.dart';
import '../../models/rule_evaluation.dart';
import '../fiscal_context.dart';
import '../i_fiscal_rule.dart';

/// Regla: Deducciones autonómicas de la Comunidad de Madrid.
///
/// Incluye:
/// - Deducción por nacimiento/adopción: 721,70 EUR por hijo.
/// - Deducción alquiler vivienda jóvenes (< 35 años): 30% del alquiler,
///   máximo 1.000 EUR.
/// - Deducción por gastos educativos: escolaridad, idiomas, uniformes
///   (15%/10%/5% respectivamente, con límites).
class MadridDeduccionesRule implements IFiscalRule {
  /// Deducción por nacimiento.
  static const double _deduccionNacimiento = 721.70;

  /// Porcentaje deducción alquiler jóvenes.
  static const double _porcentajeAlquiler = 30.0;

  /// Máximo deducción alquiler.
  static const double _maxAlquiler = 1000.0;

  /// Porcentaje deducción gastos escolaridad.
  static const double _porcentajeEscolaridad = 15.0;

  @override
  FiscalRule get metadata => FiscalRule(
    id: 'autonomica_madrid_deducciones',
    name: 'Deducciones autonómicas Madrid',
    description:
        'Deducciones de la Comunidad de Madrid: nacimiento '
        '($_deduccionNacimiento EUR), alquiler jóvenes ($_porcentajeAlquiler%), '
        'gastos educativos.',
    taxType: TaxType.irpf,
    legalReference: 'DL 1/2010 CM — IRPF autonómico Madrid',
    contributorType: ContributorType.ambos,
    applicableCommunities: ['Madrid'],
    fiscalYearFrom: 2010,
    defaultRisk: RiskLevel.low,
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  RuleEvaluation evaluate(FiscalContext context) {
    final now = DateTime.now();

    if (context.profile.autonomousCommunity != 'Madrid') {
      return RuleEvaluation(
        ruleId: metadata.id,
        ruleName: metadata.name,
        taxType: metadata.taxType,
        applies: false,
        estimatedSaving: 0,
        riskLevel: RiskLevel.low,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'No aplica: el contribuyente no reside en Madrid.',
        legalReference: metadata.legalReference,
        evaluatedAt: now,
      );
    }

    // Estimación de deducciones aplicables
    double totalDeduccion = 0;
    final deduccionesDetalle = <String>[];

    // 1. Deducción por nacimiento (informativa: siempre posible)
    deduccionesDetalle.add(
      'Nacimiento/adopción: $_deduccionNacimiento EUR por hijo',
    );

    // 2. Deducción alquiler jóvenes — buscar gastos de alquiler
    final alquilerExpenses = context.expenseClassifications
        .where((e) => e.category == ExpenseCategory.alquiler)
        .toList();

    if (alquilerExpenses.isNotEmpty) {
      final totalAlquiler = alquilerExpenses.fold(
        0.0,
        (sum, e) => sum + e.deductibleAmount + e.nonDeductibleAmount,
      );
      final deduccionAlquiler = totalAlquiler * (_porcentajeAlquiler / 100);
      final deduccionAlquilerEfectiva = deduccionAlquiler > _maxAlquiler
          ? _maxAlquiler
          : deduccionAlquiler;
      totalDeduccion += deduccionAlquilerEfectiva;
      deduccionesDetalle.add(
        'Alquiler jóvenes: ${deduccionAlquilerEfectiva.toStringAsFixed(2)} EUR '
        '($_porcentajeAlquiler% de ${totalAlquiler.toStringAsFixed(2)} EUR, '
        'máx. $_maxAlquiler EUR)',
      );
    }

    // 3. Gastos educativos — buscar gastos de formación
    final educExpenses = context.expenseClassifications
        .where((e) => e.category == ExpenseCategory.formacion)
        .toList();

    if (educExpenses.isNotEmpty) {
      final totalEduc = educExpenses.fold(
        0.0,
        (sum, e) => sum + e.deductibleAmount + e.nonDeductibleAmount,
      );
      final deduccionEduc = totalEduc * (_porcentajeEscolaridad / 100);
      totalDeduccion += deduccionEduc;
      deduccionesDetalle.add(
        'Gastos educativos: ${deduccionEduc.toStringAsFixed(2)} EUR '
        '($_porcentajeEscolaridad% de ${totalEduc.toStringAsFixed(2)} EUR)',
      );
    }

    return RuleEvaluation(
      ruleId: metadata.id,
      ruleName: metadata.name,
      taxType: metadata.taxType,
      applies: true,
      estimatedSaving: totalDeduccion,
      riskLevel: RiskLevel.low,
      confidenceLevel: totalDeduccion > 0
          ? ConfidenceLevel.medium
          : ConfidenceLevel.low,
      explanation:
          'Deducciones autonómicas Madrid disponibles: '
          '${totalDeduccion.toStringAsFixed(2)} EUR. '
          '${deduccionesDetalle.join(". ")}.',
      legalReference: metadata.legalReference,
      metadata: {
        'totalDeduccion': totalDeduccion,
        'deduccionNacimiento': _deduccionNacimiento,
        'porcentajeAlquiler': _porcentajeAlquiler,
        'detalle': deduccionesDetalle,
      },
      evaluatedAt: now,
    );
  }
}
