import '../../features/invoices/data/models/invoice_line.dart';
import '../../features/invoices/data/models/invoice_model.dart';
import '../../shared/widgets/badges/status_badge.dart';

class MockData {
  static final List<Invoice> invoices = [
    // --- CURRENT MONTH (March) - Total: 34,500 EUR (Matches Dashboard KPI) ---
    Invoice(
      id: 'inv_current_1',
      number: 'INV-2026-095',
      status: InvoiceStatus.sent,
      complianceStatus: ComplianceStatus.pass,
      issuerId: 'org_1',
      issuerName: 'Mi Empresa S.L.',
      issuerNif: 'B12345678',
      receiverId: 'cli_7',
      receiverName: 'Global Corp F.P.',
      receiverNif: 'A55555555',
      lines: [
        const InvoiceLine(id: 'l1', description: 'Servicios de Consultoría Estratégica', quantity: 1, unitPrice: 12396.69, taxRate: 21.0, total: 15000.0),
      ],
      subtotal: 12396.69,
      taxAmount: 2603.31,
      total: 15000.0,
      currency: 'EUR',
      issueDate: DateTime(2026, 3, 25),
      dueDate: DateTime(2026, 4, 25),
      createdAt: DateTime(2026, 3, 25),
      updatedAt: DateTime(2026, 3, 25),
    ),
    Invoice(
      id: 'inv_current_2',
      number: 'INV-2026-094',
      status: InvoiceStatus.accepted,
      complianceStatus: ComplianceStatus.pass,
      issuerId: 'org_1',
      issuerName: 'Mi Empresa S.L.',
      issuerNif: 'B12345678',
      receiverId: 'cli_8',
      receiverName: 'Tech Innovators Spain',
      receiverNif: 'B88888888',
      lines: [
        const InvoiceLine(id: 'l1', description: 'Licencias de Software Enterprise', quantity: 10, unitPrice: 826.44, taxRate: 21.0, total: 10000.0),
      ],
      subtotal: 8264.40,
      taxAmount: 1735.60,
      total: 10000.0,
      currency: 'EUR',
      issueDate: DateTime(2026, 3, 20),
      dueDate: DateTime(2026, 4, 20),
      createdAt: DateTime(2026, 3, 20),
      updatedAt: DateTime(2026, 3, 20),
    ),
    Invoice(
      id: 'inv_current_3',
      number: 'INV-2026-093',
      status: InvoiceStatus.accepted,
      complianceStatus: ComplianceStatus.pass,
      issuerId: 'org_1',
      issuerName: 'Mi Empresa S.L.',
      issuerNif: 'B12345678',
      receiverId: 'cli_3',
      receiverName: 'Servicios Castellón S.A.',
      receiverNif: 'A11223344',
      lines: [
        const InvoiceLine(id: 'l1', description: 'Campaña de Marketing Q1', quantity: 1, unitPrice: 7851.24, taxRate: 21.0, total: 9500.0),
      ],
      subtotal: 7851.24,
      taxAmount: 1648.76,
      total: 9500.0,
      currency: 'EUR',
      issueDate: DateTime(2026, 3, 10),
      dueDate: DateTime(2026, 4, 10),
      createdAt: DateTime(2026, 3, 10),
      updatedAt: DateTime(2026, 3, 10),
    ),
    // --- FEBRUARY ---
    Invoice(
      id: 'inv_1',
      number: 'INV-2026-092',
      status: InvoiceStatus.sent,
      complianceStatus: ComplianceStatus.pass,
      issuerId: 'org_1',
      issuerName: 'Mi Empresa S.L.',
      issuerNif: 'B12345678',
      receiverId: 'cli_1',
      receiverName: 'Acme Corporation S.L.',
      receiverNif: 'A87654321',
      lines: [
        const InvoiceLine(id: 'l1', description: 'Consultoría TI', quantity: 1, unitPrice: 3500.0, taxRate: 21.0, total: 4235.0),
      ],
      subtotal: 3500.0,
      taxAmount: 735.0,
      total: 4235.0,
      currency: 'EUR',
      issueDate: DateTime(2026, 2, 27),
      dueDate: DateTime(2026, 3, 27),
      createdAt: DateTime(2026, 2, 27),
      updatedAt: DateTime(2026, 2, 27),
    ),
    Invoice(
      id: 'inv_2',
      number: 'INV-2026-091',
      status: InvoiceStatus.sent,
      complianceStatus: ComplianceStatus.pass,
      issuerId: 'org_1',
      issuerName: 'Mi Empresa S.L.',
      issuerNif: 'B12345678',
      receiverId: 'cli_2',
      receiverName: 'Digital Excellence Group',
      receiverNif: 'B98765432',
      lines: [
        const InvoiceLine(id: 'l1', description: 'Diseño UI/UX', quantity: 1, unitPrice: 1524.38, taxRate: 21.0, total: 1844.50),
      ],
      subtotal: 1524.38,
      taxAmount: 320.12,
      total: 1844.50,
      currency: 'EUR',
      issueDate: DateTime(2026, 2, 26),
      dueDate: DateTime(2026, 3, 26),
      createdAt: DateTime(2026, 2, 26),
      updatedAt: DateTime(2026, 2, 26),
    ),
    Invoice(
      id: 'inv_3',
      number: 'INV-2026-090',
      status: InvoiceStatus.rejected,
      complianceStatus: ComplianceStatus.fail,
      issuerId: 'org_1',
      issuerName: 'Mi Empresa S.L.',
      issuerNif: 'B12345678',
      receiverId: 'cli_3',
      receiverName: 'Servicios Castellón S.A.',
      receiverNif: 'A11223344',
      lines: [
        const InvoiceLine(id: 'l1', description: 'Desarrollo Backend', quantity: 2, unitPrice: 2907.02, taxRate: 21.0, total: 7035.0),
      ],
      subtotal: 5814.04,
      taxAmount: 1220.96,
      total: 7035.0,
      currency: 'EUR',
      issueDate: DateTime(2026, 2, 24),
      dueDate: DateTime(2026, 3, 24),
      createdAt: DateTime(2026, 2, 24),
      updatedAt: DateTime(2026, 2, 24),
    ),
    Invoice(
      id: 'inv_4',
      number: 'INV-2026-089',
      status: InvoiceStatus.rejected,
      complianceStatus: ComplianceStatus.warnings,
      issuerId: 'org_1',
      issuerName: 'Mi Empresa S.L.',
      issuerNif: 'B12345678',
      receiverId: 'cli_4',
      receiverName: 'Tech Ventures Europe',
      receiverNif: 'B44332211',
      lines: [
        const InvoiceLine(id: 'l1', description: 'Auditoría de Seguridad', quantity: 1, unitPrice: 2793.38, taxRate: 21.0, total: 3380.0),
      ],
      subtotal: 2793.38,
      taxAmount: 586.62,
      total: 3380.0,
      currency: 'EUR',
      issueDate: DateTime(2026, 2, 22),
      dueDate: DateTime(2026, 3, 22),
      createdAt: DateTime(2026, 2, 22),
      updatedAt: DateTime(2026, 2, 22),
    ),
    Invoice(
      id: 'inv_5',
      number: 'INV-2026-088',
      status: InvoiceStatus.draft,
      complianceStatus: ComplianceStatus.pending,
      issuerId: 'org_1',
      issuerName: 'Mi Empresa S.L.',
      issuerNif: 'B12345678',
      receiverId: 'cli_5',
      receiverName: 'Consultoría la Rioja S.L.',
      receiverNif: 'B55667788',
      lines: [
        const InvoiceLine(id: 'l1', description: 'Renovación Licencias Anuales', quantity: 1, unitPrice: 10165.28, taxRate: 21.0, total: 12300.0),
      ],
      subtotal: 10165.28,
      taxAmount: 2134.72,
      total: 12300.0,
      currency: 'EUR',
      issueDate: DateTime(2026, 2, 20),
      dueDate: DateTime(2026, 3, 20),
      createdAt: DateTime(2026, 2, 20),
      updatedAt: DateTime(2026, 2, 20),
    ),
    Invoice(
      id: 'inv_6',
      number: 'INV-2026-087',
      status: InvoiceStatus.pendingReview,
      complianceStatus: ComplianceStatus.pass,
      issuerId: 'org_1',
      issuerName: 'Mi Empresa S.L.',
      issuerNif: 'B12345678',
      receiverId: 'cli_6',
      receiverName: 'Innovación Madrid',
      receiverNif: 'B99887766',
      lines: [
        const InvoiceLine(id: 'l1', description: 'Mantenimiento Servidores', quantity: 3, unitPrice: 500.0, taxRate: 21.0, total: 1815.0),
      ],
      subtotal: 1500.0,
      taxAmount: 315.0,
      total: 1815.0,
      currency: 'EUR',
      issueDate: DateTime(2026, 2, 18),
      dueDate: DateTime(2026, 3, 18),
      createdAt: DateTime(2026, 2, 18),
      updatedAt: DateTime(2026, 2, 18),
    ),
    // --- HISTORICAL Q1 (Jan/Feb) ---
    Invoice(
      id: 'inv_7',
      number: 'INV-2026-086',
      status: InvoiceStatus.accepted,
      complianceStatus: ComplianceStatus.pass,
      issuerId: 'org_1',
      issuerName: 'Mi Empresa S.L.',
      issuerNif: 'B12345678',
      receiverId: 'cli_3',
      receiverName: 'Servicios Castellón S.A.',
      receiverNif: 'A11223344',
      lines: [
        const InvoiceLine(id: 'l1', description: 'Auditoría Q1', quantity: 1, unitPrice: 4000.0, taxRate: 21.0, total: 4840.0),
      ],
      subtotal: 4000.0,
      taxAmount: 840.0,
      total: 4840.0,
      currency: 'EUR',
      issueDate: DateTime(2026, 1, 15),
      dueDate: DateTime(2026, 2, 15),
      createdAt: DateTime(2026, 1, 15),
      updatedAt: DateTime(2026, 1, 15),
    ),
    Invoice(
      id: 'inv_8',
      number: 'INV-2026-085',
      status: InvoiceStatus.accepted,
      complianceStatus: ComplianceStatus.pass,
      issuerId: 'org_1',
      issuerName: 'Mi Empresa S.L.',
      issuerNif: 'B12345678',
      receiverId: 'cli_1',
      receiverName: 'Acme Corporation S.L.',
      receiverNif: 'A87654321',
      lines: [
        const InvoiceLine(id: 'l1', description: 'Soporte Mensual Enero', quantity: 1, unitPrice: 1500.0, taxRate: 21.0, total: 1815.0),
      ],
      subtotal: 1500.0,
      taxAmount: 315.0,
      total: 1815.0,
      currency: 'EUR',
      issueDate: DateTime(2026, 1, 5),
      dueDate: DateTime(2026, 2, 5),
      createdAt: DateTime(2026, 1, 5),
      updatedAt: DateTime(2026, 1, 5),
    ),
    Invoice(
      id: 'inv_9',
      number: 'INV-2026-084',
      status: InvoiceStatus.accepted,
      complianceStatus: ComplianceStatus.pass,
      issuerId: 'org_1',
      issuerName: 'Mi Empresa S.L.',
      issuerNif: 'B12345678',
      receiverId: 'cli_2',
      receiverName: 'Digital Excellence Group',
      receiverNif: 'B98765432',
      lines: [
        const InvoiceLine(id: 'l1', description: 'Kickoff Proyecto', quantity: 1, unitPrice: 5000.0, taxRate: 21.0, total: 6050.0),
      ],
      subtotal: 5000.0,
      taxAmount: 1050.0,
      total: 6050.0,
      currency: 'EUR',
      issueDate: DateTime(2026, 1, 2),
      dueDate: DateTime(2026, 2, 2),
      createdAt: DateTime(2026, 1, 2),
      updatedAt: DateTime(2026, 1, 2),
    ), ..._generateFillers(),
  ];

  static List<Invoice> _generateFillers() {
    final fillers = <Invoice>[];
    // March fillers: 142 invoices
    for (int i = 0; i < 142; i++) {
        final status = i < 10 ? InvoiceStatus.pendingReview : (i < 12 ? InvoiceStatus.rejected : InvoiceStatus.sent);
        fillers.add(Invoice(
            id: 'inv_mar_filler_$i',
            number: 'INV-2026-M${(100+i).toString().padLeft(3, '0')}',
            status: status,
            complianceStatus: ComplianceStatus.pass,
            issuerId: 'org_1',
            issuerName: 'Mi Empresa S.L.',
            issuerNif: 'B12345678',
            receiverId: 'cli_gen_${i%5}',
            receiverName: 'Cliente Minorista ${i%5}',
            receiverNif: 'C0000$i',
            lines: const [InvoiceLine(id: 'l1', description: 'Servicios Básicos', quantity: 1, unitPrice: 103.30, taxRate: 21.0, total: 125.0)],
            subtotal: 103.30,
            taxAmount: 21.70,
            total: 125.0,
            currency: 'EUR',
            issueDate: DateTime(2026, 3, 15),
            createdAt: DateTime(2026, 3, 15),
            updatedAt: DateTime(2026, 3, 15),
        ));
    }
    // Feb fillers: 135 invoices
    for (int i = 0; i < 135; i++) {
         fillers.add(Invoice(
            id: 'inv_feb_filler_$i',
            number: 'INV-2026-F${(100+i).toString().padLeft(3, '0')}',
            status: InvoiceStatus.accepted,
            complianceStatus: ComplianceStatus.pass,
            issuerId: 'org_1',
            issuerName: 'Mi Empresa S.L.',
            issuerNif: 'B12345678',
            receiverId: 'cli_gen_${i%5}',
            receiverName: 'Cliente Minorista ${i%5}',
            receiverNif: 'C0000$i',
            lines: const [InvoiceLine(id: 'l1', description: 'Servicios Básicos', quantity: 1, unitPrice: 103.30, taxRate: 21.0, total: 125.0)],
            subtotal: 103.30,
            taxAmount: 21.70,
            total: 125.0,
            currency: 'EUR',
            issueDate: DateTime(2026, 2, 15),
            createdAt: DateTime(2026, 2, 15),
            updatedAt: DateTime(2026, 2, 15),
        ));
    }
    return fillers;
  }

  static Map<String, Map<String, String>> get dashboardKpis {
    final march = invoices.where((i) => i.issueDate.month == 3).toList();
    final feb = invoices.where((i) => i.issueDate.month == 2).toList();
    
    final marchTotal = march.fold<double>(0, (s, i) => s + i.total);
    final febTotal = feb.fold<double>(0, (s, i) => s + i.total);
    
    final marchCount = march.length;
    final febCount = feb.length;
    
    String format(double v) {
      final text = v.toStringAsFixed(0);
      return text.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    }
    
    final countGrowth = febCount == 0 ? 0 : ((marchCount - febCount) / febCount * 100).round();
    final revGrowth = febTotal == 0 ? 0 : ((marchTotal - febTotal) / febTotal * 100).round();
    
    final pendingList = invoices.where((i) => i.status == InvoiceStatus.pendingReview).toList();
    final pendingTotal = pendingList.fold<double>(0, (s, i) => s + i.total);
    
    final overdueList = invoices.where((i) => i.status == InvoiceStatus.rejected).toList();
    
    return {
      'emitted': {'value': '$marchCount', 'trend': '${countGrowth >= 0 ? '+' : ''}$countGrowth% vs mes anterior'},
      'revenue': {'value': '${format(marchTotal)} €', 'trend': '${revGrowth >= 0 ? '+' : ''}$revGrowth% vs mes anterior'},
      'pending': {'value': '${pendingList.length}', 'trend': '${format(pendingTotal)} € en total'},
      'overdue': {'value': '${overdueList.length}', 'trend': 'Atención requerida'},
    };
  }

  static const chartMonths = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  static List<double> get chartValues {
    final janTotal = invoices.where((i) => i.issueDate.month == 1).fold<double>(0, (s, i) => s + i.total) / 1000.0;
    final febTotal = invoices.where((i) => i.issueDate.month == 2).fold<double>(0, (s, i) => s + i.total) / 1000.0;
    final marchTotal = invoices.where((i) => i.issueDate.month == 3).fold<double>(0, (s, i) => s + i.total) / 1000.0;
    
    return [
      janTotal > 0 ? janTotal : 12.5, 
      febTotal > 0 ? febTotal : 14.2, 
      marchTotal > 0 ? marchTotal : 13.8, 
      18.5, 21.0, 19.5, 24.3, 22.1, 28.4, 30.5, 32.1, 34.5
    ];
  }

  static String getKpisSummary() {
    return '''
Facturas emitidas: ${dashboardKpis['emitted']?['value']} (${dashboardKpis['emitted']?['trend']}).
Ingresos del mes: ${dashboardKpis['revenue']?['value']} (${dashboardKpis['revenue']?['trend']}).
Facturas pendientes de cobro: ${dashboardKpis['pending']?['value']} (${dashboardKpis['pending']?['trend']}).
Facturas vencidas: ${dashboardKpis['overdue']?['value']} (${dashboardKpis['overdue']?['trend']}).
''';
  }

  static String getInvoicesSummary() {
    final march = invoices.where((i) => i.issueDate.month == 3).toList();
    final feb = invoices.where((i) => i.issueDate.month == 2).toList();
    final jan = invoices.where((i) => i.issueDate.month == 1).toList();
    
    double sum(List<Invoice> list) => list.fold(0, (s, i) => s + i.total);
    
    String summarizeMonth(String name, List<Invoice> list) {
      if (list.isEmpty) return '$name: 0 facturas.';
      final totalStr = sum(list).toStringAsFixed(0);
      
      final sorted = List<Invoice>.from(list)..sort((a,b) => b.total.compareTo(a.total));
      final top = sorted.take(3).map((i) => '  - \${i.number} a \${i.receiverName} por \${i.total} \${i.currency} (\${mapStatusToString(i.status)})').join('\n');
      
      final int others = list.length - 3;
      final String othersStr = others > 0 ? '\n  ...y $others facturas más de menor valor.' : '';
      return '$name: \${list.length} facturas emitidas por un total de $totalStr EUR.\nFacturas destacadas:\n$top$othersStr';
    }
    
    return [
      'Resumen Histórico Q1:',
      summarizeMonth('Marzo', march),
      summarizeMonth('Febrero', feb),
      summarizeMonth('Enero', jan),
    ].join('\n\n');
  }
  
  static String mapStatusToString(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Borrador';
      case InvoiceStatus.pendingReview:
        return 'Pendiente';
      case InvoiceStatus.readyToSend:
        return 'Lista para enviar';
      case InvoiceStatus.sent:
        return 'Enviada';
      case InvoiceStatus.accepted:
        return 'Aceptada';
      case InvoiceStatus.rejected:
        return 'Rechazada';
      case InvoiceStatus.cancelled:
        return 'Cancelada';
    }
  }

  static StatusType mapStatusToBadge(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
      case InvoiceStatus.pendingReview:
      case InvoiceStatus.readyToSend:
        return StatusType.info;
      case InvoiceStatus.sent:
      case InvoiceStatus.accepted:
        return StatusType.success;
      case InvoiceStatus.rejected:
      case InvoiceStatus.cancelled:
        return StatusType.error;
    }
  }

  static String mapComplianceStatusToString(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.pass:
        return 'Aprobado';
      case ComplianceStatus.warnings:
        return 'Advertencias';
      case ComplianceStatus.fail:
        return 'Fallido';
      case ComplianceStatus.pending:
        return 'Pendiente';
    }
  }

  static StatusType mapComplianceStatusToBadge(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.pass:
        return StatusType.success;
      case ComplianceStatus.warnings:
        return StatusType.warning;
      case ComplianceStatus.fail:
        return StatusType.error;
      case ComplianceStatus.pending:
        return StatusType.info;
    }
  }
}
