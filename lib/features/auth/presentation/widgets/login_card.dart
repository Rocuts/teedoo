import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/text_input.dart';

/// Tarjeta de formulario de login extraída de [LoginScreen].
///
/// Contiene: email, contraseña, botón login, divider, botón passkey.
/// Reutilizable como widget independiente.
class LoginCard extends StatelessWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onPasskey;

  const LoginCard({super.key, this.onLogin, this.onPasskey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Iniciar sesión',
            style: AppTypography.h2.copyWith(color: context.colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ingresa tus credenciales para acceder',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s24),

          // Email
          const TeeDooTextField(
            label: 'Correo electrónico',
            placeholder: 'tu@empresa.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.s24),

          // Password
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contraseña',
                    style: AppTypography.captionMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(RoutePaths.forgotPassword),
                    child: Text(
                      'Olvidé mi contraseña',
                      style: AppTypography.caption.copyWith(
                        color: context.colors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const TeeDooTextField(placeholder: '••••••••', obscureText: true),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),

          // Login button
          PrimaryButton(
            label: 'Iniciar sesión',
            isExpanded: true,
            onPressed: onLogin ?? () => context.go(RoutePaths.dashboard),
          ),
          const SizedBox(height: AppSpacing.s24),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: context.colors.borderSubtle)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'o continúa con',
                  style: AppTypography.captionSmall.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: context.colors.borderSubtle)),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),

          // Passkey button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onPasskey ?? () {},
              icon: Icon(
                LucideIcons.keyRound,
                size: 16,
                color: context.colors.textSecondary,
              ),
              label: Text(
                'Continuar con passkey',
                style: AppTypography.bodySmallMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.colors.borderSubtle),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
