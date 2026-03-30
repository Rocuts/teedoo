import '../../../../features/invoices/data/models/invoice_model.dart';
import '../models/expense_classification.dart';
import '../models/fiscal_profile.dart';

/// Contexto fiscal agregado para evaluación de reglas.
///
/// Reúne toda la información necesaria para que el motor de reglas
/// evalúe cada regla: perfil del contribuyente, facturas emitidas
/// y recibidas, clasificación de gastos, y totales acumulados.
class FiscalContext {
  final FiscalProfile profile;
  final List<Invoice> issuedInvoices;
  final List<Invoice> receivedInvoices;
  final List<ExpenseClassification> expenseClassifications;
  final int fiscalYear;

  const FiscalContext({
    required this.profile,
    required this.issuedInvoices,
    required this.receivedInvoices,
    this.expenseClassifications = const [],
    required this.fiscalYear,
  });

  /// Total de ingresos facturados (base imponible).
  double get totalRevenue =>
      issuedInvoices.fold(0.0, (sum, inv) => sum + inv.subtotal);

  /// Total de gastos facturados (base imponible).
  double get totalExpenses =>
      receivedInvoices.fold(0.0, (sum, inv) => sum + inv.subtotal);

  /// Total de IVA repercutido (en facturas emitidas).
  double get totalIvaRepercutido =>
      issuedInvoices.fold(0.0, (sum, inv) => sum + inv.taxAmount);

  /// Total de IVA soportado (en facturas recibidas).
  double get totalIvaSoportado =>
      receivedInvoices.fold(0.0, (sum, inv) => sum + inv.taxAmount);

  /// Beneficio neto estimado antes de impuestos.
  double get estimatedProfit => totalRevenue - totalExpenses;

  /// Gastos de suministros del hogar (luz, agua, gas, internet).
  List<ExpenseClassification> get homeSupplyExpenses => expenseClassifications
      .where((e) => e.category == ExpenseCategory.suministros)
      .toList();

  /// Importe total de gastos clasificados como deducibles.
  double get totalDeductibleExpenses => expenseClassifications
      .where((e) => e.isDeducible)
      .fold(0.0, (sum, e) => sum + e.deductibleAmount);

  FiscalContext copyWith({
    FiscalProfile? profile,
    List<Invoice>? issuedInvoices,
    List<Invoice>? receivedInvoices,
    List<ExpenseClassification>? expenseClassifications,
    int? fiscalYear,
  }) {
    return FiscalContext(
      profile: profile ?? this.profile,
      issuedInvoices: issuedInvoices ?? this.issuedInvoices,
      receivedInvoices: receivedInvoices ?? this.receivedInvoices,
      expenseClassifications:
          expenseClassifications ?? this.expenseClassifications,
      fiscalYear: fiscalYear ?? this.fiscalYear,
    );
  }
}
