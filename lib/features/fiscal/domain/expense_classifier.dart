import '../../../features/invoices/data/models/invoice_model.dart';
import '../data/models/expense_classification.dart';
import '../data/models/fiscal_profile.dart';

/// Clasificador de gastos basado en palabras clave.
///
/// Analiza la descripción de las líneas de factura para asignar
/// una categoría de gasto y determinar su deducibilidad fiscal.
class ExpenseClassifier {
  /// Mapa de palabras clave a categorías de gasto.
  static const Map<ExpenseCategory, List<String>> _keywords = {
    ExpenseCategory.suministros: [
      'luz',
      'electricidad',
      'agua',
      'gas',
      'internet',
      'fibra',
      'telefonía',
      'telefono',
      'adsl',
      'energía',
      'suministro',
      'endesa',
      'iberdrola',
      'naturgy',
      'vodafone',
      'movistar',
      'orange',
      'masmovil',
    ],
    ExpenseCategory.alquiler: [
      'alquiler',
      'arrendamiento',
      'renta',
      'local',
      'oficina',
      'coworking',
    ],
    ExpenseCategory.materialOficina: [
      'papelería',
      'material oficina',
      'tóner',
      'toner',
      'cartuchos',
      'papel',
      'bolígrafos',
      'sobres',
      'archivador',
      'impresora',
    ],
    ExpenseCategory.serviciosProfesionales: [
      'asesoría',
      'asesoria',
      'consultoría',
      'consultoria',
      'abogado',
      'notario',
      'gestoría',
      'gestoria',
      'auditoría',
      'auditoria',
      'honorarios',
      'servicios profesionales',
    ],
    ExpenseCategory.marketing: [
      'publicidad',
      'marketing',
      'anuncio',
      'campaña',
      'google ads',
      'facebook ads',
      'diseño gráfico',
      'branding',
      'seo',
      'sem',
      'redes sociales',
    ],
    ExpenseCategory.formacion: [
      'formación',
      'formacion',
      'curso',
      'taller',
      'seminario',
      'conferencia',
      'congreso',
      'máster',
      'master',
      'certificación',
      'libro',
      'suscripción educativa',
    ],
    ExpenseCategory.seguros: [
      'seguro',
      'póliza',
      'poliza',
      'prima',
      'responsabilidad civil',
      'mutua',
    ],
    ExpenseCategory.vehiculo: [
      'gasolina',
      'gasoil',
      'diésel',
      'diesel',
      'combustible',
      'aparcamiento',
      'parking',
      'peaje',
      'autopista',
      'taller mecánico',
      'reparación vehículo',
      'itv',
      'leasing coche',
      'renting',
    ],
    ExpenseCategory.viajes: [
      'vuelo',
      'avión',
      'avion',
      'tren',
      'renfe',
      'hotel',
      'alojamiento',
      'taxi',
      'uber',
      'cabify',
      'transporte',
      'billete',
    ],
    ExpenseCategory.dietas: [
      'restaurante',
      'comida',
      'cena',
      'almuerzo',
      'dieta',
      'manutención',
      'catering',
    ],
    ExpenseCategory.amortizacion: [
      'ordenador',
      'portátil',
      'portatil',
      'servidor',
      'mobiliario',
      'mueble',
      'equipo',
      'maquinaria',
      'vehículo',
      'vehiculo',
    ],
    ExpenseCategory.comunicaciones: [
      'correos',
      'mensajería',
      'paquetería',
      'envío',
      'seur',
      'mrw',
      'ups',
      'dhl',
      'fedex',
    ],
    ExpenseCategory.software: [
      'software',
      'licencia',
      'saas',
      'suscripción',
      'cloud',
      'hosting',
      'dominio',
      'aws',
      'azure',
      'google cloud',
      'github',
      'slack',
      'microsoft 365',
      'adobe',
    ],
    ExpenseCategory.impuestosTasas: [
      'tasa',
      'impuesto',
      'tributo',
      'canon',
      'ibi',
      'iae',
      'basura',
      'recogida residuos',
    ],
  };

  /// Porcentajes de deducibilidad por defecto según categoría.
  static const Map<ExpenseCategory, double> _defaultDeductibility = {
    ExpenseCategory.suministros: 30.0,
    ExpenseCategory.alquiler: 100.0,
    ExpenseCategory.materialOficina: 100.0,
    ExpenseCategory.serviciosProfesionales: 100.0,
    ExpenseCategory.marketing: 100.0,
    ExpenseCategory.formacion: 100.0,
    ExpenseCategory.seguros: 100.0,
    ExpenseCategory.vehiculo: 50.0,
    ExpenseCategory.viajes: 100.0,
    ExpenseCategory.dietas: 100.0,
    ExpenseCategory.amortizacion: 100.0,
    ExpenseCategory.comunicaciones: 100.0,
    ExpenseCategory.software: 100.0,
    ExpenseCategory.impuestosTasas: 100.0,
    ExpenseCategory.otros: 0.0,
  };

  /// Referencias legales por categoría.
  static const Map<ExpenseCategory, String> _legalReferences = {
    ExpenseCategory.suministros: 'Art. 30.2.5.b) LIRPF',
    ExpenseCategory.alquiler: 'Art. 28.1 LIRPF / Art. 10 LIS',
    ExpenseCategory.materialOficina: 'Art. 28.1 LIRPF',
    ExpenseCategory.serviciosProfesionales: 'Art. 28.1 LIRPF',
    ExpenseCategory.marketing: 'Art. 28.1 LIRPF',
    ExpenseCategory.formacion: 'Art. 28.1 LIRPF',
    ExpenseCategory.seguros: 'Art. 28.1 LIRPF / Art. 30.2.1 LIRPF',
    ExpenseCategory.vehiculo: 'Art. 22 RIVA (50% IVA deducible)',
    ExpenseCategory.viajes: 'Art. 28.1 LIRPF / Art. 9 RD 439/2007',
    ExpenseCategory.dietas: 'Art. 9 RD 439/2007',
    ExpenseCategory.amortizacion:
        'Art. 12 LIS / Tabla amortización simplificada',
    ExpenseCategory.comunicaciones: 'Art. 28.1 LIRPF',
    ExpenseCategory.software: 'Art. 28.1 LIRPF',
    ExpenseCategory.impuestosTasas: 'Art. 28.1 LIRPF (con exclusiones)',
    ExpenseCategory.otros: 'Requiere análisis individualizado',
  };

  /// Clasifica una factura recibida en una categoría de gasto.
  ExpenseClassification classify({
    required Invoice invoice,
    required FiscalProfile profile,
  }) {
    // Concatenar todas las descripciones de líneas
    final description = invoice.lines
        .map((l) => l.description)
        .join(' ')
        .toLowerCase();

    // Buscar categoría por palabras clave
    final result = _matchCategory(description);
    final category = result.category;
    final matchedKeywords = result.keywords;

    // Determinar porcentaje deducible
    double percentage = _defaultDeductibility[category] ?? 0;

    // Ajustar suministros si trabaja desde casa
    if (category == ExpenseCategory.suministros && profile.worksFromHome) {
      final homePercentage = profile.homeOfficePercentage ?? 0;
      percentage = homePercentage * 0.3; // 30% del porcentaje de vivienda
    }

    // Ajustar vehículo: solo 50% IVA deducible según Art. 22 RIVA
    if (category == ExpenseCategory.vehiculo) {
      percentage = 50.0;
    }

    // Calcular importes
    final baseAmount = invoice.subtotal;
    final deductibleAmount = baseAmount * (percentage / 100);
    final ivaDeducible = invoice.taxAmount * (percentage / 100);

    // Determinar tipo de deducibilidad
    final deductibility = _determineDeductibility(
      category: category,
      percentage: percentage,
    );

    final legalRef = _legalReferences[category] ?? 'Requiere análisis';

    return ExpenseClassification(
      invoiceId: invoice.id,
      category: category,
      deductibility: deductibility,
      deductiblePercentage: percentage,
      deductibleAmount: deductibleAmount,
      ivaDeducible: ivaDeducible,
      legalReference: legalRef,
      explanation: _buildExplanation(
        category: category,
        percentage: percentage,
        deductibleAmount: deductibleAmount,
        legalRef: legalRef,
      ),
      matchedKeywords: matchedKeywords,
      classifiedAt: DateTime.now(),
    );
  }

  /// Busca la categoría que mejor coincide con la descripción.
  _CategoryMatch _matchCategory(String description) {
    int bestScore = 0;
    ExpenseCategory bestCategory = ExpenseCategory.otros;
    List<String> bestKeywords = [];

    for (final entry in _keywords.entries) {
      final matched = <String>[];
      for (final keyword in entry.value) {
        if (description.contains(keyword.toLowerCase())) {
          matched.add(keyword);
        }
      }
      if (matched.length > bestScore) {
        bestScore = matched.length;
        bestCategory = entry.key;
        bestKeywords = matched;
      }
    }

    return _CategoryMatch(category: bestCategory, keywords: bestKeywords);
  }

  /// Determina el tipo de deducibilidad según categoría y porcentaje.
  Deductibility _determineDeductibility({
    required ExpenseCategory category,
    required double percentage,
  }) {
    if (category == ExpenseCategory.otros) {
      return Deductibility.requiereAnalisis;
    }
    if (percentage >= 100) {
      return Deductibility.totalmenteDeducible;
    }
    if (percentage > 0) {
      return Deductibility.parcialmenteDeducible;
    }
    return Deductibility.noDeducible;
  }

  /// Construye la explicación textual de la clasificación.
  String _buildExplanation({
    required ExpenseCategory category,
    required double percentage,
    required double deductibleAmount,
    required String legalRef,
  }) {
    final categoryName = category.name;
    return 'Gasto clasificado como $categoryName. '
        'Deducible al ${percentage.toStringAsFixed(0)}% '
        '(${deductibleAmount.toStringAsFixed(2)} EUR). '
        'Ref: $legalRef.';
  }
}

/// Resultado interno de la búsqueda de categoría.
class _CategoryMatch {
  final ExpenseCategory category;
  final List<String> keywords;

  const _CategoryMatch({required this.category, required this.keywords});
}
