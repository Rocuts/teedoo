import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';

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

  const ComplianceAlertItem({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: data.bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(data.icon, size: 18, color: data.iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
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

  const ComplianceAlertsList({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < alerts.length; i++) ...[
          ComplianceAlertItem(data: alerts[i]),
          if (i < alerts.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
