import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/session/data_source.dart';
import '../../core/session/data_source_provider.dart';
import '../../core/theme/app_colors_theme.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

/// Segmented selector that switches the active backend
/// (MongoDB ↔ Supabase) for the current session.
///
/// Reads / writes [dataSourceProvider]. Uses Material 3 `SegmentedButton`
/// themed inline to blend with the glass surface — the app's design system
/// does not yet expose a dedicated SegmentedButton token set, so this is
/// the minimal cohesive option (`teedoo-design-system` owns the follow-up
/// if we want a fully glass-morphic variant).
///
/// Responsive: on compact screens (< 600 px) shows short labels only
/// (`Mongo` / `Supabase`). Icon-only mode is avoided so the demo remains
/// legible.
class DbTargetSelector extends ConsumerWidget {
  const DbTargetSelector({super.key, this.compact = false});

  /// When true (or when the viewport is < 600 px), icons are hidden and
  /// only the short label is shown. Useful when embedded in a dense toolbar.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(dataSourceProvider);
    final colors = context.colors;
    final screenCompact =
        compact || MediaQuery.sizeOf(context).width < 600;

    return Theme(
      data: Theme.of(context).copyWith(
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            textStyle: WidgetStatePropertyAll(AppTypography.captionMedium),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colors.textOnAccent;
              }
              return colors.textSecondary;
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colors.accentBlue;
              }
              return colors.bgGlass;
            }),
            side: WidgetStatePropertyAll(
              BorderSide(color: colors.borderSubtle),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
            ),
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(
                horizontal: screenCompact ? 10 : 14,
                vertical: 8,
              ),
            ),
          ),
        ),
      ),
      child: SegmentedButton<DataSource>(
        showSelectedIcon: false,
        segments: <ButtonSegment<DataSource>>[
          ButtonSegment<DataSource>(
            value: DataSource.mongo,
            label: Text(
              screenCompact
                  ? DataSource.mongo.shortLabel
                  : DataSource.mongo.label,
            ),
            icon: screenCompact ? null : const Icon(LucideIcons.leaf, size: 14),
          ),
          ButtonSegment<DataSource>(
            value: DataSource.postgres,
            label: Text(
              screenCompact
                  ? DataSource.postgres.shortLabel
                  : DataSource.postgres.label,
            ),
            icon: screenCompact
                ? null
                : const Icon(LucideIcons.database, size: 14),
          ),
        ],
        selected: <DataSource>{active},
        onSelectionChanged: (Set<DataSource> s) {
          final next = s.first;
          if (next == active) return;
          ref.read(dataSourceProvider.notifier).state = next;
        },
      ),
    );
  }
}
