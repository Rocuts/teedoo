import '../../../core/services/fiscal_explanation_service.dart';
import '../../../features/invoices/data/models/invoice_model.dart';
import '../data/models/fiscal_profile.dart';
import '../data/models/fiscal_rule.dart';
import '../data/models/optimization_report.dart';
import '../data/models/rule_evaluation.dart';
import '../data/models/tax_optimization.dart';
import '../data/rules/fiscal_context.dart';
import '../data/rules/rule_engine.dart';
import '../data/rules/rule_registry.dart';
import 'expense_classifier.dart';
import 'risk_scorer.dart';
import 'savings_calculator.dart';

/// Orquestador principal de análisis fiscal.
///
/// Construye el contexto fiscal, ejecuta el motor de reglas,
/// calcula ahorros y genera el informe de optimización completo.
class FiscalAnalyzer {
  final FiscalExplanationService? _explanationService;

  const FiscalAnalyzer({FiscalExplanationService? explanationService})
    : _explanationService = explanationService;

  /// Genera un informe completo de optimización fiscal.
  ///
  /// Recibe el perfil fiscal, facturas emitidas y recibidas,
  /// clasifica gastos, evalúa reglas, calcula ahorros, y
  /// opcionalmente enriquece con explicaciones de IA.
  Future<OptimizationReport> analyze({
    required FiscalProfile profile,
    required List<Invoice> issuedInvoices,
    required List<Invoice> receivedInvoices,
    bool includeAiExplanations = false,
  }) async {
    final stopwatch = Stopwatch()..start();

    // 1. Clasificar gastos de facturas recibidas
    final classifier = ExpenseClassifier();
    final classifications = receivedInvoices
        .map((inv) => classifier.classify(invoice: inv, profile: profile))
        .toList();

    // 2. Construir contexto fiscal
    final context = FiscalContext(
      profile: profile,
      issuedInvoices: issuedInvoices,
      receivedInvoices: receivedInvoices,
      expenseClassifications: classifications,
      fiscalYear: profile.fiscalYear,
    );

    // 3. Obtener reglas aplicables y evaluar
    final rules = RuleRegistry.forFiscalYear(profile.fiscalYear);
    final engine = FiscalRuleEngine(rules: rules);
    final evaluations = engine.evaluate(context);

    // 4. Enriquecer con explicaciones de IA si se solicita
    final enrichedEvaluations = includeAiExplanations
        ? await _enrichWithAiExplanations(evaluations, profile)
        : evaluations;

    // 5. Generar optimizaciones a partir de evaluaciones con ahorro
    final optimizations = _buildOptimizations(enrichedEvaluations);

    // 6. Calcular resumen
    final summary = _buildSummary(enrichedEvaluations, optimizations);

    stopwatch.stop();

    return OptimizationReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: profile.userId,
      fiscalYear: profile.fiscalYear,
      summary: summary,
      evaluations: enrichedEvaluations,
      optimizations: optimizations,
      generatedAt: DateTime.now(),
      processingTime: stopwatch.elapsed,
    );
  }

  /// Enriquece las evaluaciones con explicaciones.
  ///
  /// Primero genera justificaciones deterministas locales para todas
  /// las evaluaciones con ahorro. Luego, si el servicio de IA está
  /// disponible, intenta enriquecer con explicaciones generadas por OpenAI.
  /// Si la API falla, mantiene la justificación local.
  Future<List<RuleEvaluation>> _enrichWithAiExplanations(
    List<RuleEvaluation> evaluations,
    FiscalProfile profile,
  ) async {
    final enriched = <RuleEvaluation>[];

    for (final evaluation in evaluations) {
      if (!evaluation.hasSaving) {
        enriched.add(evaluation);
        continue;
      }

      // Siempre generar justificación local determinista
      final localExplanation = _buildLocalExplanation(evaluation, profile);
      var enrichedEval = evaluation.copyWith(aiExplanation: localExplanation);

      // Intentar enriquecer con OpenAI validado si el servicio está disponible
      if (_explanationService != null) {
        try {
          final aiExplanation = await _explanationService.explain(
            ruleName: evaluation.ruleName,
            ruleExplanation: evaluation.explanation,
            legalReference: evaluation.legalReference,
            estimatedSaving: evaluation.estimatedSaving,
            fiscalYear: profile.fiscalYear,
            autonomousCommunity: profile.autonomousCommunity,
            confidenceLevel: evaluation.confidenceLevel.name,
            riskLevel: evaluation.riskLevel.name,
            actionRequired: _suggestAction(evaluation),
          );
          if (aiExplanation != null) {
            // OpenAI validó y enriqueció — reemplazar la justificación local
            enrichedEval = enrichedEval.copyWith(aiExplanation: aiExplanation);
          }
          // Si null, se mantiene la justificación local
        } catch (_) {
          // Si la API falla, se mantiene la justificación local
        }
      }

      enriched.add(enrichedEval);
    }

    return enriched;
  }

  /// Genera una justificación fiscal determinista sin IA.
  ///
  /// Basada exclusivamente en los datos de la regla evaluada y el perfil
  /// del contribuyente. No inventa fundamentos legales.
  String _buildLocalExplanation(RuleEvaluation eval, FiscalProfile profile) {
    final saving = eval.estimatedSaving.toStringAsFixed(2);
    final regime =
        profile.fiscalRegime == FiscalRegime.estimacionDirectaSimplificada
        ? 'estimación directa simplificada'
        : profile.fiscalRegime == FiscalRegime.estimacionDirectaNormal
        ? 'estimación directa normal'
        : 'su régimen fiscal';
    final formJuridica = profile.legalForm == LegalForm.autonomo
        ? 'autónomo persona física'
        : 'sociedad';

    final buffer = StringBuffer();

    // Párrafo 1: Qué se detectó
    buffer.writeln(
      'Se ha detectado una oportunidad de ahorro fiscal de $saving EUR '
      'aplicable a su situación como $formJuridica en $regime.',
    );
    buffer.writeln();

    // Párrafo 2: Base normativa
    buffer.writeln(
      'Fundamento legal: ${eval.legalReference}. '
      '${eval.explanation}',
    );
    buffer.writeln();

    // Párrafo 3: Acción recomendada por tipo de impuesto
    switch (eval.taxType) {
      case TaxType.irpf:
        buffer.writeln(
          'Para aplicar esta deducción, incluya el importe en la casilla '
          'correspondiente de su declaración de IRPF (modelo 100) o en el '
          'pago fraccionado trimestral (modelo 130). Conserve las facturas '
          'y justificantes de pago como soporte documental.',
        );
      case TaxType.iva:
        buffer.writeln(
          'Incluya el IVA deducible en el modelo 303 del trimestre '
          'correspondiente. Asegúrese de disponer de facturas completas '
          'conforme al Art. 6 del RD 1619/2012.',
        );
      case TaxType.sociedades:
        buffer.writeln(
          'Registre el gasto deducible en la contabilidad de la sociedad '
          'para su inclusión en el Impuesto sobre Sociedades (modelo 200).',
        );
      default:
        buffer.writeln(
          'Consulte con su asesor fiscal la aplicación de esta optimización.',
        );
    }
    buffer.writeln();

    // Párrafo 4: Nivel de confianza y riesgo
    final confianza = switch (eval.confidenceLevel) {
      ConfidenceLevel.high => 'alta',
      ConfidenceLevel.medium => 'media',
      ConfidenceLevel.low => 'baja — se recomienda validación profesional',
    };
    final riesgo = switch (eval.riskLevel) {
      RiskLevel.low => 'bajo',
      RiskLevel.medium => 'medio',
      RiskLevel.high => 'alto — proceda con cautela',
      RiskLevel.critical =>
        'crítico — requiere revisión profesional obligatoria',
    };

    buffer.writeln(
      'Nivel de confianza: $confianza. Nivel de riesgo ante inspección: $riesgo.',
    );
    buffer.writeln();

    buffer.write(
      'Nota: Este análisis es orientativo y no sustituye el asesoramiento '
      'fiscal profesional. Basado en normativa vigente a fecha del análisis.',
    );

    return buffer.toString();
  }

  /// Convierte evaluaciones con ahorro en optimizaciones accionables.
  List<TaxOptimization> _buildOptimizations(List<RuleEvaluation> evaluations) {
    return evaluations.where((e) => e.hasSaving).map((e) {
      final action = _suggestAction(e);
      return TaxOptimization(
        id: '${e.ruleId}_${DateTime.now().millisecondsSinceEpoch}',
        ruleId: e.ruleId,
        title: e.ruleName,
        description: e.explanation,
        taxType: e.taxType,
        estimatedSaving: SavingsCalculator.computeIrpfSaving(
          deductibleAmount: e.estimatedSaving,
          taxableIncome: 0,
        ),
        riskLevel: e.riskLevel,
        confidenceLevel: e.confidenceLevel,
        legalReference: e.legalReference,
        aiExplanation: e.aiExplanation,
        actionRequired: action,
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  /// Sugiere la acción que debe tomar el contribuyente.
  String _suggestAction(RuleEvaluation evaluation) {
    return switch (evaluation.taxType) {
      TaxType.irpf =>
        'Incluir la deducción de ${evaluation.estimatedSaving.toStringAsFixed(2)} EUR '
            'en la casilla correspondiente del modelo 130/100.',
      TaxType.iva =>
        'Incluir el IVA deducible de ${evaluation.estimatedSaving.toStringAsFixed(2)} EUR '
            'en el modelo 303 del trimestre.',
      TaxType.sociedades =>
        'Registrar el gasto deducible en la contabilidad para el '
            'Impuesto de Sociedades (modelo 200).',
      _ => 'Revisar con su asesor fiscal la aplicación de esta deducción.',
    };
  }

  /// Construye el resumen ejecutivo del informe.
  ReportSummary _buildSummary(
    List<RuleEvaluation> evaluations,
    List<TaxOptimization> optimizations,
  ) {
    final applicable = evaluations.where((e) => e.applies).toList();

    final irpfSaving = evaluations
        .where((e) => e.hasSaving && e.taxType == TaxType.irpf)
        .fold(0.0, (sum, e) => sum + e.estimatedSaving);

    final ivaSaving = evaluations
        .where((e) => e.hasSaving && e.taxType == TaxType.iva)
        .fold(0.0, (sum, e) => sum + e.estimatedSaving);

    final highConfidence = evaluations
        .where((e) => e.confidenceLevel == ConfidenceLevel.high)
        .length;

    final lowRisk = evaluations
        .where((e) => e.riskLevel == RiskLevel.low)
        .length;

    final overallRisk = RiskScorer.computeRisk(evaluations);

    return ReportSummary(
      totalEstimatedSaving: irpfSaving + ivaSaving,
      irpfSaving: irpfSaving,
      ivaSaving: ivaSaving,
      rulesEvaluated: evaluations.length,
      rulesApplicable: applicable.length,
      highConfidenceCount: highConfidence,
      lowRiskCount: lowRisk,
      overallRisk: overallRisk,
    );
  }
}
