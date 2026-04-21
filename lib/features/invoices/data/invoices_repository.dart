// Invoices repository — Flutter side.
//
// Hits `/api/invoices` and `/api/parties/{id}` through the Dio client, which
// already injects the `X-Data-Source` header from `dataSourceProvider`. The
// backend routes the request to MongoDB Atlas or Supabase Postgres based on
// that header; this layer is source-agnostic.
//
// Mapping strategy: the wire shape (`InvoiceDoc` in
// `api/_lib/db/types.d.ts`) is canonical and uses cents + denormalised
// `issuerName`/`recipientName`. We map to the **legacy** `Invoice` model
// (double euros + flat issuer/receiver fields) so the existing UI keeps
// working. The canonical Dart `Invoice` in `domain/invoice.dart` will
// replace this shim once the detail tabs migrate.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/session/data_source.dart';
import '../../../core/session/data_source_provider.dart';
import 'models/invoice_line.dart';
import 'models/invoice_model.dart';

class InvoicesRepository {
  InvoicesRepository(this._dio);

  final DioClient _dio;

  /// GET /api/invoices — returns legacy-shape invoices. Issuer/receiver
  /// NIF + address come back empty because the list endpoint only carries
  /// denormalised names. The detail fetch fills them in.
  Future<List<Invoice>> listInvoices({DataSource? source}) async {
    final response = await _dio.dio.get<dynamic>(
      '/invoices',
      options: _sourceOverride(source),
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected /api/invoices payload: $data');
    }
    final items = data['items'];
    if (items is! List) {
      throw StateError('Expected "items" to be a list, got: $items');
    }
    return [
      for (final raw in items)
        if (raw is Map<String, dynamic>) _wireToLegacyInvoice(raw),
    ];
  }

  /// GET /api/invoices/{id} then fills issuer + recipient NIF/address from
  /// /api/parties/{id} (in parallel). Returns a legacy `Invoice` ready for
  /// the detail screen.
  Future<Invoice> getInvoiceById(String id, {DataSource? source}) async {
    final options = _sourceOverride(source);
    final invoiceResponse = await _dio.dio.get<dynamic>(
      '/invoices/$id',
      options: options,
    );
    final doc = invoiceResponse.data;
    if (doc is! Map<String, dynamic>) {
      throw StateError('Unexpected /api/invoices/$id payload: $doc');
    }

    final issuerId = doc['issuerId'] as String?;
    final recipientId = doc['recipientId'] as String?;

    final partyResults = await Future.wait<Map<String, dynamic>?>([
      if (issuerId != null) _fetchParty(issuerId, options) else Future.value(null),
      if (recipientId != null) _fetchParty(recipientId, options) else Future.value(null),
    ]);
    final issuer = partyResults.isNotEmpty ? partyResults[0] : null;
    final recipient = partyResults.length > 1 ? partyResults[1] : null;

    return _wireToLegacyInvoice(doc, issuer: issuer, recipient: recipient);
  }

  Future<Map<String, dynamic>?> _fetchParty(String id, Options? options) async {
    try {
      final r = await _dio.dio.get<dynamic>('/parties/$id', options: options);
      final data = r.data;
      return data is Map<String, dynamic> ? data : null;
    } on DioException {
      // 404 or mid-flight DB-switch race: degrade gracefully with empty
      // NIF/address instead of blocking the whole detail view.
      return null;
    }
  }

  Options? _sourceOverride(DataSource? source) {
    if (source == null) return null;
    return Options(headers: {'X-Data-Source': source.header});
  }
}

// ── Wire → legacy mapping ───────────────────────────────────────────────

Invoice _wireToLegacyInvoice(
  Map<String, dynamic> doc, {
  Map<String, dynamic>? issuer,
  Map<String, dynamic>? recipient,
}) {
  final totals = (doc['totals'] as Map?)?.cast<String, dynamic>() ?? const {};
  final compliance =
      (doc['compliance'] as Map?)?.cast<String, dynamic>() ?? const {};
  final paymentTerms = (doc['paymentTerms'] as Map?)?.cast<String, dynamic>();
  final linesRaw = (doc['lines'] as List?) ?? const [];
  final vatBreakdown = (totals['vatBreakdown'] as List?) ?? const [];

  final subtotal = _centsToDouble(totals['subtotalCents']);
  final irpf = _centsToDouble(totals['irpfCents']);
  final total = _centsToDouble(totals['totalCents']);
  final taxAmount = vatBreakdown.fold<double>(0, (s, v) {
    if (v is Map<String, dynamic>) {
      return s + _centsToDouble(v['vatCents']) + _centsToDouble(v['recargoCents']);
    }
    return s;
  });

  return Invoice(
    id: doc['id'] as String,
    number: '${doc['series'] ?? ''}${doc['number'] ?? ''}',
    status: _parseStatus(doc['status'] as String?),
    complianceStatus: _deriveCompliance(compliance),
    issuerId: doc['issuerId'] as String? ?? '',
    issuerName: (doc['issuerName'] as String?) ??
        (issuer?['name'] as String?) ??
        '',
    issuerNif: (issuer?['taxId'] as String?) ?? '',
    issuerAddress: _formatAddress(issuer?['address']),
    receiverId: doc['recipientId'] as String? ?? '',
    receiverName: (doc['recipientName'] as String?) ??
        (recipient?['name'] as String?) ??
        '',
    receiverNif: (recipient?['taxId'] as String?) ?? '',
    receiverAddress: _formatAddress(recipient?['address']),
    lines: [
      for (final l in linesRaw)
        if (l is Map<String, dynamic>) _wireToLegacyLine(l),
    ],
    subtotal: subtotal,
    taxAmount: taxAmount > 0 ? taxAmount : (total - subtotal + irpf),
    total: total,
    currency: (totals['currency'] as String?) ?? 'EUR',
    issueDate: _parseDate(doc['issueDate']) ?? DateTime.now(),
    dueDate: _parseDate(paymentTerms?['dueDate']),
    paymentTerm:
        paymentTerms == null ? PaymentTerm.contado : PaymentTerm.credito,
    paymentMethod: paymentTerms?['method'] as String?,
    paymentIban: paymentTerms?['iban'] as String?,
    notes: doc['notes'] as String?,
    createdAt: _parseDate(doc['createdAt']) ?? DateTime.now(),
    updatedAt: _parseDate(doc['updatedAt']) ?? DateTime.now(),
  );
}

InvoiceLine _wireToLegacyLine(Map<String, dynamic> l) {
  return InvoiceLine(
    id: l['id'] as String? ?? '',
    description: l['description'] as String? ?? '',
    quantity: (l['quantity'] is num)
        ? (l['quantity'] as num).round()
        : int.tryParse('${l['quantity']}') ?? 1,
    unitPrice: _centsToDouble(l['unitPriceCents']),
    taxRate: (l['vatRateValue'] is num)
        ? (l['vatRateValue'] as num).toDouble()
        : 0,
    total: _centsToDouble(l['lineTotalCents']),
  );
}

String? _formatAddress(dynamic raw) {
  if (raw is! Map) return null;
  final m = raw.cast<String, dynamic>();
  final line1 = (m['line1'] as String?)?.trim() ?? '';
  final line2 = (m['line2'] as String?)?.trim() ?? '';
  final postal = (m['postalCode'] as String?)?.trim() ?? '';
  final city = (m['city'] as String?)?.trim() ?? '';
  final parts = <String>[
    if (line1.isNotEmpty) line1,
    if (line2.isNotEmpty) line2,
    [postal, city].where((p) => p.isNotEmpty).join(' '),
  ].where((p) => p.isNotEmpty).toList();
  return parts.isEmpty ? null : parts.join(', ');
}

double _centsToDouble(dynamic v) {
  if (v is num) return v.toDouble() / 100.0;
  if (v is String) {
    final parsed = num.tryParse(v);
    if (parsed != null) return parsed.toDouble() / 100.0;
  }
  return 0;
}

DateTime? _parseDate(dynamic v) {
  if (v is String && v.isNotEmpty) {
    return DateTime.tryParse(v);
  }
  return null;
}

InvoiceStatus _parseStatus(String? wire) {
  if (wire == null) return InvoiceStatus.draft;
  for (final s in InvoiceStatus.values) {
    if (s.name == wire) return s;
  }
  return InvoiceStatus.draft;
}

// Heuristic: the list view shows a compliance chip per invoice. The wire
// payload only exposes primitives (SII submitted flag + TBAI / Verifactu
// hash presence), so we map them into the existing four-state enum the UI
// already renders. Simple and stable — avoids a backend-side change and
// keeps the demo visually rich.
ComplianceStatus _deriveCompliance(Map<String, dynamic> compliance) {
  final sii = compliance['siiSubmitted'] == true;
  final tbai = (compliance['ticketBaiHash'] as String?)?.isNotEmpty ?? false;
  final verifactu =
      (compliance['verifactuHash'] as String?)?.isNotEmpty ?? false;
  if (sii && (tbai || verifactu)) return ComplianceStatus.pass;
  if (tbai || verifactu) return ComplianceStatus.warnings;
  if (sii) return ComplianceStatus.pass;
  return ComplianceStatus.pending;
}

// ── Providers ───────────────────────────────────────────────────────────

final invoicesRepositoryProvider = Provider<InvoicesRepository>((ref) {
  return InvoicesRepository(ref.watch(dioClientProvider));
});

/// Lista de facturas. Re-fetches automatically when [dataSourceProvider]
/// flips, because Riverpod invalidates any provider whose `watch()`ed
/// dependency changes.
final invoicesListProvider =
    FutureProvider.autoDispose<List<Invoice>>((ref) async {
  final source = ref.watch(dataSourceProvider);
  final repo = ref.watch(invoicesRepositoryProvider);
  return repo.listInvoices(source: source);
});

/// Factura individual por id. Mismo contrato reactivo al switch de DB.
final invoiceByIdProvider =
    FutureProvider.autoDispose.family<Invoice, String>((ref, id) async {
  final source = ref.watch(dataSourceProvider);
  final repo = ref.watch(invoicesRepositoryProvider);
  return repo.getInvoiceById(id, source: source);
});
