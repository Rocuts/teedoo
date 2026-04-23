// MongoDB-shaped model for the canonical [Party] entity (Phase 2).
//
// Shape: one document per party in the `parties` collection. Address is
// embedded. No Mongo `_id` is mirrored — the server manages it and we key
// on the public UUID `id`.
//
// Uniqueness target (enforced server-side via a compound index):
//   { orgId: 1, taxId: 1 } unique.
//
// Round-trip guarantee:
//   PartyMongoModel.fromDomain(e).toDomain() == e
//   PartyMongoModel.fromJson(PartyMongoModel.fromDomain(e).toJson())
//     .toDomain() == e

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/party.dart';

// TODO(phase-2-codegen): run `dart run build_runner build --delete-conflicting-outputs`
// to generate `party_mongo_model.freezed.dart` and `party_mongo_model.g.dart`.
part 'party_mongo_model.freezed.dart';
part 'party_mongo_model.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Embedded address
// ─────────────────────────────────────────────────────────────────────────────

@freezed
abstract class AddressMongoModel with _$AddressMongoModel {
  const factory AddressMongoModel({
    required String line1,
    String? line2,
    required String city,
    required String postalCode,
    String? province,
    required String country,
  }) = _AddressMongoModel;

  factory AddressMongoModel.fromJson(Map<String, dynamic> json) =>
      _$AddressMongoModelFromJson(json);

  factory AddressMongoModel.fromDomain(Address a) => AddressMongoModel(
    line1: a.line1,
    line2: a.line2,
    city: a.city,
    postalCode: a.postalCode,
    province: a.province,
    country: a.country,
  );
}

extension AddressMongoModelX on AddressMongoModel {
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
// Root document
// ─────────────────────────────────────────────────────────────────────────────

@freezed
abstract class PartyMongoModel with _$PartyMongoModel {
  const factory PartyMongoModel({
    required String id,
    required String orgId,
    required String taxId,

    /// Stored as canonical wire value (`NIF`, `NIE`, `NIF_IVA`, ...) —
    /// SCREAMING_SNAKE_CASE per spec 2026-04-18; filterable in Atlas.
    required String taxIdType,
    required String name,
    required AddressMongoModel address,
    required String country,
    String? email,
    String? phone,
  }) = _PartyMongoModel;

  factory PartyMongoModel.fromJson(Map<String, dynamic> json) =>
      _$PartyMongoModelFromJson(json);

  factory PartyMongoModel.fromDomain(Party p) => PartyMongoModel(
    id: p.id,
    orgId: p.orgId,
    taxId: p.taxId,
    taxIdType: p.taxIdType.wireValue,
    name: p.name,
    address: AddressMongoModel.fromDomain(p.address),
    country: p.country,
    email: p.email,
    phone: p.phone,
  );
}

extension PartyMongoModelX on PartyMongoModel {
  Party toDomain() => Party(
    id: id,
    orgId: orgId,
    taxId: taxId,
    taxIdType: TaxIdType.fromWire(taxIdType),
    name: name,
    address: address.toDomain(),
    country: country,
    email: email,
    phone: phone,
  );
}
