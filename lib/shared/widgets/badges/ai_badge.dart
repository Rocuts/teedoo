import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_radius.dart';

/// Badge de IA del Design System.
///
/// Ref Pencil: Component/Badge/AI (niEEB)
/// - Fill: ai-purple-bg
/// - Stroke: 1px ai-purple-border
/// - Icon sparkles 12x12
/// - Label 12px/600 ai-purple
class AIBadge extends StatelessWidget {
  final String label;

  const AIBadge({
    super.key,
    this.label = 'IA Compliance',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.aiPurpleBg,
        borderRadius: AppRadius.badgeAll,
        border: Border.all(color: context.colors.aiPurpleBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.sparkles,
            size: 12,
            color: context.colors.aiPurple,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.aiPurple,
            ),
          ),
        ],
      ),
    );
  }
}
