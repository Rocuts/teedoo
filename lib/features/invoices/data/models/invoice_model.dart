import 'invoice_line.dart';

/// Estado de la factura en el flujo de trabajo.
enum InvoiceStatus {
  draft,
  pendingReview,
  readyToSend,
  sent,
  accepted,
  rejected,
  cancelled,
}

/// Estado del compliance check de la factura.
enum ComplianceStatus {
  pass,
  warnings,
  fail,
  pending,
}

/// Modelo principal de factura.
///
/// Contiene toda la información estructurada de una factura
/// electrónica: partes (emisor/receptor), líneas, totales,
/// estado de compliance y datos de pago.
class Invoice {
  final String id;
  final String number;
  final InvoiceStatus status;
  final ComplianceStatus complianceStatus;
  final String issuerId;
  final String issuerName;
  final String issuerNif;
  final String? issuerAddress;
  final String receiverId;
  final String receiverName;
  final String receiverNif;
  final String? receiverAddress;
  final List<InvoiceLine> lines;
  final double subtotal;
  final double taxAmount;
  final double total;
  final String currency;
  final DateTime issueDate;
  final DateTime? dueDate;
  final String? paymentMethod;
  final String? paymentIban;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.number,
    required this.status,
    required this.complianceStatus,
    required this.issuerId,
    required this.issuerName,
    required this.issuerNif,
    this.issuerAddress,
    required this.receiverId,
    required this.receiverName,
    required this.receiverNif,
    this.receiverAddress,
    required this.lines,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    this.currency = 'EUR',
    required this.issueDate,
    this.dueDate,
    this.paymentMethod,
    this.paymentIban,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Invoice copyWith({
    String? id,
    String? number,
    InvoiceStatus? status,
    ComplianceStatus? complianceStatus,
    String? issuerId,
    String? issuerName,
    String? issuerNif,
    String? issuerAddress,
    String? receiverId,
    String? receiverName,
    String? receiverNif,
    String? receiverAddress,
    List<InvoiceLine>? lines,
    double? subtotal,
    double? taxAmount,
    double? total,
    String? currency,
    DateTime? issueDate,
    DateTime? dueDate,
    String? paymentMethod,
    String? paymentIban,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      number: number ?? this.number,
      status: status ?? this.status,
      complianceStatus: complianceStatus ?? this.complianceStatus,
      issuerId: issuerId ?? this.issuerId,
      issuerName: issuerName ?? this.issuerName,
      issuerNif: issuerNif ?? this.issuerNif,
      issuerAddress: issuerAddress ?? this.issuerAddress,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverNif: receiverNif ?? this.receiverNif,
      receiverAddress: receiverAddress ?? this.receiverAddress,
      lines: lines ?? this.lines,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentIban: paymentIban ?? this.paymentIban,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
