import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/badges/status_badge.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../../shared/widgets/buttons/ghost_button.dart';
import '../../../../../shared/widgets/glass_toast.dart';

class DetailHeader extends StatelessWidget {
  final String invoiceNumber;

  const DetailHeader({
    super.key,
    required this.invoiceNumber,
  });

  @override
  Widget build(BuildContext context) {
    final titleAndBadges = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            invoiceNumber,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const StatusBadge(
          label: 'Enviada',
          type: StatusType.success,
        ),
        const SizedBox(width: 8),
        const StatusBadge(
          label: 'Pass',
          type: StatusType.success,
        ),
      ],
    );

    final actionButtons = [
      GhostButton(
        label: 'Duplicar',
        icon: LucideIcons.copy,
        onPressed: () {
          GlassToast.show(context,
              message: 'Factura duplicada en borradores',
              type: StatusType.success);
        },
      ),
      const SizedBox(width: 8),
      SecondaryButton(
        label: 'Exportar',
        icon: LucideIcons.download,
        onPressed: () {
          GlassToast.show(context,
              message: 'Descarga de factura iniciada...',
              type: StatusType.info);
        },
      ),
      const SizedBox(width: AppSpacing.buttonGap),
      PrimaryButton(
        label: 'Enviar',
        icon: LucideIcons.send,
        onPressed: () {
          GlassToast.show(context,
              message: 'Enviando al sistema del cliente...',
              type: StatusType.info);
        },
      ),
    ];

    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleAndBadges,
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actionButtons,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: titleAndBadges),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: actionButtons,
        ),
      ],
    );
  }
}
