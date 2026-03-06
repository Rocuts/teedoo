import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/text_input.dart';
import '../../../../shared/widgets/glass_toast.dart';
import '../../../../shared/widgets/badges/status_badge.dart';

/// Pantalla de Forgot Password.
///
/// Ref Pencil: Auth - Forgot Password (grRLL) — 1440x900
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: Center(
        child: ClipRRect(
          borderRadius: AppRadius.lgAll,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: glass.blurSigma,
              sigmaY: glass.blurSigma,
            ),
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(AppDimensions.authCardPadding),
              decoration: BoxDecoration(
                color: glass.cardFill,
                borderRadius: AppRadius.lgAll,
                border: Border.all(color: glass.glassBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppDimensions.authIconSize,
                    height: AppDimensions.authIconSize,
                    decoration: BoxDecoration(
                      color: context.colors.accentBlueSubtle,
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Icon(
                      LucideIcons.mail,
                      color: context.colors.accentBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Restablecer contraseña',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: 340,
                    child: Text(
                      'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const TeeDooTextField(
                    label: 'Correo electrónico',
                    placeholder: 'tu@empresa.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: 'Enviar enlace',
                    isExpanded: true,
                    onPressed: () {
                      GlassToast.show(
                        context,
                        message: 'Enlace de recuperación enviado al correo',
                        type: StatusType.success,
                      );
                      Future.delayed(const Duration(seconds: 2), () {
                        if (context.mounted) context.go(RoutePaths.login);
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: () => context.go(RoutePaths.login),
                    child: Text(
                      'Volver al inicio de sesión',
                      style: TextStyle(
                        color: context.colors.accentBlue,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
