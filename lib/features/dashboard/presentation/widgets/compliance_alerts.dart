import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Datos de una alerta de compliance.
class ComplianceAlertData {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final Widget badge;

  const ComplianceAlertData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.badge,
  });
}

/// Widget de alerta individual de compliance.
///
/// Extraído del Dashboard para reutilización.
class ComplianceAlertItem extends StatelessWidget {
  final ComplianceAlertData data;

  const ComplianceAlertItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: data.bgColor,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(data.icon, size: 18, color: data.iconColor),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTypography.bodySmallMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          data.badge,
        ],
      ),
    );
  }
}

/// Lista de alertas de compliance.
///
/// Muestra múltiples [ComplianceAlertItem] en un Column.
class ComplianceAlertsList extends StatelessWidget {
  final List<ComplianceAlertData> alerts;

  const ComplianceAlertsList({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < alerts.length; i++) ...[
          ComplianceAlertItem(data: alerts[i]),
          if (i < alerts.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
