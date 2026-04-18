// Fuente fiscal: Real Decreto 1007/2023 (BOE-A-2023-24840) + Real Decreto
// 1619/2012 (Reglamento de facturación) — requisitos de identificación del
// obligado tributario y del destinatario. Verificado 2026-04-18.
//
// Canonical [Party] entity — Phase 2.
//
// Extracted from `lib/features/invoices/domain/invoice.dart` so the dual-DB
// capture can normalise parties into a dedicated table / collection, instead
// of embedding them inline inside invoices (which was a Phase-1 shortcut).
//
// IMPORTANT CONVENTIONS:
//   * `id`: UUID v4 string. Required — a Party is a first-class aggregate
//     persisted before any invoice references it. Fase-1 sintético
//     (`party_${orgId}_${taxId}`) queda prohibido a partir de aquí.
//   * `orgId`: required for tenant scoping (Postgres RLS / Mongo shard key).
//   * `taxId` + `taxIdType`: identifier of the subject (NIF/NIE/CIF/VAT_EU…).
//     Business uniqueness target: (orgId, taxId) — enforced by the server.
//   * Dates are serialised to ISO-8601 in the data-layer models.
//
// `invoice.dart` re-exports `Party`, `PartyAddress` (alias of [Address]) and
// [TaxIdType] via `export 'show ...'` so every existing import path keeps
// compiling unchanged.

import 'package:freezed_annotation/freezed_annotation.dart';

// TODO(phase-2-codegen): run `dart run build_runner build --delete-conflicting-outputs`
// to generate `party.freezed.dart`.
part 'party.freezed.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tax identifier taxonomy (AEAT + intra-EU VIES).
// ─────────────────────────────────────────────────────────────────────────────

/// Tipo de identificador fiscal (alineado con el catálogo AEAT):
///   NIF → DNI español + letra de control.
///   NIE → extranjero residente.
///   CIF → histórico (ahora fundido con NIF para personas jurídicas).
///   VAT_EU → número de IVA intracomunitario (ES, FR, DE, ...).
///   PASSPORT → operaciones no sujetas a identificación fiscal UE.
///   OTHER → cualquier otro.
enum TaxIdType { nif, nie, cif, vatEu, passport, other }

// ─────────────────────────────────────────────────────────────────────────────
// Address
// ─────────────────────────────────────────────────────────────────────────────

/// Dirección postal mínima fiscalmente válida.
///
/// Se mantiene el nombre [Address] por compatibilidad histórica. El alias
/// público [PartyAddress] se expone para consumidores que prefieren el naming
/// normalizado (equivalente semántico al `PartyAddress` del API TypeScript).
@freezed
class Address with _$Address {
  const factory Address({
    required String line1,
    String? line2,
    required String city,
    required String postalCode,
    String? province,

    /// Código ISO-3166-1 alpha-2 (ES, FR, DE ...).
    required String country,
  }) = _Address;
}

/// Alias público — mismo tipo que [Address]. Útil cuando el consumidor quiere
/// nombrarlo de forma explícita como sub-entidad de [Party].
typedef PartyAddress = Address;

// ─────────────────────────────────────────────────────────────────────────────
// Party
// ─────────────────────────────────────────────────────────────────────────────

/// Parte fiscal (emisor o receptor) — entidad canónica.
///
/// Se mapea a [PartyMongoModel] (documento en `parties`) y a
/// [PartyPostgresModel] (fila en `parties`). Ambos modelos deben ofrecer
/// round-trip sin pérdida: `Model.fromDomain(e).toDomain() == e`.
///
/// NOTA sobre `id`: desde Fase 2 este campo es OBLIGATORIO. El backend debe
/// persistir el Party antes de emitir cualquier factura que lo referencie
/// por FK (`issuerId` / `recipientId`).
@freezed
class Party with _$Party {
  const factory Party({
    /// UUID v4. PK lógica (Postgres) / `id` opaco (Mongo — no se mapea a
    /// `_id`, que es gestionado por el servidor).
    required String id,

    /// Tenant. Requerido para RLS (Postgres) y sharding (Mongo).
    required String orgId,

    required String taxId,
    required TaxIdType taxIdType,
    required String name,
    required Address address,

    /// Código ISO-3166-1 alpha-2 — redundante con `address.country` para
    /// acceso rápido en validaciones de sujeto pasivo / inversión del
    /// sujeto pasivo (Art. 84.Uno LIVA).
    required String country,
    String? email,
    String? phone,
  }) = _Party;
}
