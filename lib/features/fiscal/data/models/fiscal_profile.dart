/// Forma jurídica del contribuyente.
enum LegalForm {
  autonomo,
  sociedadLimitada,
  sociedadAnonima,
  cooperativa,
  comunidadBienes,
  sociedadCivil,
}

/// Régimen fiscal aplicable.
enum FiscalRegime {
  estimacionDirectaSimplificada,
  estimacionDirectaNormal,
  estimacionObjetiva,
  regimenGeneral,
}

/// Régimen de IVA aplicable.
enum IvaRegime { general, simplificado, recargo, exento, prorata }

/// Perfil fiscal del contribuyente.
///
/// Contiene toda la información fiscal del usuario necesaria
/// para evaluar reglas de optimización: forma jurídica, régimen
/// fiscal e IVA, comunidad autónoma y epígrafe IAE.
class FiscalProfile {
  final String id;
  final String userId;
  final LegalForm legalForm;
  final FiscalRegime fiscalRegime;
  final IvaRegime ivaRegime;
  final String nif;
  final String autonomousCommunity;
  final String iaeCode;
  final String iaeDescription;
  final double annualRevenue;
  final double annualExpenses;
  final bool worksFromHome;
  final double? homeOfficePercentage;
  final int fiscalYear;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FiscalProfile({
    required this.id,
    required this.userId,
    required this.legalForm,
    required this.fiscalRegime,
    required this.ivaRegime,
    required this.nif,
    required this.autonomousCommunity,
    required this.iaeCode,
    required this.iaeDescription,
    required this.annualRevenue,
    required this.annualExpenses,
    this.worksFromHome = false,
    this.homeOfficePercentage,
    required this.fiscalYear,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Indica si el contribuyente es autónomo (persona física).
  bool get isAutonomo => legalForm == LegalForm.autonomo;

  /// Indica si el contribuyente tributa en estimación directa.
  bool get isEstimacionDirecta =>
      fiscalRegime == FiscalRegime.estimacionDirectaSimplificada ||
      fiscalRegime == FiscalRegime.estimacionDirectaNormal;

  /// Calcula el beneficio neto estimado.
  double get estimatedProfit => annualRevenue - annualExpenses;

  FiscalProfile copyWith({
    String? id,
    String? userId,
    LegalForm? legalForm,
    FiscalRegime? fiscalRegime,
    IvaRegime? ivaRegime,
    String? nif,
    String? autonomousCommunity,
    String? iaeCode,
    String? iaeDescription,
    double? annualRevenue,
    double? annualExpenses,
    bool? worksFromHome,
    double? homeOfficePercentage,
    int? fiscalYear,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FiscalProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      legalForm: legalForm ?? this.legalForm,
      fiscalRegime: fiscalRegime ?? this.fiscalRegime,
      ivaRegime: ivaRegime ?? this.ivaRegime,
      nif: nif ?? this.nif,
      autonomousCommunity: autonomousCommunity ?? this.autonomousCommunity,
      iaeCode: iaeCode ?? this.iaeCode,
      iaeDescription: iaeDescription ?? this.iaeDescription,
      annualRevenue: annualRevenue ?? this.annualRevenue,
      annualExpenses: annualExpenses ?? this.annualExpenses,
      worksFromHome: worksFromHome ?? this.worksFromHome,
      homeOfficePercentage: homeOfficePercentage ?? this.homeOfficePercentage,
      fiscalYear: fiscalYear ?? this.fiscalYear,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
