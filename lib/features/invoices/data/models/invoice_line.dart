/// Línea individual de factura.
///
/// Representa un producto o servicio facturado con su
/// descripción, cantidad, precio unitario, tasa de IVA y total.
class InvoiceLine {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double taxRate;
  final double total;

  const InvoiceLine({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
    required this.total,
  });

  /// Calcula el total de la línea: quantity * unitPrice * (1 + taxRate/100)
  static double computeTotal({
    required int quantity,
    required double unitPrice,
    required double taxRate,
  }) {
    return quantity * unitPrice * (1 + taxRate / 100);
  }

  /// Calcula el subtotal sin impuestos.
  double get subtotal => quantity * unitPrice;

  /// Calcula la cantidad de impuestos.
  double get taxAmount => subtotal * (taxRate / 100);

  InvoiceLine copyWith({
    String? id,
    String? description,
    int? quantity,
    double? unitPrice,
    double? taxRate,
    double? total,
  }) {
    return InvoiceLine(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      total: total ?? this.total,
    );
  }
}
