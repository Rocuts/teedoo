/// Calculadora de ahorro fiscal.
///
/// Calcula el ahorro real en impuestos utilizando los tramos
/// marginales del IRPF estatal + autonómico vigentes en España.
class SavingsCalculator {
  SavingsCalculator._();

  /// Tramos del IRPF estatal 2024-2025.
  /// Cada entrada: (límite superior, tipo marginal).
  static const List<(double, double)> _irpfTramos = [
    (12450, 19.0),
    (20200, 24.0),
    (35200, 30.0),
    (60000, 37.0),
    (300000, 45.0),
    (double.infinity, 47.0),
  ];

  /// Calcula el ahorro en IRPF de una deducción.
  ///
  /// El ahorro es la cantidad que se deja de pagar al reducir
  /// la base imponible en [deductibleAmount]. Se calcula aplicando
  /// el tipo marginal correspondiente al tramo de [taxableIncome].
  ///
  /// Si [taxableIncome] es 0 o no se conoce, se aplica un tipo
  /// marginal estimado del 30% (tramo medio para autónomos).
  static double computeIrpfSaving({
    required double deductibleAmount,
    required double taxableIncome,
  }) {
    if (deductibleAmount <= 0) return 0;

    // Si no se conoce la base imponible, usar tipo marginal estimado
    if (taxableIncome <= 0) {
      return deductibleAmount * 0.30;
    }

    // Calcular tipo marginal para la base imponible actual
    final marginalRate = getMarginalRate(taxableIncome);
    return deductibleAmount * (marginalRate / 100);
  }

  /// Obtiene el tipo marginal para una base imponible dada.
  static double getMarginalRate(double taxableIncome) {
    for (final (limit, rate) in _irpfTramos) {
      if (taxableIncome <= limit) return rate;
    }
    return _irpfTramos.last.$2;
  }

  /// Calcula la cuota íntegra del IRPF para una base imponible.
  ///
  /// Aplica los tramos progresivos sumando la cuota de cada tramo.
  static double computeIrpfQuota(double taxableIncome) {
    if (taxableIncome <= 0) return 0;

    double quota = 0;
    double remaining = taxableIncome;
    double previousLimit = 0;

    for (final (limit, rate) in _irpfTramos) {
      final tramoSize = limit - previousLimit;
      final taxableInTramo = remaining > tramoSize ? tramoSize : remaining;
      quota += taxableInTramo * (rate / 100);
      remaining -= taxableInTramo;
      previousLimit = limit;
      if (remaining <= 0) break;
    }

    return quota;
  }

  /// Calcula el ahorro real comparando cuotas con y sin deducción.
  ///
  /// Más preciso que [computeIrpfSaving] porque tiene en cuenta
  /// que la deducción puede cruzar tramos.
  static double computeRealSaving({
    required double taxableIncome,
    required double deductibleAmount,
  }) {
    if (deductibleAmount <= 0 || taxableIncome <= 0) return 0;

    final quotaWithout = computeIrpfQuota(taxableIncome);
    final quotaWith = computeIrpfQuota(taxableIncome - deductibleAmount);

    return quotaWithout - quotaWith;
  }

  /// Calcula el tipo efectivo de IRPF para una base imponible.
  static double effectiveRate(double taxableIncome) {
    if (taxableIncome <= 0) return 0;
    return computeIrpfQuota(taxableIncome) / taxableIncome * 100;
  }

  /// Calcula el ahorro en IVA por deducción de IVA soportado.
  ///
  /// El ahorro es directamente el IVA deducible, ya que reduce
  /// la liquidación trimestral de IVA (modelo 303).
  static double computeIvaSaving({required double ivaDeducible}) {
    return ivaDeducible > 0 ? ivaDeducible : 0;
  }

  /// Calcula el ahorro total combinando IRPF e IVA.
  static double computeTotalSaving({
    required double irpfDeductible,
    required double ivaDeducible,
    required double taxableIncome,
  }) {
    final irpfSaving = computeIrpfSaving(
      deductibleAmount: irpfDeductible,
      taxableIncome: taxableIncome,
    );
    final ivaSaving = computeIvaSaving(ivaDeducible: ivaDeducible);
    return irpfSaving + ivaSaving;
  }
}
