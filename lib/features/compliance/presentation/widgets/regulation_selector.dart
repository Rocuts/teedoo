import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/regulation.dart';

/// Selector de regulaciones con radio buttons estilizados.
///
/// Ref Pencil: Quick Check — Regulación card options.
class RegulationSelector extends StatelessWidget {
  final List<Regulation> regulations;
  final String? selectedId;
  final ValueChanged<String>? onSelected;

  const RegulationSelector({
    super.key,
    required this.regulations,
    this.selectedId,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < regulations.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          _RegulationOption(
            regulation: regulations[i],
            isSelected: regulations[i].id == selectedId,
            onTap: regulations[i].isActive
                ? () => onSelected?.call(regulations[i].id)
                : null,
          ),
        ],
      ],
    );
  }
}

class _RegulationOption extends StatelessWidget {
  final Regulation regulation;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RegulationOption({
    required this.regulation,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = !regulation.isActive && !isSelected;
    final opacity = isDisabled && regulation.description == null ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: MouseRegion(
        cursor: regulation.isActive
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colors.accentBlueSubtle
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected
                    ? context.colors.accentBlue
                    : context.colors.borderSubtle,
              ),
            ),
            child: Row(
              children: [
                // Radio dot
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? context.colors.accentBlue
                          : context.colors.borderSubtle,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: context.colors.accentBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.lg),
                // Flag placeholder
                Container(
                  width: 24,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.colors.bgInput,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: context.colors.borderSubtle,
                      width: 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    regulation.country.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Text column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${regulation.country} \u2014 ${regulation.name}',
                        style: AppTypography.bodySmallMedium.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (regulation.isActive)
                        Text(
                          '${regulation.version} (activo)',
                          style: AppTypography.captionSmall.copyWith(
                            color: context.colors.accentBlue,
                          ),
                        )
                      else
                        Text(
                          'Coming soon',
                          style: AppTypography.captionSmall.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
