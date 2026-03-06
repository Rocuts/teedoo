import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Panel de estado de facturas — distribución actual.
///
/// Ref screenshot: "Estado de Facturas — Distribución actual"
class InvoiceStatusPanel extends StatelessWidget {
  const InvoiceStatusPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final items = [
      _StatusItem('Pagadas', 156, 72, colors.statusSuccess),
      _StatusItem('Pendientes', 42, 19, colors.statusWarning),
      _StatusItem('Vencidas', 12, 6, colors.statusError),
      _StatusItem('Canceladas', 8, 4, colors.textTertiary),
    ];

    return GlassCard(
      header: const GlassCardHeader(
        title: 'Estado de Facturas',
        subtitle: 'Distribución actual',
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Column(
          children: [
            // ── Bar visual ──
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 32,
                child: Row(
                  children: items.map((item) {
                    return Expanded(
                      flex: item.percent,
                      child: Container(color: item.color),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ── Legend items ──
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    '${item.count}',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${item.percent}%)',
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _StatusItem {
  final String label;
  final int count;
  final int percent;
  final Color color;

  const _StatusItem(this.label, this.count, this.percent, this.color);
}
