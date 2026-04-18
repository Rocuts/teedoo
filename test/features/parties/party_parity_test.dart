// Phase-2 parity tests for the dual-DB Party aggregate.
//
// Guarantees that the canonical [Party] entity round-trips losslessly through
// both data models (Mongo + Postgres), both via direct `fromDomain → toDomain`
// and via the JSON boundary.
//
// NOTE: this file depends on `*.freezed.dart` / `*.g.dart` generated files.
// Run `dart run build_runner build --delete-conflicting-outputs` before
// `flutter test`.

import 'package:flutter_test/flutter_test.dart';

import 'package:teedoo/features/parties/domain/party.dart';
import 'package:teedoo/features/parties/data/models/party_mongo_model.dart';
import 'package:teedoo/features/parties/data/models/party_postgres_model.dart';

Party _buildIssuer() => const Party(
  id: 'aaaaaaaa-1111-4111-8111-111111111111',
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
);

Party _buildRecipient() => const Party(
  id: 'bbbbbbbb-2222-4222-8222-222222222222',
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
);

Party _buildIntraEu() => const Party(
  id: 'cccccccc-3333-4333-8333-333333333333',
  orgId: 'org_aurora_01',
  taxId: 'DE123456789',
  taxIdType: TaxIdType.vatEu,
  name: 'Cliente Alemán GmbH',
  address: Address(
    line1: 'Unter den Linden 5',
    city: 'Berlin',
    postalCode: '10117',
    country: 'DE',
  ),
  country: 'DE',
);

void main() {
  group('Party parity — Mongo', () {
    test('issuer fromDomain → toDomain round-trip is lossless', () {
      final p = _buildIssuer();
      final m = PartyMongoModel.fromDomain(p);
      expect(m.toDomain(), equals(p));
    });

    test('recipient fromDomain → toDomain round-trip is lossless', () {
      final p = _buildRecipient();
      final m = PartyMongoModel.fromDomain(p);
      expect(m.toDomain(), equals(p));
    });

    test('intra-EU (VAT) fromDomain → toDomain round-trip is lossless', () {
      final p = _buildIntraEu();
      final m = PartyMongoModel.fromDomain(p);
      expect(m.toDomain(), equals(p));
    });

    test('JSON boundary round-trip is lossless', () {
      final p = _buildIssuer();
      final m1 = PartyMongoModel.fromDomain(p);
      final json = m1.toJson();
      final m2 = PartyMongoModel.fromJson(json);
      expect(m2, equals(m1));
      expect(m2.toDomain(), equals(p));
    });

    test('taxIdType serialises as enum name', () {
      final p = _buildIntraEu();
      final json = PartyMongoModel.fromDomain(p).toJson();
      expect(json['taxIdType'], 'vatEu');
    });
  });

  group('Party parity — Postgres', () {
    test('issuer fromDomain → toDomain round-trip is lossless', () {
      final p = _buildIssuer();
      final m = PartyPostgresModel.fromDomain(p);
      expect(m.toDomain(), equals(p));
    });

    test('recipient fromDomain → toDomain round-trip is lossless', () {
      final p = _buildRecipient();
      final m = PartyPostgresModel.fromDomain(p);
      expect(m.toDomain(), equals(p));
    });

    test('intra-EU (VAT) fromDomain → toDomain round-trip is lossless', () {
      final p = _buildIntraEu();
      final m = PartyPostgresModel.fromDomain(p);
      expect(m.toDomain(), equals(p));
    });

    test('JSON boundary round-trip is lossless', () {
      final p = _buildIssuer();
      final m1 = PartyPostgresModel.fromDomain(p);
      final json = m1.toJson();
      final m2 = PartyPostgresModel.fromJson(json);
      expect(m2, equals(m1));
      expect(m2.toDomain(), equals(p));
    });

    test('id + orgId are preserved end-to-end', () {
      final p = _buildIssuer();
      final m = PartyPostgresModel.fromDomain(p);
      expect(m.id, p.id);
      expect(m.orgId, p.orgId);
    });
  });

  group('Cross-model equivalence', () {
    test('Mongo and Postgres both round-trip to the same domain value', () {
      final p = _buildIssuer();
      final viaMongo = PartyMongoModel.fromDomain(p).toDomain();
      final viaPg = PartyPostgresModel.fromDomain(p).toDomain();
      expect(viaMongo, equals(viaPg));
      expect(viaMongo, equals(p));
    });
  });
}
