import '../models/fiscal_rule.dart';
import '../models/rule_evaluation.dart';
import 'fiscal_context.dart';
import 'i_fiscal_rule.dart';

/// Motor de reglas fiscales.
///
/// Ejecuta una lista de [IFiscalRule] contra un [FiscalContext]
/// y retorna todas las evaluaciones resultantes. Filtra reglas
/// inactivas y las que no aplican al ejercicio fiscal del contexto.
class FiscalRuleEngine {
  final List<IFiscalRule> rules;

  const FiscalRuleEngine({required this.rules});

  /// Evalúa todas las reglas contra el contexto proporcionado.
  ///
  /// Solo evalúa reglas activas y aplicables al ejercicio fiscal
  /// y comunidad autónoma del perfil del contribuyente.
  List<RuleEvaluation> evaluate(FiscalContext context) {
    final evaluations = <RuleEvaluation>[];

    for (final rule in rules) {
      final meta = rule.metadata;

      if (!meta.isActive) continue;
      if (!meta.appliesTo(fiscalYear: context.fiscalYear)) continue;
      if (!meta.appliesToCommunity(context.profile.autonomousCommunity)) {
        continue;
      }

      final contributorType = context.profile.isAutonomo
          ? ContributorType.autonomo
          : ContributorType.sociedad;

      if (!meta.appliesToContributor(contributorType)) continue;

      final evaluation = rule.evaluate(context);
      evaluations.add(evaluation);
    }

    return evaluations;
  }

  /// Evalúa solo reglas de un tipo de impuesto específico.
  List<RuleEvaluation> evaluateByTaxType(
    FiscalContext context, {
    required TaxType taxType,
  }) {
    final filtered = rules.where((r) => r.metadata.taxType == taxType).toList();
    return FiscalRuleEngine(rules: filtered).evaluate(context);
  }
}
