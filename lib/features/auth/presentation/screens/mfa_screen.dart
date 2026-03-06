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
import '../../../../shared/widgets/glass_toast.dart';
import '../../../../shared/widgets/badges/status_badge.dart';

/// Pantalla de MFA Challenge.
///
/// Ref Pencil: Auth - MFA Challenge (hO0Ik) — 1440x900
class MfaScreen extends StatelessWidget {
  const MfaScreen({super.key});

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
                  // Shield icon
                  Container(
                    width: AppDimensions.authIconSize,
                    height: AppDimensions.authIconSize,
                    decoration: BoxDecoration(
                      color: context.colors.accentBlueSubtle,
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Icon(
                      LucideIcons.shieldCheck,
                      color: context.colors.accentBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    'Verificación de seguridad',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: 340,
                    child: Text(
                      'Introduce el código de 6 dígitos de tu aplicación de autenticación',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 6 digit inputs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      final sampleDigits = ['3', '8', '4', '7', '', ''];
                      final isFocused = i == 3;
                      return Container(
                        width: 48,
                        height: 56,
                        margin: EdgeInsets.only(left: i > 0 ? 10 : 0),
                        decoration: BoxDecoration(
                          color: context.colors.bgInput,
                          borderRadius: AppRadius.mdAll,
                          border: Border.all(
                            color: isFocused
                                ? context.colors.accentBlue
                                : context.colors.borderSubtle,
                            width: isFocused ? 2 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          sampleDigits[i],
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    'El código expira en 4:32',
                    style: TextStyle(
                      color: context.colors.textTertiary,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  PrimaryButton(
                    label: 'Verificar',
                    isExpanded: true,
                    onPressed: () {
                      GlassToast.show(
                        context,
                        message: 'Código verificado correctamente',
                        type: StatusType.success,
                      );
                      Future.delayed(const Duration(seconds: 1), () {
                        if (context.mounted) context.go(RoutePaths.dashboard);
                      });
                    },
                  ),
                  const SizedBox(height: 28),

                  Text(
                    'Usar código de recuperación',
                    style: TextStyle(
                      color: context.colors.accentBlue,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
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
