/// Categoría de gasto para clasificación fiscal.
enum ExpenseCategory {
  suministros,
  alquiler,
  materialOficina,
  serviciosProfesionales,
  marketing,
  formacion,
  seguros,
  vehiculo,
  viajes,
  dietas,
  amortizacion,
  comunicaciones,
  software,
  impuestosTasas,
  otros,
}

/// Deducibilidad del gasto según normativa fiscal.
enum Deductibility {
  totalmenteDeducible,
  parcialmenteDeducible,
  noDeducible,
  requiereAnalisis,
}

/// Clasificación fiscal de un gasto.
///
/// Asocia una factura recibida con su categoría de gasto,
/// deducibilidad fiscal, porcentaje deducible, y la referencia
/// legal que lo justifica.
class ExpenseClassification {
  final String invoiceId;
  final ExpenseCategory category;
  final Deductibility deductibility;
  final double deductiblePercentage;
  final double deductibleAmount;
  final double ivaDeducible;
  final String legalReference;
  final String explanation;
  final List<String> matchedKeywords;
  final DateTime classifiedAt;

  const ExpenseClassification({
    required this.invoiceId,
    required this.category,
    required this.deductibility,
    required this.deductiblePercentage,
    required this.deductibleAmount,
    required this.ivaDeducible,
    required this.legalReference,
    required this.explanation,
    this.matchedKeywords = const [],
    required this.classifiedAt,
  });

  /// Indica si el gasto es al menos parcialmente deducible.
  bool get isDeducible =>
      deductibility == Deductibility.totalmenteDeducible ||
      deductibility == Deductibility.parcialmenteDeducible;

  /// Importe no deducible del gasto.
  double get nonDeductibleAmount =>
      deductibleAmount / (deductiblePercentage / 100) - deductibleAmount;

  ExpenseClassification copyWith({
    String? invoiceId,
    ExpenseCategory? category,
    Deductibility? deductibility,
    double? deductiblePercentage,
    double? deductibleAmount,
    double? ivaDeducible,
    String? legalReference,
    String? explanation,
    List<String>? matchedKeywords,
    DateTime? classifiedAt,
  }) {
    return ExpenseClassification(
      invoiceId: invoiceId ?? this.invoiceId,
      category: category ?? this.category,
      deductibility: deductibility ?? this.deductibility,
      deductiblePercentage: deductiblePercentage ?? this.deductiblePercentage,
      deductibleAmount: deductibleAmount ?? this.deductibleAmount,
      ivaDeducible: ivaDeducible ?? this.ivaDeducible,
      legalReference: legalReference ?? this.legalReference,
      explanation: explanation ?? this.explanation,
      matchedKeywords: matchedKeywords ?? this.matchedKeywords,
      classifiedAt: classifiedAt ?? this.classifiedAt,
    );
  }
}
