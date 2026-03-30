import '../models/fiscal_rule.dart';
import '../models/rule_evaluation.dart';
import 'fiscal_context.dart';

/// Interfaz abstracta para reglas fiscales evaluables.
///
/// Cada regla concreta (IRPF, IVA, etc.) implementa esta interfaz
/// proporcionando sus metadatos y la lógica de evaluación contra
/// un [FiscalContext].
abstract class IFiscalRule {
  /// Metadatos de la regla (id, nombre, tipo impuesto, etc.).
  FiscalRule get metadata;

  /// Evalúa la regla contra el contexto fiscal proporcionado.
  ///
  /// Retorna un [RuleEvaluation] con el resultado: si aplica,
  /// ahorro estimado, nivel de riesgo, y explicación.
  RuleEvaluation evaluate(FiscalContext context);
}
