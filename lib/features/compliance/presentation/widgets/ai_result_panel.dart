import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../data/models/compliance_result.dart';
import '../../data/models/finding.dart';
import 'findings_list.dart';
import 'score_header.dart';

/// Panel izquierdo de resultados de compliance con score y hallazgos.
///
/// Ref Pencil: Results screen — Left panel (fill).
class AiResultPanel extends StatelessWidget {
  final ComplianceResult result;

  const AiResultPanel({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScoreHeader(result: result),
          const SizedBox(height: AppSpacing.s20),
          Expanded(child: FindingsList(findings: result.findings)),
        ],
      ),
    );
  }

  /// Datos mock para previsualización.
  static ComplianceResult get mockResult => ComplianceResult(
    id: 'chk-001',
    invoiceId: 'INV-2026-092',
    score: 78,
    level: ComplianceLevel.warnings,
    findings: mockFindings,
    regulationId: 'es-facturae',
    regulationVersion: 'SII 2026',
    analyzedAt: DateTime(2026, 3, 1, 15, 7),
    documentHash: '0x4f2a...b3c1',
  );

  static List<Finding> get mockFindings => const [
    Finding(
      id: 'f1',
      priority: FindingPriority.high,
      title: 'NIF del receptor no v\u00e1lido',
      description:
          'El campo TaxId del receptor contiene un formato no v\u00e1lido '
          'para el tipo de identificaci\u00f3n fiscal especificada (NIF), '
          'debe cumplir el formato 8 d\u00edgitos + letra.',
      fieldPath: 'ReceptorTaxId',
      xPath:
          '/fe:Facturae/Parties/BuyerParty/TaxIdentification/TaxIdentificationNumber',
    ),
    Finding(
      id: 'f2',
      priority: FindingPriority.high,
      title: 'Falta referencia de pedido obligatoria',
      description:
          'Real Decreto 8/29 de Espa\u00f1a, el campo OrderReference '
          'ya no es opcional. Incluir referencia cuando exista relaci\u00f3n '
          'comercial previa.',
      fieldPath: 'OrderReference',
      xPath: '/fe:Facturae/Invoices/Invoice/AdditionalData/RelatedDocuments',
    ),
    Finding(
      id: 'f3',
      priority: FindingPriority.medium,
      title: 'Descripci\u00f3n de l\u00ednea demasiado gen\u00e9rica',
      description:
          'La descripci\u00f3n \'Servicio\' no cumple la pr\u00e1ctica '
          'recomendada. Se recomienda una descripci\u00f3n de al menos '
          '10 caracteres.',
      fieldPath: 'InvoiceLine.Description',
    ),
    Finding(
      id: 'f4',
      priority: FindingPriority.low,
      title: 'C\u00f3digo de pa\u00eds no estandarizado',
      description:
          'El c\u00f3digo de pa\u00eds "ESP" deber\u00eda ser "ES" '
          'seg\u00fan ISO 3166-1 alpha-2.',
      fieldPath: 'CountryCode',
    ),
    Finding(
      id: 'f5',
      priority: FindingPriority.low,
      title: 'Formato de fecha no \u00f3ptimo',
      description:
          'La fecha usa formato DD/MM/YYYY, pero el est\u00e1ndar Facturae '
          'recomienda YYYY-MM-DD (ISO 8601).',
      fieldPath: 'IssueDate',
    ),
  ];
}
