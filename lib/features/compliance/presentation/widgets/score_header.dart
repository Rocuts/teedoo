import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../data/models/compliance_result.dart';

/// Cabecera del resultado de compliance con score circular y acciones.
///
/// Ref Pencil: Results screen — Score header row.
class ScoreHeader extends StatelessWidget {
  final ComplianceResult result;
  final VoidCallback? onExport;
  final VoidCallback? onApplyFixes;

  const ScoreHeader({
    super.key,
    required this.result,
    this.onExport,
    this.onApplyFixes,
  });

  Color _scoreColor(BuildContext context) => switch (result.level) {
    ComplianceLevel.pass => context.colors.statusSuccess,
    ComplianceLevel.warnings => context.colors.statusWarning,
    ComplianceLevel.fail => context.colors.statusError,
  };

  StatusType get _statusType => switch (result.level) {
    ComplianceLevel.pass => StatusType.success,
    ComplianceLevel.warnings => StatusType.warning,
    ComplianceLevel.fail => StatusType.error,
  };

  String get _statusLabel => switch (result.level) {
    ComplianceLevel.pass => 'Pass',
    ComplianceLevel.warnings => 'Warnings',
    ComplianceLevel.fail => 'Fail',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Score circle
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _scoreColor(context), width: 4),
          ),
          alignment: Alignment.center,
          child: Text(
            result.score.toString(),
            style: AppTypography.h1.copyWith(color: context.colors.textPrimary),
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    result.invoiceId,
                    style: AppTypography.h4.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(label: _statusLabel, type: _statusType),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Espa\u00f1a \u2014 Facturae / VeriFActu \u00b7 Fecha: ${_formatDate(result.analyzedAt)}',
                style: AppTypography.captionSmall.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        // Actions
        SecondaryButton(
          label: 'Exportar reporte',
          icon: LucideIcons.download,
          onPressed: onExport ?? () {},
        ),
        const SizedBox(width: AppSpacing.sm),
        PrimaryButton(
          label: 'Aplicar correcciones',
          icon: LucideIcons.check,
          onPressed: onApplyFixes ?? () {},
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} $h:$m';
  }
}
