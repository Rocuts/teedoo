/// Tipo de impuesto al que aplica la regla.
enum TaxType { irpf, iva, sociedades, ibi, iae }

/// Nivel de riesgo de una evaluación fiscal.
enum RiskLevel { low, medium, high, critical }

/// Nivel de confianza en el resultado de la evaluación.
enum ConfidenceLevel { high, medium, low }

/// Tipo de contribuyente al que aplica la regla.
enum ContributorType { autonomo, sociedad, ambos }

/// Regla fiscal abstracta con metadatos.
///
/// Define una regla fiscal con su identificador, tipo de impuesto,
/// artículo de referencia legal, y condiciones de aplicabilidad
/// (tipo de contribuyente, comunidades autónomas, ejercicio fiscal).
class FiscalRule {
  final String id;
  final String name;
  final String description;
  final TaxType taxType;
  final String legalReference;
  final ContributorType contributorType;
  final List<String> applicableCommunities;
  final int fiscalYearFrom;
  final int? fiscalYearTo;
  final RiskLevel defaultRisk;
  final bool isActive;
  final DateTime createdAt;

  const FiscalRule({
    required this.id,
    required this.name,
    required this.description,
    required this.taxType,
    required this.legalReference,
    this.contributorType = ContributorType.ambos,
    this.applicableCommunities = const [],
    required this.fiscalYearFrom,
    this.fiscalYearTo,
    this.defaultRisk = RiskLevel.low,
    this.isActive = true,
    required this.createdAt,
  });

  /// Indica si la regla aplica a un ejercicio fiscal concreto.
  bool appliesTo({required int fiscalYear}) {
    if (fiscalYear < fiscalYearFrom) return false;
    if (fiscalYearTo != null && fiscalYear > fiscalYearTo!) return false;
    return true;
  }

  /// Indica si la regla aplica a una comunidad autónoma concreta.
  /// Lista vacía significa que aplica a todas.
  bool appliesToCommunity(String community) {
    if (applicableCommunities.isEmpty) return true;
    return applicableCommunities.contains(community);
  }

  /// Indica si la regla aplica a un tipo de contribuyente.
  bool appliesToContributor(ContributorType type) {
    if (contributorType == ContributorType.ambos) return true;
    return contributorType == type;
  }

  FiscalRule copyWith({
    String? id,
    String? name,
    String? description,
    TaxType? taxType,
    String? legalReference,
    ContributorType? contributorType,
    List<String>? applicableCommunities,
    int? fiscalYearFrom,
    int? fiscalYearTo,
    RiskLevel? defaultRisk,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return FiscalRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      taxType: taxType ?? this.taxType,
      legalReference: legalReference ?? this.legalReference,
      contributorType: contributorType ?? this.contributorType,
      applicableCommunities:
          applicableCommunities ?? this.applicableCommunities,
      fiscalYearFrom: fiscalYearFrom ?? this.fiscalYearFrom,
      fiscalYearTo: fiscalYearTo ?? this.fiscalYearTo,
      defaultRisk: defaultRisk ?? this.defaultRisk,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
