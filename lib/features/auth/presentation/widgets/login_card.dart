import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
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

  const LoginCard({
    super.key,
    this.onLogin,
    this.onPasskey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Iniciar sesión',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tus credenciales para acceder',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // Email
          const TeeDooTextField(
            label: 'Correo electrónico',
            placeholder: 'tu@empresa.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),

          // Password
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contraseña',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(RoutePaths.forgotPassword),
                    child: Text(
                      'Olvidé mi contraseña',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const TeeDooTextField(
                placeholder: '••••••••',
                obscureText: true,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Login button
          PrimaryButton(
            label: 'Iniciar sesión',
            isExpanded: true,
            onPressed: onLogin ?? () => context.go(RoutePaths.dashboard),
          ),
          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(color: context.colors.borderSubtle),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'o continúa con',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: context.colors.borderSubtle),
              ),
            ],
          ),
          const SizedBox(height: 24),

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
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textSecondary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.colors.borderSubtle),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdAll,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
