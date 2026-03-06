import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Card de estado de integridad de la cadena de registros.
///
/// Ref Pencil: Audit screen — Right column, "Estado de integridad" card.
class IntegrityCard extends StatelessWidget {
  final bool isIntact;
  final String lastHash;
  final int operationCount;

  const IntegrityCard({
    super.key,
    this.isIntact = true,
    this.lastHash = '0x4f2a...b3c1',
    this.operationCount = 1247,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      header: const GlassCardHeader(title: 'Estado de integridad'),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isIntact
                    ? context.colors.statusSuccessBg
                    : context.colors.statusErrorBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isIntact ? LucideIcons.shieldCheck : LucideIcons.shieldAlert,
                    size: 18,
                    color: isIntact
                        ? context.colors.statusSuccess
                        : context.colors.statusError,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isIntact ? 'Registros intactos' : 'Integridad comprometida',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isIntact
                              ? 'Cadena de registros verificada'
                              : 'Se detectaron inconsistencias',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Hash info
            Text(
              '\u00daltimo hash generado: $lastHash',
              style: TextStyle(
                fontSize: 11,
                color: context.colors.textTertiary,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 10),
            // Chain count
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _formatCount(operationCount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'operaciones registradas',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      final whole = count ~/ 1000;
      final remainder = (count % 1000) ~/ 100;
      return remainder > 0 ? '$whole,${count % 1000}' : '${whole}000';
    }
    return count.toString();
  }
}
