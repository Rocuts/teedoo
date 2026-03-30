import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../invoices/data/models/invoice_model.dart';

/// Panel de estado de facturas — distribución actual.
///
/// Ref screenshot: "Estado de Facturas — Distribución actual"
class InvoiceStatusPanel extends StatelessWidget {
  const InvoiceStatusPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final all = MockData.invoices;
    final total = all.length;

    final accepted = all
        .where((i) => i.status == InvoiceStatus.accepted)
        .length;
    final pending = all
        .where(
          (i) =>
              i.status == InvoiceStatus.pendingReview ||
              i.status == InvoiceStatus.sent ||
              i.status == InvoiceStatus.readyToSend,
        )
        .length;
    final overdue = all.where((i) => i.status == InvoiceStatus.rejected).length;
    final drafts = all
        .where(
          (i) =>
              i.status == InvoiceStatus.draft ||
              i.status == InvoiceStatus.cancelled,
        )
        .length;

    int pct(int count) => total == 0 ? 0 : (count * 100 / total).round();

    final items = [
      _StatusItem('Aceptadas', accepted, pct(accepted), colors.statusSuccess),
      _StatusItem('Pendientes', pending, pct(pending), colors.statusWarning),
      _StatusItem('Rechazadas', overdue, pct(overdue), colors.statusError),
      _StatusItem('Borradores', drafts, pct(drafts), colors.textTertiary),
    ];

    return GlassCard(
      header: const GlassCardHeader(
        title: 'Estado de Facturas',
        subtitle: 'Distribución actual',
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.xl,
          AppSpacing.s24,
          AppSpacing.s20,
        ),
        child: Column(
          children: [
            // ── Bar visual ──
            ClipRRect(
              borderRadius: AppRadius.smAll,
              child: SizedBox(
                height: AppSpacing.s32,
                child: Row(
                  children: items.where((item) => item.percent > 0).map((item) {
                    return Expanded(
                      flex: item.percent,
                      child: Container(color: item.color),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            // ── Legend items ──
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
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
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item.label,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '${item.count}',
                      style: AppTypography.h4.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '(${item.percent}%)',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
