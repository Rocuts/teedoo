import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/text_input.dart';
import '../../../../shared/widgets/glass_toast.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../providers/auth_provider.dart';

/// Pantalla de Login — responsive.
///
/// - Desktop: Card 880x520 con branding panel izquierdo + formulario derecho
/// - Tablet: Card mas estrecha, branding panel oculto
/// - Movil: Formulario full-width sin card glass, branding minimo arriba
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      GlassToast.show(
        context,
        message: 'Ingresa correo y contrasena',
        type: StatusType.warning,
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.login(email: email, password: password);

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go(RoutePaths.dashboard);
    } else if (authState.error != null) {
      GlassToast.show(
        context,
        message: authState.error!,
        type: StatusType.error,
      );
      authNotifier.clearError();
    }
  }

  Future<void> _handlePasskey() async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.loginWithPasskey();

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go(RoutePaths.dashboard);
    } else if (authState.error != null) {
      GlassToast.show(
        context,
        message: authState.error!,
        type: StatusType.error,
      );
      authNotifier.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    final isCompact = context.isCompact;
    final isMedium = context.isMedium;
    final authState = ref.watch(authProvider);

    if (isCompact) {
      return _buildMobileLogin(context, glass, authState);
    }

    // Tablet: card sin branding panel. Desktop: card completa.
    final cardWidth = isMedium ? 460.0 : 880.0;

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ClipRRect(
            borderRadius: AppRadius.lgAll,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: glass.blurSigma,
                sigmaY: glass.blurSigma,
              ),
              child: Container(
                width: cardWidth,
                constraints: const BoxConstraints(maxWidth: 880),
                decoration: BoxDecoration(
                  color: glass.cardFill,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: glass.glassBorder),
                ),
                child: isMedium
                    ? _buildFormPanel(context, authState)
                    : Row(
                        children: [
                          _buildBrandingPanel(context),
                          Expanded(child: _buildFormPanel(context, authState)),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Layout movil: formulario full-width con branding minimo arriba.
  Widget _buildMobileLogin(
    BuildContext context,
    GlassTheme glass,
    AuthState authState,
  ) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mini branding
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.colors.accentBlue,
                        borderRadius: AppRadius.smAll,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'T',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'TeDoo',
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Facturacion electronica inteligente',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 32),

                // Form in a glass card
                ClipRRect(
                  borderRadius: AppRadius.lgAll,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: glass.blurSigma,
                      sigmaY: glass.blurSigma,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: glass.cardFill,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(color: glass.glassBorder),
                      ),
                      child: _buildFormContent(context, authState),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingPanel(BuildContext context) {
    return Container(
      width: 380,
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x152563EB), Color(0x0009090B)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.colors.accentBlue,
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'T',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'TeDoo',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Facturacion electronica inteligente',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Gestiona tus facturas electronicas de forma segura, cumpliendo con la normativa vigente.',
            style: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPanel(BuildContext context, AuthState authState) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        child: _buildFormContent(context, authState),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Iniciar sesion',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa tus credenciales para acceder',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),

        // Email
        TeeDooTextField(
          label: 'Correo electronico',
          placeholder: 'test@teedoo.com',
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
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
                  'Contrasena',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(RoutePaths.forgotPassword),
                  child: Text(
                    'Olvide mi contrasena',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.accentBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TeeDooTextField(
              placeholder: '123456789',
              obscureText: true,
              controller: _passwordController,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Login button
        PrimaryButton(
          label: authState.isLoading ? 'Cargando...' : 'Iniciar sesion',
          isExpanded: true,
          onPressed: authState.isLoading ? null : _handleLogin,
        ),
        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: context.colors.borderSubtle)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'o continua con',
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.textTertiary,
                ),
              ),
            ),
            Expanded(child: Divider(color: context.colors.borderSubtle)),
          ],
        ),
        const SizedBox(height: 24),

        // Passkey button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: authState.isLoading ? null : _handlePasskey,
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
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
            ),
          ),
        ),
      ],
    );
  }
}
