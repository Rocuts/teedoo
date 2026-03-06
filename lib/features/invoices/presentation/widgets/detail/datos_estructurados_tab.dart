import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../shared/widgets/glass_card.dart';

class DatosEstructuradosTab extends StatelessWidget {
  const DatosEstructuradosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      header: const GlassCardHeader(
        title: 'Datos estructurados',
        subtitle: 'Representación JSON de la factura según FacturaE',
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.bgInput,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: context.colors.borderSubtle),
          ),
          child: SelectableText(
            '{\n'
            '  "invoiceNumber": "INV-2026-092",\n'
            '  "issueDate": "2026-02-27",\n'
            '  "seller": {\n'
            '    "name": "Mi Empresa S.L.",\n'
            '    "taxId": "B12345678",\n'
            '    "address": "Calle Mayor 15, Madrid"\n'
            '  },\n'
            '  "buyer": {\n'
            '    "name": "Acme Corporation S.L.",\n'
            '    "taxId": "A98765432",\n'
            '    "address": "Av. Diagonal 100, Barcelona"\n'
            '  },\n'
            '  "lines": [\n'
            '    {\n'
            '      "description": "Consultoría de sistemas ERP",\n'
            '      "quantity": 40,\n'
            '      "unitPrice": 85.00,\n'
            '      "taxRate": 21,\n'
            '      "total": 4114.00\n'
            '    }\n'
            '  ],\n'
            '  "totals": {\n'
            '    "subtotal": 3400.00,\n'
            '    "tax": 714.00,\n'
            '    "total": 4114.00\n'
            '  }\n'
            '}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: context.colors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}
