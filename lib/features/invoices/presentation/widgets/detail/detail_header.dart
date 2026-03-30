import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/badges/status_badge.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../../shared/widgets/buttons/ghost_button.dart';
import '../../../../../shared/widgets/glass_toast.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/invoice_status.dart';

class DetailHeader extends StatelessWidget {
  final String invoiceNumber;
  final InvoiceStatus status;
  final ComplianceStatus complianceStatus;

  const DetailHeader({
    super.key,
    required this.invoiceNumber,
    required this.status,
    required this.complianceStatus,
  });

  @override
  Widget build(BuildContext context) {
    final titleAndBadges = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            invoiceNumber,
            style: AppTypography.h2.copyWith(color: context.colors.textPrimary),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        StatusBadge(label: status.label, type: status.badgeType),
        const SizedBox(width: AppSpacing.sm),
        StatusBadge(
          label: complianceStatus.label,
          type: complianceStatus.badgeType,
        ),
      ],
    );

    final actionButtons = [
      GhostButton(
        label: 'Duplicar',
        icon: LucideIcons.copy,
        onPressed: () {
          GlassToast.show(
            context,
            message: 'Factura duplicada en borradores',
            type: StatusType.success,
          );
        },
      ),
      const SizedBox(width: 8),
      SecondaryButton(
        label: 'Exportar',
        icon: LucideIcons.download,
        onPressed: () {
          GlassToast.show(
            context,
            message: 'Descarga de factura iniciada...',
            type: StatusType.info,
          );
        },
      ),
      const SizedBox(width: AppSpacing.buttonGap),
      PrimaryButton(
        label: 'Enviar',
        icon: LucideIcons.send,
        onPressed: () {
          GlassToast.show(
            context,
            message: 'Enviando al sistema del cliente...',
            type: StatusType.info,
          );
        },
      ),
    ];

    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleAndBadges,
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: actionButtons,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: titleAndBadges),
        Row(mainAxisSize: MainAxisSize.min, children: actionButtons),
      ],
    );
  }
}
