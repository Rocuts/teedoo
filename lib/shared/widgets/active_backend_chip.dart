import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/session/data_source.dart';
import '../../core/session/data_source_provider.dart';
import '../../core/theme/app_colors_theme.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Tiny chip that surfaces which backend is serving the current screen
/// ("Servido por: Mongo" / "Servido por: Supabase"). Designed to sit in
/// the header of list/detail screens so the demo is self-evident.
///
/// Read-only — the switch happens via [DbTargetSelector].
class ActiveBackendChip extends ConsumerWidget {
  const ActiveBackendChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(dataSourceProvider);
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colors.accentBlueSubtle,
        borderRadius: AppRadius.badgeAll,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active == DataSource.mongo ? LucideIcons.leaf : LucideIcons.database,
            size: 12,
            color: colors.accentBlue,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Servido por: ${active.shortLabel}',
            style: AppTypography.captionMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
