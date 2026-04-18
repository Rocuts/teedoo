// Fuente fiscal: Real Decreto 1007/2023 (BOE-A-2023-24840) — Sistemas informáticos
// de facturación y Verifactu. https://www.boe.es/eli/es/rd/2023/12/05/1007
// Cross-checked with TicketBAI schema (Euskadi), SII AEAT and EN 16931 core invoice.
// Verificado 2026-04-18.
//
// Canonical invoice entity (Phase 1 of dual-DB capture).
//
// IMPORTANT CONVENTIONS:
//   * Money: every monetary field is stored as integer CENTS (int). Never double.
//     Operations/rounding happen at the edge; domain never holds floats.
//   * Dates: stored as DateTime (UTC preferred). Data-layer models serialize to
//     ISO-8601 strings for wire/DB.
//   * Currency: ISO-4217 code (e.g. 'EUR').
//   * IDs: UUID v4 strings. Postgres uses `id` as primary key; Mongo server-side
//     `_id` is opaque and NOT mirrored here.
//   * orgId: required in domain for RLS scoping (Postgres) and shard key (Mongo).
//
// Phase 1 does NOT replace the legacy [Invoice] in
// `lib/features/invoices/data/models/invoice_model.dart`. It lives alongside it
// under the `domain/` folder so existing screens keep compiling.

import 'package:freezed_annotation/freezed_annotation.dart';

// Reuse the existing [InvoiceStatus] enum so UI/status_extensions keep working.
// If Phase 2 needs extra states (ISSUED, PAID, RECTIFIED) we extend there.
// InvoiceStatus is declared in `invoice_model.dart`; `invoice_status.dart`
// only extends it with UI helpers, so we import from the canonical source.
import '../data/models/invoice_model.dart' show InvoiceStatus;

// Party / Address / TaxIdType viven ahora en su propio módulo para permitir
// normalizarlos como agregado independiente (tabla `parties` / colección
// `parties`). Se re-exportan más abajo para que los imports existentes
// (`package:teedoo/features/invoices/domain/invoice.dart`) sigan compilando
// sin cambios.
import '../../parties/domain/party.dart';

// Re-export Party API so downstream imports of this file keep working.
export '../../parties/domain/party.dart'
    show Party, Address, PartyAddress, TaxIdType;

// TODO(phase-1-codegen): run `dart run build_runner build --delete-conflicting-outputs`
// to generate `invoice.freezed.dart`.
part 'invoice.freezed.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums — fiscal metadata
// ─────────────────────────────────────────────────────────────────────────────

/// Régimen fiscal aplicable a la factura (Art. 120 LIVA + RD 1007/2023),
/// spec canónica 2026-04-18 con siglas oficiales AEAT.
enum InvoiceRegime {
  general('GENERAL'),
  simplificado('SIMPLIFICADO'),
  recargoEquivalencia('RECARGO_EQUIVALENCIA'),
  reagp('REAGP'), // Régimen especial de agricultura, ganadería y pesca
  bienesUsadosRebu('BIENES_USADOS_REBU'),
  agenciasViajesReav('AGENCIAS_VIAJES_REAV'),
  criterioCajaRecc('CRITERIO_CAJA_RECC'),
  grupoEntidadesRege('GRUPO_ENTIDADES_REGE'),
  exento('EXENTO');

  const InvoiceRegime(this.wireValue);

  final String wireValue;

  static InvoiceRegime fromWire(String value) {
    for (final v in InvoiceRegime.values) {
      if (v.wireValue == value) return v;
    }
    throw ArgumentError.value(
      value,
      'wireValue',
      'Unknown InvoiceRegime wire value (expected one of: '
          '${InvoiceRegime.values.map((e) => e.wireValue).join(', ')})',
    );
  }
}

/// Claves de operación AEAT (SII / Verifactu), catálogo canónico 2026-04-18:
///   F1: Factura completa.
///   F2: Factura simplificada (ticket).
///   F3: Factura emitida en sustitución de simplificadas.
///   F4: Asiento resumen de facturas.
///   F5: Importaciones (DUA).
///   R1-R5: Facturas rectificativas (por error fundado en derecho, art. 80 LIVA,
///          por diferencias, por devoluciones, por sustitución de simplificadas).
enum OperationType {
  f1('F1'),
  f2('F2'),
  f3('F3'),
  f4('F4'),
  f5('F5'),
  r1('R1'),
  r2('R2'),
  r3('R3'),
  r4('R4'),
  r5('R5');

  const OperationType(this.wireValue);

  final String wireValue;

  static OperationType fromWire(String value) {
    for (final v in OperationType.values) {
      if (v.wireValue == value) return v;
    }
    throw ArgumentError.value(
      value,
      'wireValue',
      'Unknown OperationType wire value (expected one of: '
          '${OperationType.values.map((e) => e.wireValue).join(', ')})',
    );
  }
}

/// Regiones fiscales españolas con IVA propio o particularidades:
///   PENINSULA_BALEARES → IVA estándar.
///   CANARIAS → IGIC.
///   CEUTA / MELILLA → IPSI.
///   PAIS_VASCO_ARABA / PAIS_VASCO_BIZKAIA / PAIS_VASCO_GIPUZKOA →
///       Hacienda Foral correspondiente, TicketBAI obligatorio.
///   NAVARRA → Hacienda Foral de Navarra.
enum FiscalRegion {
  peninsulaBaleares('PENINSULA_BALEARES'),
  canarias('CANARIAS'),
  ceuta('CEUTA'),
  melilla('MELILLA'),
  paisVascoAraba('PAIS_VASCO_ARABA'),
  paisVascoBizkaia('PAIS_VASCO_BIZKAIA'),
  paisVascoGipuzkoa('PAIS_VASCO_GIPUZKOA'),
  navarra('NAVARRA');

  const FiscalRegion(this.wireValue);

  final String wireValue;

  static FiscalRegion fromWire(String value) {
    for (final v in FiscalRegion.values) {
      if (v.wireValue == value) return v;
    }
    throw ArgumentError.value(
      value,
      'wireValue',
      'Unknown FiscalRegion wire value (expected one of: '
          '${FiscalRegion.values.map((e) => e.wireValue).join(', ')})',
    );
  }
}

// [TaxIdType] vive en `features/parties/domain/party.dart` y se re-exporta al
// principio de este archivo, de modo que los imports existentes no se rompen.

/// Tipos impositivos / categorías de IVA canónicos 2026-04-18.
///   IVA_GENERAL_21, IVA_REDUCIDO_10, IVA_SUPERREDUCIDO_4, IVA_CERO.
///   EXENTO (sin IVA), NO_SUJETO (fuera del ámbito del IVA).
///   IGIC_* para Canarias; IPSI para Ceuta/Melilla. El valor numérico
///   efectivo lo lleva la línea en `vatRateValue`.
enum VatRate {
  general('IVA_GENERAL_21'),
  reducido('IVA_REDUCIDO_10'),
  superReducido('IVA_SUPERREDUCIDO_4'),
  cero('IVA_CERO'),
  exento('EXENTO'),
  noSujeto('NO_SUJETO'),
  igicGeneral('IGIC_GENERAL_7'),
  igicReducido('IGIC_REDUCIDO_3'),
  igicCero('IGIC_CERO'),
  ipsi('IPSI');

  const VatRate(this.wireValue);

  final String wireValue;

  static VatRate fromWire(String value) {
    for (final v in VatRate.values) {
      if (v.wireValue == value) return v;
    }
    throw ArgumentError.value(
      value,
      'wireValue',
      'Unknown VatRate wire value (expected one of: '
          '${VatRate.values.map((e) => e.wireValue).join(', ')})',
    );
  }
}

/// Estado en workflow interno.
/// Reutiliza el enum legado de [InvoiceStatus] (draft / pendingReview /
/// readyToSend / sent / accepted / rejected / cancelled). El estado contable
/// extendido (PAID, RECTIFIED) se añadirá en Phase 2 sin romper UI actual.
/// Aquí sólo re-exportamos para centralizar imports.
typedef DomainInvoiceStatus = InvoiceStatus;

// ─────────────────────────────────────────────────────────────────────────────
// Sub-entities
// ─────────────────────────────────────────────────────────────────────────────
//
// [Address] y [Party] viven ahora en `features/parties/domain/party.dart`.
// Se re-exportan al principio de este archivo — no redeclarar aquí.
//

/// Línea de factura. Todos los importes en CENTS.
@freezed
class DomainInvoiceLine with _$DomainInvoiceLine {
  const factory DomainInvoiceLine({
    required String id,
    required String description,

    /// Cantidad. Usamos num porque algunas unidades (kg, h) permiten decimales.
    /// Se serializa como String ISO decimal para no perder precisión.
    required num quantity,

    /// Precio unitario en céntimos (int).
    required int unitPriceCents,

    /// Descuento como porcentaje 0-100 (nullable).
    double? discountPercent,

    /// Tipo de IVA aplicado (enum canónico).
    required VatRate vatRate,

    /// Valor numérico efectivo del tipo IVA (por ej. 21, 10, 4, 0). Permite
    /// representar tipos que cambian sin alterar el enum.
    required double vatRateValue,

    /// Recargo de equivalencia (porcentaje). Sólo aplica en ese régimen.
    double? recargoEquivalenciaRate,

    /// Retención IRPF como porcentaje (ej. 15 para profesionales, 7 nuevos).
    double? irpfRate,

    /// Motivo de exención si [vatRate] == exento (código AEAT: E1, E2, E3, E4, E5, E6).
    String? exemptReason,

    /// Total de la línea en céntimos tras descuento + IVA + recargos − IRPF.
    required int lineTotalCents,
  }) = _DomainInvoiceLine;
}

/// Desglose de IVA agregado por tipo impositivo.
@freezed
class VatBreak with _$VatBreak {
  const factory VatBreak({
    required VatRate rate,
    required double rateValue,

    /// Base imponible en céntimos.
    required int baseCents,

    /// Cuota de IVA en céntimos.
    required int vatCents,

    /// Cuota de recargo de equivalencia en céntimos (0 si no aplica).
    @Default(0) int recargoCents,
  }) = _VatBreak;
}

/// Totales agregados de la factura.
@freezed
class InvoiceTotals with _$InvoiceTotals {
  const factory InvoiceTotals({
    /// Base imponible total en céntimos.
    required int subtotalCents,
    required List<VatBreak> vatBreakdown,

    /// Suma de retenciones IRPF en céntimos.
    @Default(0) int irpfCents,

    /// Total factura en céntimos (subtotal + IVA + recargos − IRPF).
    required int totalCents,

    /// Código ISO-4217.
    @Default('EUR') String currency,
  }) = _InvoiceTotals;
}

/// Datos de compliance y huellas Verifactu / TicketBAI / SII.
@freezed
class ComplianceFlags with _$ComplianceFlags {
  const factory ComplianceFlags({
    /// Identificador TicketBAI (cuando aplica País Vasco).
    String? ticketBaiId,

    /// Huella TBAI (HashTBAI) — SHA-256 del registro de alta.
    String? ticketBaiHash,

    /// Huella Verifactu — SHA-256 de los campos obligatorios (Art. 137 RGAT).
    String? verifactuHash,

    /// Referencia al registro anterior en la cadena Verifactu (encadenado).
    String? verifactuChainRef,

    /// Enviada al SII (Suministro Inmediato de Información).
    @Default(false) bool siiSubmitted,

    /// Timestamp de envío SII si procede.
    DateTime? siiSubmittedAt,
  }) = _ComplianceFlags;
}

/// Condiciones de pago.
@freezed
class PaymentTerms with _$PaymentTerms {
  const factory PaymentTerms({
    /// Método libre (transferencia, tarjeta, domiciliación, efectivo, …).
    required String method,
    String? iban,
    DateTime? dueDate,
  }) = _PaymentTerms;
}

/// Adjunto (PDF, XML Facturae, justificante).
@freezed
class Attachment with _$Attachment {
  const factory Attachment({
    required String id,
    required String filename,
    required String mimeType,
    required int sizeBytes,

    /// URL firmada o ruta relativa en el bucket.
    required String url,
    required DateTime uploadedAt,
  }) = _Attachment;
}

/// Rectificación (factura R1-R5).
@freezed
class Rectification with _$Rectification {
  const factory Rectification({
    /// ID de la factura que rectifica.
    required String originalInvoiceId,

    /// Número legal de la factura rectificada.
    required String originalInvoiceNumber,

    /// Motivo según codificación AEAT (art. 80.Uno LIVA, art. 80.Tres, ...).
    required String reasonCode,
    String? reasonText,

    /// Rectificación por sustitución o por diferencias.
    required bool bySubstitution,
  }) = _Rectification;
}

/// Marca de auditoría — quien tocó qué y cuándo.
@freezed
class AuditStamp with _$AuditStamp {
  const factory AuditStamp({
    required DateTime at,
    required String actorId,
    required String action,
    String? notes,
  }) = _AuditStamp;
}

// ─────────────────────────────────────────────────────────────────────────────
// Root entity
// ─────────────────────────────────────────────────────────────────────────────

/// Entidad canónica de factura en el dominio de TeeDoo.
///
/// Se mapea a [InvoiceMongoModel] (documento embebido) y a
/// [InvoicePostgresModel] (cabecera + tablas hijas). Ambos modelos deben
/// ofrecer round-trip sin pérdida: `Model.fromDomain(e).toDomain() == e`.
@freezed
class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    required String orgId,
    required String series,
    required String number,
    required DateTime issueDate,
    DateTime? operationDate,
    required Party issuer,
    required Party recipient,
    required List<DomainInvoiceLine> lines,
    required InvoiceTotals totals,
    required InvoiceRegime regime,
    required OperationType operationType,
    required FiscalRegion fiscalRegion,
    required ComplianceFlags compliance,
    PaymentTerms? paymentTerms,
    String? notes,
    @Default(<Attachment>[]) List<Attachment> attachments,
    required DomainInvoiceStatus status,
    Rectification? rectification,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(<AuditStamp>[]) List<AuditStamp> audit,
  }) = _Invoice;
}
