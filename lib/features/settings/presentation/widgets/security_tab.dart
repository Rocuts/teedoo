import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_toast.dart';

/// Tab de seguridad.
///
/// Secciones: MFA, sesiones activas, API keys, contrase\u00f1a.
class SecurityTab extends StatelessWidget {
  const SecurityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Seguridad',
          style: AppTypography.h4.copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Gestiona la seguridad de tu cuenta y las claves de acceso',
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        // MFA Section
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    LucideIcons.shieldCheck,
                    size: 18,
                    color: context.colors.accentBlue,
                  ),
                  Text(
                    'Autenticaci\u00f3n multifactor (MFA)',
                    style: AppTypography.h4.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const StatusBadge(label: 'Activo', type: StatusType.success),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildMfaOption(
                context,
                label: 'TOTP (Aplicaci\u00f3n autenticadora)',
                description: 'Google Authenticator, Authy, etc.',
                isEnabled: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildMfaOption(
                context,
                label: 'SMS',
                description:
                    'C\u00f3digo de verificaci\u00f3n por mensaje de texto',
                isEnabled: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        // Sessions Section
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.monitor,
                    size: 18,
                    color: context.colors.accentBlue,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Sesiones activas',
                      style: AppTypography.h4.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildSessionRow(
                context,
                device: 'MacBook Pro \u2014 Chrome 122',
                location: 'Madrid, Espa\u00f1a',
                time: 'Sesi\u00f3n actual',
                isCurrent: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSessionRow(
                context,
                device: 'iPhone 15 Pro \u2014 Safari',
                location: 'Madrid, Espa\u00f1a',
                time: 'Hace 2 horas',
                isCurrent: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        // API Keys Section
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact) ...[
                Row(
                  children: [
                    Icon(
                      LucideIcons.key,
                      size: 18,
                      color: context.colors.accentBlue,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Claves API',
                        style: AppTypography.h4.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                SecondaryButton(
                  label: 'Crear clave',
                  icon: LucideIcons.plus,
                  onPressed: () {
                    GlassToast.show(
                      context,
                      message:
                          'Funci\u00f3n de creaci\u00f3n de claves API en desarrollo...',
                      type: StatusType.info,
                    );
                  },
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(
                      LucideIcons.key,
                      size: 18,
                      color: context.colors.accentBlue,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Claves API',
                      style: AppTypography.h4.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    SecondaryButton(
                      label: 'Crear clave',
                      icon: LucideIcons.plus,
                      onPressed: () {
                        GlassToast.show(
                          context,
                          message:
                              'Funci\u00f3n de creaci\u00f3n de claves API en desarrollo...',
                          type: StatusType.info,
                        );
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.s16),
              _buildApiKeyRow(
                context,
                name: 'Producci\u00f3n',
                key: 'td_live_****...****7f2a',
                created: '15 Ene 2026',
                isCompact: isCompact,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildApiKeyRow(
                context,
                name: 'Desarrollo',
                key: 'td_test_****...****3b9c',
                created: '03 Feb 2026',
                isCompact: isCompact,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        // Password Section
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.lock,
                          size: 18,
                          color: context.colors.accentBlue,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Contrase\u00f1a',
                            style: AppTypography.h4.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '\u00daltimo cambio: hace 45 d\u00edas',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    PrimaryButton(
                      label: 'Cambiar contrase\u00f1a',
                      onPressed: () {
                        GlassToast.show(
                          context,
                          message:
                              'Solicitud de cambio de contrase\u00f1a enviada',
                          type: StatusType.success,
                        );
                      },
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      LucideIcons.lock,
                      size: 18,
                      color: context.colors.accentBlue,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contrase\u00f1a',
                            style: AppTypography.h4.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '\u00daltimo cambio: hace 45 d\u00edas',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PrimaryButton(
                      label: 'Cambiar contrase\u00f1a',
                      onPressed: () {
                        GlassToast.show(
                          context,
                          message:
                              'Solicitud de cambio de contrase\u00f1a enviada',
                          type: StatusType.success,
                        );
                      },
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMfaOption(
    BuildContext context, {
    required String label,
    required String description,
    required bool isEnabled,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmallMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.caption.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        // Toggle
        Container(
          width: 40,
          height: 22,
          decoration: BoxDecoration(
            color: isEnabled
                ? context.colors.accentBlue
                : context.colors.borderSubtle,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionRow(
    BuildContext context, {
    required String device,
    required String location,
    required String time,
    required bool isCurrent,
  }) {
    return Row(
      children: [
        Icon(
          isCurrent ? LucideIcons.monitor : LucideIcons.smartphone,
          size: 16,
          color: context.colors.textTertiary,
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device,
                style: AppTypography.bodySmallMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$location \u00b7 $time',
                style: AppTypography.caption.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        if (isCurrent)
          const StatusBadge(label: 'Actual', type: StatusType.info),
      ],
    );
  }

  Widget _buildApiKeyRow(
    BuildContext context, {
    required String name,
    required String key,
    required String created,
    bool isCompact = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.bgInput,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.key,
                      size: 14,
                      color: context.colors.textTertiary,
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      child: Text(
                        name,
                        style: AppTypography.bodySmallMedium.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 14 + AppSpacing.xl),
                  child: Text(
                    key,
                    style: AppTypography.caption.copyWith(
                      fontFamily: 'monospace',
                      color: context.colors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 14 + AppSpacing.xl),
                  child: Text(
                    'Creada: $created',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Icon(
                  LucideIcons.key,
                  size: 14,
                  color: context.colors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.bodySmallMedium.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        key,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Creada: $created',
                  style: AppTypography.captionSmall.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
    );
  }
}
