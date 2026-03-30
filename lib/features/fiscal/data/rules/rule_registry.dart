import '../models/fiscal_rule.dart';
import 'i_fiscal_rule.dart';
import 'irpf/deduccion_manutencion.dart';
import 'irpf/deduccion_seguro_enfermedad.dart';
import 'irpf/deduccion_suministros.dart';
import 'irpf/gastos_dificil_justificacion.dart';
import 'iva/iva_deducibilidad.dart';
import 'iva/iva_vehiculo_afectacion.dart';
import 'sociedades/tipo_reducido_nueva_entidad.dart';
import 'sociedades/tipo_reducido_microempresa.dart';
import 'sociedades/reserva_capitalizacion.dart';
import 'sociedades/reserva_nivelacion.dart';
import 'sociedades/amortizacion_acelerada.dart';
import 'sociedades/gastos_no_deducibles.dart';
import 'facturacion/requisitos_formales.dart';
import 'facturacion/obligacion_sii.dart';
import 'facturacion/obligacion_verifactu.dart';
import 'autonomicas/madrid_rules.dart';

/// Registro central de todas las reglas fiscales disponibles.
///
/// Provee métodos estáticos para obtener reglas filtradas por
/// ejercicio fiscal, tipo de contribuyente y comunidad autónoma.
class RuleRegistry {
  RuleRegistry._();

  /// Todas las reglas registradas en el sistema.
  static List<IFiscalRule> get allRules => [
    // ── IRPF ──
    DeduccionSuministrosViviendaRule(),
    DeduccionManutencionRule(),
    DeduccionSeguroEnfermedadRule(),
    GastosDificilJustificacionRule(),

    // ── IVA ──
    IvaDeducibilidadGastoRule(),
    IvaVehiculoAfectacionRule(),

    // ── Sociedades ──
    TipoReducidoNuevaEntidadRule(),
    TipoReducidoMicroempresaRule(),
    ReservaCapitalizacionRule(),
    ReservaNivelacionRule(),
    AmortizacionAceleradaRule(),
    GastosNoDeduciblesRule(),

    // ── Facturación ──
    RequisitosFormalesRule(),
    ObligacionSiiRule(),
    ObligacionVerifactuRule(),

    // ── Autonómicas ──
    MadridDeduccionesRule(),
  ];

  /// Reglas que aplican a un ejercicio fiscal concreto.
  static List<IFiscalRule> forFiscalYear(int year) {
    return allRules
        .where((r) => r.metadata.appliesTo(fiscalYear: year))
        .toList();
  }

  /// Reglas que aplican a un tipo de contribuyente.
  static List<IFiscalRule> forContributorType(ContributorType type) {
    return allRules
        .where((r) => r.metadata.appliesToContributor(type))
        .toList();
  }

  /// Reglas que aplican a una comunidad autónoma.
  static List<IFiscalRule> forCommunity(String community) {
    return allRules
        .where((r) => r.metadata.appliesToCommunity(community))
        .toList();
  }

  /// Reglas filtradas por ejercicio, tipo de contribuyente y comunidad.
  static List<IFiscalRule> filtered({
    required int fiscalYear,
    required ContributorType contributorType,
    required String community,
  }) {
    return allRules.where((r) {
      final meta = r.metadata;
      return meta.isActive &&
          meta.appliesTo(fiscalYear: fiscalYear) &&
          meta.appliesToContributor(contributorType) &&
          meta.appliesToCommunity(community);
    }).toList();
  }

  /// Reglas de un tipo de impuesto específico.
  static List<IFiscalRule> forTaxType(TaxType taxType) {
    return allRules.where((r) => r.metadata.taxType == taxType).toList();
  }
}
