import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_radius.dart';

/// Tipo de status para los badges.
enum StatusType { success, warning, error, info }

/// Badge de status del Design System.
///
/// Ref Pencil: Component/Badge/Success (5vHEe), Warning (FvPwn),
///             Error (NFFkU), Info (VI921)
/// - Radius: 6px
/// - Padding: 4/10
/// - Dot 6x6 + label 12px/600
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = switch (type) {
      StatusType.success => context.colors.statusSuccess,
      StatusType.warning => context.colors.statusWarning,
      StatusType.error => context.colors.statusError,
      StatusType.info => context.colors.statusInfo,
    };

    final Color statusBgColor = switch (type) {
      StatusType.success => context.colors.statusSuccessBg,
      StatusType.warning => context.colors.statusWarningBg,
      StatusType.error => context.colors.statusErrorBg,
      StatusType.info => context.colors.statusInfoBg,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: AppRadius.badgeAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
