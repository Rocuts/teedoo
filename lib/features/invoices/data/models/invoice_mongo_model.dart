// MongoDB-shaped model for the Phase-1 canonical [Invoice] entity.
//
// Shape: one document per invoice with embedded arrays (lines, vatBreakdown,
// attachments, audit). No Mongo `_id` is mirrored — the server manages it and
// we key on the public UUID `id`.
//
// Dates serialize as ISO-8601 strings. Monetary fields stay as integer cents.
//
// Round-trip guarantee:
//   InvoiceMongoModel.fromDomain(e).toDomain() == e
//   InvoiceMongoModel.fromJson(InvoiceMongoModel.fromDomain(e).toJson())
//     .toDomain() == e
//
// This model lives ALONGSIDE the legacy `invoice_model.dart`; it does not
// replace it. Phase 2 will migrate the wizard to consume this through the
// dual-DB repositories under `api/_lib/db/`.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../parties/data/models/party_mongo_model.dart';
import '../../domain/invoice.dart';

// Re-export so consumers of `invoice_mongo_model.dart` can still resolve
// `PartyMongoModel` / `AddressMongoModel` without importing a second file.
export '../../../parties/data/models/party_mongo_model.dart'
    show PartyMongoModel, AddressMongoModel;

// TODO(phase-1-codegen): run `dart run build_runner build --delete-conflicting-outputs`
// to generate `invoice_mongo_model.freezed.dart` and `invoice_mongo_model.g.dart`.
part 'invoice_mongo_model.freezed.dart';
part 'invoice_mongo_model.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Embedded sub-documents
// ─────────────────────────────────────────────────────────────────────────────
//
// [AddressMongoModel] y [PartyMongoModel] viven ahora en
// `features/parties/data/models/party_mongo_model.dart`. El documento de
// factura sigue embebiendo el Party completo (estrategia doc-store), pero
// utilizando el modelo normalizado para mantener un único shape canónico.

@freezed
class InvoiceLineMongoModel with _$InvoiceLineMongoModel {
  const factory InvoiceLineMongoModel({
    required String id,
    required String description,
    required num quantity,
    required int unitPriceCents,
    double? discountPercent,
    required String vatRate,
    required double vatRateValue,
    double? recargoEquivalenciaRate,
    double? irpfRate,
    String? exemptReason,
    required int lineTotalCents,
  }) = _InvoiceLineMongoModel;

  factory InvoiceLineMongoModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceLineMongoModelFromJson(json);

  factory InvoiceLineMongoModel.fromDomain(DomainInvoiceLine l) =>
      InvoiceLineMongoModel(
        id: l.id,
        description: l.description,
        quantity: l.quantity,
        unitPriceCents: l.unitPriceCents,
        discountPercent: l.discountPercent,
        vatRate: l.vatRate.wireValue,
        vatRateValue: l.vatRateValue,
        recargoEquivalenciaRate: l.recargoEquivalenciaRate,
        irpfRate: l.irpfRate,
        exemptReason: l.exemptReason,
        lineTotalCents: l.lineTotalCents,
      );
}

extension InvoiceLineMongoModelX on InvoiceLineMongoModel {
  DomainInvoiceLine toDomain() => DomainInvoiceLine(
    id: id,
    description: description,
    quantity: quantity,
    unitPriceCents: unitPriceCents,
    discountPercent: discountPercent,
    vatRate: VatRate.fromWire(vatRate),
    vatRateValue: vatRateValue,
    recargoEquivalenciaRate: recargoEquivalenciaRate,
    irpfRate: irpfRate,
    exemptReason: exemptReason,
    lineTotalCents: lineTotalCents,
  );
}

@freezed
class VatBreakMongoModel with _$VatBreakMongoModel {
  const factory VatBreakMongoModel({
    required String rate,
    required double rateValue,
    required int baseCents,
    required int vatCents,
    @Default(0) int recargoCents,
  }) = _VatBreakMongoModel;

  factory VatBreakMongoModel.fromJson(Map<String, dynamic> json) =>
      _$VatBreakMongoModelFromJson(json);

  factory VatBreakMongoModel.fromDomain(VatBreak v) => VatBreakMongoModel(
    rate: v.rate.wireValue,
    rateValue: v.rateValue,
    baseCents: v.baseCents,
    vatCents: v.vatCents,
    recargoCents: v.recargoCents,
  );
}

extension VatBreakMongoModelX on VatBreakMongoModel {
  VatBreak toDomain() => VatBreak(
    rate: VatRate.fromWire(rate),
    rateValue: rateValue,
    baseCents: baseCents,
    vatCents: vatCents,
    recargoCents: recargoCents,
  );
}

@freezed
class InvoiceTotalsMongoModel with _$InvoiceTotalsMongoModel {
  const factory InvoiceTotalsMongoModel({
    required int subtotalCents,
    required List<VatBreakMongoModel> vatBreakdown,
    @Default(0) int irpfCents,
    required int totalCents,
    @Default('EUR') String currency,
  }) = _InvoiceTotalsMongoModel;

  factory InvoiceTotalsMongoModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceTotalsMongoModelFromJson(json);

  factory InvoiceTotalsMongoModel.fromDomain(InvoiceTotals t) =>
      InvoiceTotalsMongoModel(
        subtotalCents: t.subtotalCents,
        vatBreakdown: t.vatBreakdown
            .map(VatBreakMongoModel.fromDomain)
            .toList(),
        irpfCents: t.irpfCents,
        totalCents: t.totalCents,
        currency: t.currency,
      );
}

extension InvoiceTotalsMongoModelX on InvoiceTotalsMongoModel {
  InvoiceTotals toDomain() => InvoiceTotals(
    subtotalCents: subtotalCents,
    vatBreakdown: vatBreakdown.map((e) => e.toDomain()).toList(),
    irpfCents: irpfCents,
    totalCents: totalCents,
    currency: currency,
  );
}

@freezed
class ComplianceFlagsMongoModel with _$ComplianceFlagsMongoModel {
  const factory ComplianceFlagsMongoModel({
    String? ticketBaiId,
    String? ticketBaiHash,
    String? verifactuHash,
    String? verifactuChainRef,
    @Default(false) bool siiSubmitted,

    /// ISO-8601 string; null if not submitted.
    String? siiSubmittedAt,
  }) = _ComplianceFlagsMongoModel;

  factory ComplianceFlagsMongoModel.fromJson(Map<String, dynamic> json) =>
      _$ComplianceFlagsMongoModelFromJson(json);

  factory ComplianceFlagsMongoModel.fromDomain(ComplianceFlags c) =>
      ComplianceFlagsMongoModel(
        ticketBaiId: c.ticketBaiId,
        ticketBaiHash: c.ticketBaiHash,
        verifactuHash: c.verifactuHash,
        verifactuChainRef: c.verifactuChainRef,
        siiSubmitted: c.siiSubmitted,
        siiSubmittedAt: c.siiSubmittedAt?.toIso8601String(),
      );
}

extension ComplianceFlagsMongoModelX on ComplianceFlagsMongoModel {
  ComplianceFlags toDomain() => ComplianceFlags(
    ticketBaiId: ticketBaiId,
    ticketBaiHash: ticketBaiHash,
    verifactuHash: verifactuHash,
    verifactuChainRef: verifactuChainRef,
    siiSubmitted: siiSubmitted,
    siiSubmittedAt: siiSubmittedAt == null
        ? null
        : DateTime.parse(siiSubmittedAt!),
  );
}

@freezed
class PaymentTermsMongoModel with _$PaymentTermsMongoModel {
  const factory PaymentTermsMongoModel({
    required String method,
    String? iban,

    /// ISO-8601 string.
    String? dueDate,
  }) = _PaymentTermsMongoModel;

  factory PaymentTermsMongoModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentTermsMongoModelFromJson(json);

  factory PaymentTermsMongoModel.fromDomain(PaymentTerms p) =>
      PaymentTermsMongoModel(
        method: p.method,
        iban: p.iban,
        dueDate: p.dueDate?.toIso8601String(),
      );
}

extension PaymentTermsMongoModelX on PaymentTermsMongoModel {
  PaymentTerms toDomain() => PaymentTerms(
    method: method,
    iban: iban,
    dueDate: dueDate == null ? null : DateTime.parse(dueDate!),
  );
}

@freezed
class AttachmentMongoModel with _$AttachmentMongoModel {
  const factory AttachmentMongoModel({
    required String id,
    required String filename,
    required String mimeType,
    required int sizeBytes,
    required String url,
    required String uploadedAt,
  }) = _AttachmentMongoModel;

  factory AttachmentMongoModel.fromJson(Map<String, dynamic> json) =>
      _$AttachmentMongoModelFromJson(json);

  factory AttachmentMongoModel.fromDomain(Attachment a) => AttachmentMongoModel(
    id: a.id,
    filename: a.filename,
    mimeType: a.mimeType,
    sizeBytes: a.sizeBytes,
    url: a.url,
    uploadedAt: a.uploadedAt.toIso8601String(),
  );
}

extension AttachmentMongoModelX on AttachmentMongoModel {
  Attachment toDomain() => Attachment(
    id: id,
    filename: filename,
    mimeType: mimeType,
    sizeBytes: sizeBytes,
    url: url,
    uploadedAt: DateTime.parse(uploadedAt),
  );
}

@freezed
class RectificationMongoModel with _$RectificationMongoModel {
  const factory RectificationMongoModel({
    required String originalInvoiceId,
    required String originalInvoiceNumber,
    required String reasonCode,
    String? reasonText,
    required bool bySubstitution,
  }) = _RectificationMongoModel;

  factory RectificationMongoModel.fromJson(Map<String, dynamic> json) =>
      _$RectificationMongoModelFromJson(json);

  factory RectificationMongoModel.fromDomain(Rectification r) =>
      RectificationMongoModel(
        originalInvoiceId: r.originalInvoiceId,
        originalInvoiceNumber: r.originalInvoiceNumber,
        reasonCode: r.reasonCode,
        reasonText: r.reasonText,
        bySubstitution: r.bySubstitution,
      );
}

extension RectificationMongoModelX on RectificationMongoModel {
  Rectification toDomain() => Rectification(
    originalInvoiceId: originalInvoiceId,
    originalInvoiceNumber: originalInvoiceNumber,
    reasonCode: reasonCode,
    reasonText: reasonText,
    bySubstitution: bySubstitution,
  );
}

@freezed
class AuditStampMongoModel with _$AuditStampMongoModel {
  const factory AuditStampMongoModel({
    required String at,
    required String actorId,
    required String action,
    String? notes,
  }) = _AuditStampMongoModel;

  factory AuditStampMongoModel.fromJson(Map<String, dynamic> json) =>
      _$AuditStampMongoModelFromJson(json);

  factory AuditStampMongoModel.fromDomain(AuditStamp s) => AuditStampMongoModel(
    at: s.at.toIso8601String(),
    actorId: s.actorId,
    action: s.action,
    notes: s.notes,
  );
}

extension AuditStampMongoModelX on AuditStampMongoModel {
  AuditStamp toDomain() => AuditStamp(
    at: DateTime.parse(at),
    actorId: actorId,
    action: action,
    notes: notes,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Root document
// ─────────────────────────────────────────────────────────────────────────────

@freezed
class InvoiceMongoModel with _$InvoiceMongoModel {
  const factory InvoiceMongoModel({
    required String id,
    required String orgId,
    required String series,
    required String number,

    /// ISO-8601 string.
    required String issueDate,

    /// ISO-8601 string; null if not set.
    String? operationDate,
    required PartyMongoModel issuer,
    required PartyMongoModel recipient,
    required List<InvoiceLineMongoModel> lines,
    required InvoiceTotalsMongoModel totals,
    required String regime,
    required String operationType,
    required String fiscalRegion,
    required ComplianceFlagsMongoModel compliance,
    PaymentTermsMongoModel? paymentTerms,
    String? notes,
    @Default(<AttachmentMongoModel>[]) List<AttachmentMongoModel> attachments,
    required String status,
    RectificationMongoModel? rectification,
    required String createdAt,
    required String updatedAt,
    @Default(<AuditStampMongoModel>[]) List<AuditStampMongoModel> audit,
  }) = _InvoiceMongoModel;

  factory InvoiceMongoModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceMongoModelFromJson(json);

  factory InvoiceMongoModel.fromDomain(Invoice e) => InvoiceMongoModel(
    id: e.id,
    orgId: e.orgId,
    series: e.series,
    number: e.number,
    issueDate: e.issueDate.toIso8601String(),
    operationDate: e.operationDate?.toIso8601String(),
    issuer: PartyMongoModel.fromDomain(e.issuer),
    recipient: PartyMongoModel.fromDomain(e.recipient),
    lines: e.lines.map(InvoiceLineMongoModel.fromDomain).toList(),
    totals: InvoiceTotalsMongoModel.fromDomain(e.totals),
    regime: e.regime.wireValue,
    operationType: e.operationType.wireValue,
    fiscalRegion: e.fiscalRegion.wireValue,
    compliance: ComplianceFlagsMongoModel.fromDomain(e.compliance),
    paymentTerms: e.paymentTerms == null
        ? null
        : PaymentTermsMongoModel.fromDomain(e.paymentTerms!),
    notes: e.notes,
    attachments: e.attachments.map(AttachmentMongoModel.fromDomain).toList(),
    status: e.status.name,
    rectification: e.rectification == null
        ? null
        : RectificationMongoModel.fromDomain(e.rectification!),
    createdAt: e.createdAt.toIso8601String(),
    updatedAt: e.updatedAt.toIso8601String(),
    audit: e.audit.map(AuditStampMongoModel.fromDomain).toList(),
  );
}

extension InvoiceMongoModelX on InvoiceMongoModel {
  Invoice toDomain() => Invoice(
    id: id,
    orgId: orgId,
    series: series,
    number: number,
    issueDate: DateTime.parse(issueDate),
    operationDate: operationDate == null
        ? null
        : DateTime.parse(operationDate!),
    issuer: issuer.toDomain(),
    recipient: recipient.toDomain(),
    lines: lines.map((e) => e.toDomain()).toList(),
    totals: totals.toDomain(),
    regime: InvoiceRegime.fromWire(regime),
    operationType: OperationType.fromWire(operationType),
    fiscalRegion: FiscalRegion.fromWire(fiscalRegion),
    compliance: compliance.toDomain(),
    paymentTerms: paymentTerms?.toDomain(),
    notes: notes,
    attachments: attachments.map((e) => e.toDomain()).toList(),
    status: DomainInvoiceStatus.values.byName(status),
    rectification: rectification?.toDomain(),
    createdAt: DateTime.parse(createdAt),
    updatedAt: DateTime.parse(updatedAt),
    audit: audit.map((e) => e.toDomain()).toList(),
  );
}
