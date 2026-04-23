// Postgres-shaped model for the canonical [Invoice] entity (Phase 2).
//
// Shape: flat header + explicit child rows. The server-side repository will
// INSERT into `invoices`, `invoice_lines`, `vat_breakdown`, `attachments`,
// `audit_log`. Parties live in their own table `parties` and are referenced
// by `issuer_id` / `recipient_id` — they are PRE-PERSISTED, not embedded.
//
// Timestamps serialize to ISO-8601 strings; Postgres column type is `timestamptz`.
// Monetary values are integer cents (`BIGINT` on server).
//
// FK fields:
//   - `issuerId` / `recipientId` → `parties.id`. Callers MUST ensure the
//     parties exist before writing the invoice; there is no upsert fallback
//     here (Fase-1 sintetizaba PKs como `party_${orgId}_${taxId}` — ya no).
//   - `orgId` is required on every row (RLS scope).
//
// Round-trip:
//   InvoicePostgresModel.fromDomain(e).toDomain() == e
//   via toJson → fromJson → toDomain  == e
//
// Coexists with the legacy `invoice_model.dart`; no presentation layer
// touches this yet.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/invoice.dart';

// Re-export party-side models so callers of `invoice_postgres_model.dart`
// who orchestrate the full aggregate (invoice + parties) don't need two
// imports. The invoice model itself only stores `issuerId` / `recipientId`.
export '../../../parties/data/models/party_postgres_model.dart'
    show PartyPostgresModel, AddressPostgresModel;

// TODO(phase-2-codegen): run `dart run build_runner build --delete-conflicting-outputs`
// to generate `invoice_postgres_model.freezed.dart` and `.g.dart`.
part 'invoice_postgres_model.freezed.dart';
part 'invoice_postgres_model.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Child rows
// ─────────────────────────────────────────────────────────────────────────────

@freezed
abstract class InvoiceLinePostgresModel with _$InvoiceLinePostgresModel {
  const factory InvoiceLinePostgresModel({
    required String id,
    required String invoiceId,
    required String orgId,
    /// 0-based position, for stable ordering.
    required int position,
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
  }) = _InvoiceLinePostgresModel;

  factory InvoiceLinePostgresModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceLinePostgresModelFromJson(json);

  factory InvoiceLinePostgresModel.fromDomain({
    required String invoiceId,
    required String orgId,
    required int position,
    required DomainInvoiceLine l,
  }) =>
      InvoiceLinePostgresModel(
        id: l.id,
        invoiceId: invoiceId,
        orgId: orgId,
        position: position,
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

extension InvoiceLinePostgresModelX on InvoiceLinePostgresModel {
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
abstract class VatBreakdownPostgresModel with _$VatBreakdownPostgresModel {
  const factory VatBreakdownPostgresModel({
    required String invoiceId,
    required String orgId,
    required int position,
    required String rate,
    required double rateValue,
    required int baseCents,
    required int vatCents,
    @Default(0) int recargoCents,
  }) = _VatBreakdownPostgresModel;

  factory VatBreakdownPostgresModel.fromJson(Map<String, dynamic> json) =>
      _$VatBreakdownPostgresModelFromJson(json);

  factory VatBreakdownPostgresModel.fromDomain({
    required String invoiceId,
    required String orgId,
    required int position,
    required VatBreak v,
  }) =>
      VatBreakdownPostgresModel(
        invoiceId: invoiceId,
        orgId: orgId,
        position: position,
        rate: v.rate.wireValue,
        rateValue: v.rateValue,
        baseCents: v.baseCents,
        vatCents: v.vatCents,
        recargoCents: v.recargoCents,
      );
}

extension VatBreakdownPostgresModelX on VatBreakdownPostgresModel {
  VatBreak toDomain() => VatBreak(
        rate: VatRate.fromWire(rate),
        rateValue: rateValue,
        baseCents: baseCents,
        vatCents: vatCents,
        recargoCents: recargoCents,
      );
}

@freezed
abstract class AttachmentPostgresModel with _$AttachmentPostgresModel {
  const factory AttachmentPostgresModel({
    required String id,
    required String invoiceId,
    required String orgId,
    required String filename,
    required String mimeType,
    required int sizeBytes,
    required String url,
    required String uploadedAt,
  }) = _AttachmentPostgresModel;

  factory AttachmentPostgresModel.fromJson(Map<String, dynamic> json) =>
      _$AttachmentPostgresModelFromJson(json);

  factory AttachmentPostgresModel.fromDomain({
    required String invoiceId,
    required String orgId,
    required Attachment a,
  }) =>
      AttachmentPostgresModel(
        id: a.id,
        invoiceId: invoiceId,
        orgId: orgId,
        filename: a.filename,
        mimeType: a.mimeType,
        sizeBytes: a.sizeBytes,
        url: a.url,
        uploadedAt: a.uploadedAt.toIso8601String(),
      );
}

extension AttachmentPostgresModelX on AttachmentPostgresModel {
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
abstract class AuditStampPostgresModel with _$AuditStampPostgresModel {
  const factory AuditStampPostgresModel({
    required String invoiceId,
    required String orgId,
    required int position,
    required String at,
    required String actorId,
    required String action,
    String? notes,
  }) = _AuditStampPostgresModel;

  factory AuditStampPostgresModel.fromJson(Map<String, dynamic> json) =>
      _$AuditStampPostgresModelFromJson(json);

  factory AuditStampPostgresModel.fromDomain({
    required String invoiceId,
    required String orgId,
    required int position,
    required AuditStamp s,
  }) =>
      AuditStampPostgresModel(
        invoiceId: invoiceId,
        orgId: orgId,
        position: position,
        at: s.at.toIso8601String(),
        actorId: s.actorId,
        action: s.action,
        notes: s.notes,
      );
}

extension AuditStampPostgresModelX on AuditStampPostgresModel {
  AuditStamp toDomain() => AuditStamp(
        at: DateTime.parse(at),
        actorId: actorId,
        action: action,
        notes: notes,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Flat header
// ─────────────────────────────────────────────────────────────────────────────

@freezed
abstract class InvoicePostgresModel with _$InvoicePostgresModel {
  const factory InvoicePostgresModel({
    required String id,
    required String orgId,
    required String series,
    required String number,
    required String issueDate,
    String? operationDate,
    // Party FKs → `parties.id`. The referenced Party rows are written
    // separately via [PartyPostgresModel] on the `parties` table.
    required String issuerId,
    required String recipientId,
    // Totals columns (flat on header — denormalised for fast list views).
    required int subtotalCents,
    @Default(0) int irpfCents,
    required int totalCents,
    @Default('EUR') String currency,
    // Fiscal metadata.
    required String regime,
    required String operationType,
    required String fiscalRegion,
    // Compliance columns.
    String? ticketBaiId,
    String? ticketBaiHash,
    String? verifactuHash,
    String? verifactuChainRef,
    @Default(false) bool siiSubmitted,
    String? siiSubmittedAt,
    // Payment.
    String? paymentMethod,
    String? paymentIban,
    String? paymentDueDate,
    // Rectification (flat on header; null → not a rectifying invoice).
    String? rectifiesInvoiceId,
    String? rectifiesInvoiceNumber,
    String? rectificationReasonCode,
    String? rectificationReasonText,
    bool? rectificationBySubstitution,
    String? notes,
    required String status,
    required String createdAt,
    required String updatedAt,
    // Child rows (explicit lists).
    required List<InvoiceLinePostgresModel> lines,
    required List<VatBreakdownPostgresModel> vatBreakdown,
    @Default(<AttachmentPostgresModel>[])
    List<AttachmentPostgresModel> attachments,
    @Default(<AuditStampPostgresModel>[])
    List<AuditStampPostgresModel> audit,
  }) = _InvoicePostgresModel;

  factory InvoicePostgresModel.fromJson(Map<String, dynamic> json) =>
      _$InvoicePostgresModelFromJson(json);

  /// Build a Postgres aggregate from the domain entity.
  ///
  /// Assumes `e.issuer.id` and `e.recipient.id` are already populated (the
  /// Party aggregates have been persisted beforehand). This method does
  /// **not** synthesise PKs.
  factory InvoicePostgresModel.fromDomain(Invoice e) {
    assert(
      e.issuer.id.isNotEmpty && e.recipient.id.isNotEmpty,
      'Party ids must be set before persisting the invoice '
      '(issuer.id="${e.issuer.id}", recipient.id="${e.recipient.id}"). '
      'Write parties to the parties repo first.',
    );
    return InvoicePostgresModel(
      id: e.id,
      orgId: e.orgId,
      series: e.series,
      number: e.number,
      issueDate: e.issueDate.toIso8601String(),
      operationDate: e.operationDate?.toIso8601String(),
      issuerId: e.issuer.id,
      recipientId: e.recipient.id,
      subtotalCents: e.totals.subtotalCents,
      irpfCents: e.totals.irpfCents,
      totalCents: e.totals.totalCents,
      currency: e.totals.currency,
      regime: e.regime.wireValue,
      operationType: e.operationType.wireValue,
      fiscalRegion: e.fiscalRegion.wireValue,
      ticketBaiId: e.compliance.ticketBaiId,
      ticketBaiHash: e.compliance.ticketBaiHash,
      verifactuHash: e.compliance.verifactuHash,
      verifactuChainRef: e.compliance.verifactuChainRef,
      siiSubmitted: e.compliance.siiSubmitted,
      siiSubmittedAt: e.compliance.siiSubmittedAt?.toIso8601String(),
      paymentMethod: e.paymentTerms?.method,
      paymentIban: e.paymentTerms?.iban,
      paymentDueDate: e.paymentTerms?.dueDate?.toIso8601String(),
      rectifiesInvoiceId: e.rectification?.originalInvoiceId,
      rectifiesInvoiceNumber: e.rectification?.originalInvoiceNumber,
      rectificationReasonCode: e.rectification?.reasonCode,
      rectificationReasonText: e.rectification?.reasonText,
      rectificationBySubstitution: e.rectification?.bySubstitution,
      notes: e.notes,
      status: e.status.name,
      createdAt: e.createdAt.toIso8601String(),
      updatedAt: e.updatedAt.toIso8601String(),
      lines: [
        for (int i = 0; i < e.lines.length; i++)
          InvoiceLinePostgresModel.fromDomain(
            invoiceId: e.id,
            orgId: e.orgId,
            position: i,
            l: e.lines[i],
          ),
      ],
      vatBreakdown: [
        for (int i = 0; i < e.totals.vatBreakdown.length; i++)
          VatBreakdownPostgresModel.fromDomain(
            invoiceId: e.id,
            orgId: e.orgId,
            position: i,
            v: e.totals.vatBreakdown[i],
          ),
      ],
      attachments: [
        for (final a in e.attachments)
          AttachmentPostgresModel.fromDomain(
            invoiceId: e.id,
            orgId: e.orgId,
            a: a,
          ),
      ],
      audit: [
        for (int i = 0; i < e.audit.length; i++)
          AuditStampPostgresModel.fromDomain(
            invoiceId: e.id,
            orgId: e.orgId,
            position: i,
            s: e.audit[i],
          ),
      ],
    );
  }
}

extension InvoicePostgresModelX on InvoicePostgresModel {
  /// Rehydrate a full [Invoice] aggregate. Parties are NOT stored inside the
  /// invoice row — they must be fetched from the `parties` repo and passed
  /// in explicitly by the repository/orchestrator.
  ///
  /// The provided [issuer] / [recipient] MUST match `issuerId` / `recipientId`
  /// — otherwise an [AssertionError] is raised in debug.
  Invoice toDomain({required Party issuer, required Party recipient}) {
    assert(
      issuer.id == issuerId,
      'issuer.id=${issuer.id} does not match FK issuerId=$issuerId',
    );
    assert(
      recipient.id == recipientId,
      'recipient.id=${recipient.id} does not match FK recipientId=$recipientId',
    );

    final Rectification? rect = rectifiesInvoiceId == null
        ? null
        : Rectification(
            originalInvoiceId: rectifiesInvoiceId!,
            originalInvoiceNumber: rectifiesInvoiceNumber ?? '',
            reasonCode: rectificationReasonCode ?? '',
            reasonText: rectificationReasonText,
            bySubstitution: rectificationBySubstitution ?? false,
          );

    final PaymentTerms? payment = paymentMethod == null
        ? null
        : PaymentTerms(
            method: paymentMethod!,
            iban: paymentIban,
            dueDate:
                paymentDueDate == null ? null : DateTime.parse(paymentDueDate!),
          );

    return Invoice(
      id: id,
      orgId: orgId,
      series: series,
      number: number,
      issueDate: DateTime.parse(issueDate),
      operationDate:
          operationDate == null ? null : DateTime.parse(operationDate!),
      issuer: issuer,
      recipient: recipient,
      lines: [
        for (final l in ([...lines]..sort((a, b) => a.position.compareTo(b.position))))
          l.toDomain(),
      ],
      totals: InvoiceTotals(
        subtotalCents: subtotalCents,
        vatBreakdown: [
          for (final v in ([...vatBreakdown]
            ..sort((a, b) => a.position.compareTo(b.position))))
            v.toDomain(),
        ],
        irpfCents: irpfCents,
        totalCents: totalCents,
        currency: currency,
      ),
      regime: InvoiceRegime.fromWire(regime),
      operationType: OperationType.fromWire(operationType),
      fiscalRegion: FiscalRegion.fromWire(fiscalRegion),
      compliance: ComplianceFlags(
        ticketBaiId: ticketBaiId,
        ticketBaiHash: ticketBaiHash,
        verifactuHash: verifactuHash,
        verifactuChainRef: verifactuChainRef,
        siiSubmitted: siiSubmitted,
        siiSubmittedAt:
            siiSubmittedAt == null ? null : DateTime.parse(siiSubmittedAt!),
      ),
      paymentTerms: payment,
      notes: notes,
      attachments: [for (final a in attachments) a.toDomain()],
      status: DomainInvoiceStatus.values.byName(status),
      rectification: rect,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      audit: [
        for (final s in ([...audit]..sort((a, b) => a.position.compareTo(b.position))))
          s.toDomain(),
      ],
    );
  }
}
