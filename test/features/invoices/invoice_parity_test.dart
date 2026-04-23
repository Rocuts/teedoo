// Phase-1 parity tests for the dual-DB invoice capture.
//
// Goal: guarantee that the canonical [Invoice] entity round-trips through
// BOTH data models (Mongo + Postgres) without loss — both via direct
// `fromDomain → toDomain` and via the JSON boundary (`toJson → fromJson`).
//
// NOTE: this file depends on `*.freezed.dart` / `*.g.dart` generated files.
// Run `dart run build_runner build --delete-conflicting-outputs` before
// `flutter test`.

import 'package:flutter_test/flutter_test.dart';

import 'package:teedoo/features/invoices/domain/invoice.dart';
import 'package:teedoo/features/invoices/data/models/invoice_mongo_model.dart';
import 'package:teedoo/features/invoices/data/models/invoice_postgres_model.dart';
import 'package:teedoo/features/invoices/data/models/invoice_model.dart'
    show InvoiceStatus;

// UUIDs v4 fijos para que el round-trip sea determinista.
const String _issuerUuid = 'aaaaaaaa-1111-4111-8111-111111111111';
const String _recipientUuid = 'bbbbbbbb-2222-4222-8222-222222222222';

/// Builds a fully-populated [Invoice] with 3 lines, 2 VAT breakdowns,
/// 1 attachment, 1 audit stamp, payment terms and compliance hashes.
Invoice _buildFixture() {
  final DateTime issue = DateTime.utc(2026, 4, 18, 9, 30);
  final DateTime created = DateTime.utc(2026, 4, 18, 9, 29, 55);
  final DateTime updated = DateTime.utc(2026, 4, 18, 9, 31, 12);

  return Invoice(
    id: '11111111-2222-4333-8444-555555555555',
    orgId: 'org_aurora_01',
    series: 'A',
    number: '2026/0042',
    issueDate: issue,
    operationDate: issue,
    issuer: const Party(
      id: _issuerUuid,
      orgId: 'org_aurora_01',
      taxId: 'B12345678',
      taxIdType: TaxIdType.nif,
      name: 'Aurora Studios SL',
      address: Address(
        line1: 'Gran Via 1',
        line2: '3º B',
        city: 'Madrid',
        postalCode: '28013',
        province: 'Madrid',
        country: 'ES',
      ),
      country: 'ES',
      email: 'facturacion@aurora.example',
      phone: '+34 910 000 000',
    ),
    recipient: const Party(
      id: _recipientUuid,
      orgId: 'org_aurora_01',
      taxId: 'A87654321',
      taxIdType: TaxIdType.nif,
      name: 'Cliente Peninsular SA',
      address: Address(
        line1: 'Carrer de Balmes 100',
        city: 'Barcelona',
        postalCode: '08008',
        province: 'Barcelona',
        country: 'ES',
      ),
      country: 'ES',
    ),
    lines: const [
      DomainInvoiceLine(
        id: 'line-1',
        description: 'Consultoría estratégica (abril)',
        quantity: 10,
        unitPriceCents: 15000, // 150.00 €
        vatRate: VatRate.general,
        vatRateValue: 21,
        irpfRate: 15,
        lineTotalCents: 156000, // 1500 + 315 IVA - 225 IRPF = 1590.00€ → cents
      ),
      DomainInvoiceLine(
        id: 'line-2',
        description: 'Libro técnico',
        quantity: 2,
        unitPriceCents: 2500,
        discountPercent: 10,
        vatRate: VatRate.superReducido,
        vatRateValue: 4,
        lineTotalCents: 4680,
      ),
      DomainInvoiceLine(
        id: 'line-3',
        description: 'Servicio exento (formación)',
        quantity: 1,
        unitPriceCents: 30000,
        vatRate: VatRate.exento,
        vatRateValue: 0,
        exemptReason: 'E1',
        lineTotalCents: 30000,
      ),
    ],
    totals: const InvoiceTotals(
      subtotalCents: 184500, // 150000 + 4500 + 30000
      vatBreakdown: [
        VatBreak(
          rate: VatRate.general,
          rateValue: 21,
          baseCents: 150000,
          vatCents: 31500,
        ),
        VatBreak(
          rate: VatRate.superReducido,
          rateValue: 4,
          baseCents: 4500,
          vatCents: 180,
        ),
      ],
      irpfCents: 22500,
      totalCents: 193680,
      currency: 'EUR',
    ),
    regime: InvoiceRegime.general,
    operationType: OperationType.f1,
    fiscalRegion: FiscalRegion.peninsulaBaleares,
    compliance: const ComplianceFlags(
      verifactuHash:
          'a3f1c2b3d4e5f6071829304152637485a3f1c2b3d4e5f6071829304152637485',
      verifactuChainRef: 'PREV_2026_0041',
      siiSubmitted: false,
    ),
    paymentTerms: PaymentTerms(
      method: 'transferencia',
      iban: 'ES76 1234 5678 9012 3456 7890',
      dueDate: DateTime.utc(2026, 5, 18),
    ),
    notes: 'Factura de prueba para parity test.',
    attachments: [
      Attachment(
        id: 'att-1',
        filename: 'factura-2026-0042.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 184_320,
        url: 'https://blob.example/att-1.pdf',
        uploadedAt: DateTime.utc(2026, 4, 18, 9, 31),
      ),
    ],
    status: InvoiceStatus.readyToSend,
    rectification: null,
    createdAt: created,
    updatedAt: updated,
    audit: [
      AuditStamp(
        at: DateTime.utc(2026, 4, 18, 9, 30, 10),
        actorId: 'user_admin_01',
        action: 'created',
        notes: 'Draft desde wizard',
      ),
    ],
  );
}

void main() {
  group('Invoice parity — Mongo', () {
    test('fromDomain → toDomain round-trip is lossless', () {
      final e = _buildFixture();
      final m = InvoiceMongoModel.fromDomain(e);
      final back = m.toDomain();
      expect(back, equals(e));
    });

    test('JSON boundary round-trip is lossless', () {
      final e = _buildFixture();
      final m1 = InvoiceMongoModel.fromDomain(e);
      final json = m1.toJson();
      final m2 = InvoiceMongoModel.fromJson(json);
      expect(m2, equals(m1));
      expect(m2.toDomain(), equals(e));
    });
  });

  group('Invoice parity — Postgres', () {
    test('fromDomain → toDomain round-trip is lossless', () {
      final e = _buildFixture();
      final p = InvoicePostgresModel.fromDomain(e);
      final back = p.toDomain(issuer: e.issuer, recipient: e.recipient);
      expect(back, equals(e));
    });

    test('JSON boundary round-trip is lossless', () {
      final e = _buildFixture();
      final p1 = InvoicePostgresModel.fromDomain(e);
      final json = p1.toJson();
      final p2 = InvoicePostgresModel.fromJson(json);
      expect(p2, equals(p1));
      expect(
        p2.toDomain(issuer: e.issuer, recipient: e.recipient),
        equals(e),
      );
    });

    test('FK ids match the party aggregates', () {
      final e = _buildFixture();
      final p = InvoicePostgresModel.fromDomain(e);
      expect(p.issuerId, e.issuer.id);
      expect(p.recipientId, e.recipient.id);
    });

    test('orgId propagates onto every child row', () {
      final e = _buildFixture();
      final p = InvoicePostgresModel.fromDomain(e);
      expect(p.orgId, e.orgId);
      for (final l in p.lines) {
        expect(l.orgId, e.orgId);
        expect(l.invoiceId, e.id);
      }
      for (final v in p.vatBreakdown) {
        expect(v.orgId, e.orgId);
        expect(v.invoiceId, e.id);
      }
      for (final a in p.attachments) {
        expect(a.orgId, e.orgId);
        expect(a.invoiceId, e.id);
      }
      for (final s in p.audit) {
        expect(s.orgId, e.orgId);
        expect(s.invoiceId, e.id);
      }
    });
  });

  group('Cross-model equivalence', () {
    test('Mongo and Postgres both round-trip to the same domain value', () {
      final e = _buildFixture();
      final viaMongo = InvoiceMongoModel.fromDomain(e).toDomain();
      final viaPg = InvoicePostgresModel.fromDomain(
        e,
      ).toDomain(issuer: e.issuer, recipient: e.recipient);
      expect(viaMongo, equals(viaPg));
      expect(viaMongo, equals(e));
    });
  });
}
