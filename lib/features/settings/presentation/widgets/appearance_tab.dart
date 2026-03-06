import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Tab de apariencia (tema).
///
/// Permite seleccionar entre Tema Claro, Oscuro o Automático del sistema.
class AppearanceTab extends ConsumerWidget {
  const AppearanceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Apariencia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Personaliza el tema visual de TeDoo',
          style: TextStyle(
            fontSize: 13,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        // Theme selector card
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modo de Tema',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Row(
                children: [
                  _buildThemeOption(
                    context: context,
                    label: 'Claro',
                    icon: LucideIcons.sun,
                    isSelected: currentTheme == AppThemeMode.light,
                    onTap: () {
                      ref.read(themeModeProvider.notifier).state =
                          AppThemeMode.light;
                    },
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildThemeOption(
                    context: context,
                    label: 'Oscuro',
                    icon: LucideIcons.moon,
                    isSelected: currentTheme == AppThemeMode.dark,
                    onTap: () {
                      ref.read(themeModeProvider.notifier).state =
                          AppThemeMode.dark;
                    },
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildThemeOption(
                    context: context,
                    label: 'Automático',
                    icon: LucideIcons.monitor,
                    isSelected: currentTheme == AppThemeMode.system,
                    onTap: () {
                      ref.read(themeModeProvider.notifier).state =
                          AppThemeMode.system;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colors.accentBlueSubtle
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              border: Border.all(
                color: isSelected
                    ? context.colors.accentBlue
                    : context.colors.borderSubtle,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? context.colors.accentBlue
                      : context.colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? context.colors.accentBlue
                        : context.colors.textSecondary,
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
