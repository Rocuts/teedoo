// Postgres-shaped model for the canonical [Party] entity (Phase 2).
//
// Shape: one row per party in the `parties` table. Address is stored as a
// composable struct — in Postgres it maps to flat columns (`addr_line1`,
// `addr_city`, ...) or a `jsonb` column, depending on the DDL chosen by
// the server. The model keeps them grouped as [AddressPostgresModel] for
// symmetry with Mongo and for zero-branch domain mapping.
//
// Constraints the server must enforce:
//   - PRIMARY KEY (id)
//   - UNIQUE (org_id, tax_id)
//   - org_id checked by RLS policy (Supabase/Neon)
//
// Round-trip:
//   PartyPostgresModel.fromDomain(e).toDomain() == e
//   via toJson → fromJson → toDomain == e

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/party.dart';

// TODO(phase-2-codegen): run `dart run build_runner build --delete-conflicting-outputs`
// to generate `party_postgres_model.freezed.dart` and `.g.dart`.
part 'party_postgres_model.freezed.dart';
part 'party_postgres_model.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Embedded address
// ─────────────────────────────────────────────────────────────────────────────

@freezed
class AddressPostgresModel with _$AddressPostgresModel {
  const factory AddressPostgresModel({
    required String line1,
    String? line2,
    required String city,
    required String postalCode,
    String? province,
    required String country,
  }) = _AddressPostgresModel;

  factory AddressPostgresModel.fromJson(Map<String, dynamic> json) =>
      _$AddressPostgresModelFromJson(json);

  factory AddressPostgresModel.fromDomain(Address a) => AddressPostgresModel(
    line1: a.line1,
    line2: a.line2,
    city: a.city,
    postalCode: a.postalCode,
    province: a.province,
    country: a.country,
  );
}

extension AddressPostgresModelX on AddressPostgresModel {
  Address toDomain() => Address(
    line1: line1,
    line2: line2,
    city: city,
    postalCode: postalCode,
    province: province,
    country: country,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Root row
// ─────────────────────────────────────────────────────────────────────────────

@freezed
class PartyPostgresModel with _$PartyPostgresModel {
  const factory PartyPostgresModel({
    required String id,
    required String orgId,
    required String taxId,
    required String taxIdType,
    required String name,
    required AddressPostgresModel address,
    required String country,
    String? email,
    String? phone,
  }) = _PartyPostgresModel;

  factory PartyPostgresModel.fromJson(Map<String, dynamic> json) =>
      _$PartyPostgresModelFromJson(json);

  factory PartyPostgresModel.fromDomain(Party p) => PartyPostgresModel(
    id: p.id,
    orgId: p.orgId,
    taxId: p.taxId,
    taxIdType: p.taxIdType.name,
    name: p.name,
    address: AddressPostgresModel.fromDomain(p.address),
    country: p.country,
    email: p.email,
    phone: p.phone,
  );
}

extension PartyPostgresModelX on PartyPostgresModel {
  Party toDomain() => Party(
    id: id,
    orgId: orgId,
    taxId: taxId,
    taxIdType: TaxIdType.values.byName(taxIdType),
    name: name,
    address: address.toDomain(),
    country: country,
    email: email,
    phone: phone,
  );
}
