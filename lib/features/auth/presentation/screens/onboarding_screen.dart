import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/buttons/ghost_button.dart';
import '../../../../shared/widgets/inputs/text_input.dart';
import '../../../../shared/widgets/inputs/select_input.dart';
import '../widgets/onboarding_stepper.dart';

/// Pantalla de Onboarding (wizard 4 pasos).
///
/// Ref Pencil: Auth - Onboarding (Z7HXm) — 1440x900
/// Pasos: Organización -> Facturación -> Integraciones -> Confirmación
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;

  static const _stepLabels = [
    'Organización',
    'Facturación',
    'Integraciones',
    'Confirmación',
  ];

  // ── Step 1 state ──
  String? _pais = 'es';
  String? _idioma = 'es';

  // ── Step 2 state ──
  String? _regimenFiscal = 'general';
  String? _moneda = 'eur';

  void _nextStep() {
    if (_currentStep < _stepLabels.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Stepper ──
              OnboardingStepper(steps: _stepLabels, currentStep: _currentStep),
              const SizedBox(height: AppSpacing.s32),

              // ── Card ──
              // RepaintBoundary prevents BackdropFilter from causing
              // flickering when step content changes
              RepaintBoundary(
                child: ClipRRect(
                  borderRadius: AppRadius.lgAll,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: glass.blurSigma,
                      sigmaY: glass.blurSigma,
                    ),
                    child: Container(
                      width: 560,
                      decoration: BoxDecoration(
                        color: glass.cardFill,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(color: glass.glassBorder),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.s40),
                      // ValueKey ensures Flutter rebuilds the widget tree on step change
                      child: KeyedSubtree(
                        key: ValueKey<int>(_currentStep),
                        child: _buildCurrentStep(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStepOrganizacion();
      case 1:
        return _buildStepFacturacion();
      case 2:
        return _buildStepIntegraciones();
      case 3:
        return _buildStepConfirmacion();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────
  // Step 1 — Organización
  // ─────────────────────────────────────────────
  Widget _buildStepOrganizacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Crear organización',
          style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Configura los datos principales de tu empresa',
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        // Row 1: Nombre + NIF
        const Row(
          children: [
            Expanded(
              child: TeeDooTextField(
                label: 'Nombre de la empresa',
                placeholder: 'Mi Empresa S.L.',
              ),
            ),
            SizedBox(width: AppSpacing.s16),
            Expanded(
              child: TeeDooTextField(
                label: 'NIF / CIF',
                placeholder: 'B12345678',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),

        // Row 2: Dirección
        const TeeDooTextField(
          label: 'Dirección',
          placeholder: 'Calle Gran Vía 28, Madrid',
        ),
        const SizedBox(height: AppSpacing.s16),

        // Row 3: País + Idioma
        Row(
          children: [
            Expanded(
              child: TeeDooSelect(
                label: 'País',
                value: _pais,
                options: const [
                  SelectOption(value: 'es', label: 'España'),
                  SelectOption(value: 'pt', label: 'Portugal'),
                  SelectOption(value: 'fr', label: 'Francia'),
                  SelectOption(value: 'de', label: 'Alemania'),
                ],
                onChanged: (value) => setState(() => _pais = value),
              ),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: TeeDooSelect(
                label: 'Idioma',
                value: _idioma,
                options: const [
                  SelectOption(value: 'es', label: 'Español'),
                  SelectOption(value: 'en', label: 'English'),
                  SelectOption(value: 'pt', label: 'Português'),
                  SelectOption(value: 'fr', label: 'Français'),
                ],
                onChanged: (value) => setState(() => _idioma = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s32),

        // Footer
        _buildFooter(
          leftText: 'Paso 1 de 4',
          showBack: false,
          nextLabel: 'Siguiente',
          nextIcon: LucideIcons.arrowRight,
          onNext: _nextStep,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Step 2 — Facturación
  // ─────────────────────────────────────────────
  Widget _buildStepFacturacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Configuración fiscal',
          style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Define los parámetros de facturación de tu empresa',
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        // Régimen fiscal
        TeeDooSelect(
          label: 'Régimen fiscal',
          value: _regimenFiscal,
          options: const [
            SelectOption(value: 'general', label: 'Régimen General'),
            SelectOption(value: 'simplificado', label: 'Régimen Simplificado'),
            SelectOption(value: 'recargo', label: 'Recargo de Equivalencia'),
          ],
          onChanged: (value) => setState(() => _regimenFiscal = value),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Moneda principal
        TeeDooSelect(
          label: 'Moneda principal',
          value: _moneda,
          options: const [
            SelectOption(value: 'eur', label: 'EUR — Euro'),
            SelectOption(value: 'usd', label: 'USD — Dólar'),
            SelectOption(value: 'gbp', label: 'GBP — Libra'),
          ],
          onChanged: (value) => setState(() => _moneda = value),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Serie de facturas + Siguiente número
        const Row(
          children: [
            Expanded(
              child: TeeDooTextField(
                label: 'Serie de facturas',
                placeholder: 'FACT-',
              ),
            ),
            SizedBox(width: AppSpacing.s16),
            Expanded(
              child: TeeDooTextField(
                label: 'Siguiente número',
                placeholder: '000001',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s32),

        // Footer
        _buildFooter(
          leftText: 'Paso 2 de 4',
          showBack: true,
          nextLabel: 'Siguiente',
          nextIcon: LucideIcons.arrowRight,
          onBack: _previousStep,
          onNext: _nextStep,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Step 3 — Integraciones
  // ─────────────────────────────────────────────
  Widget _buildStepIntegraciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Integraciones',
          style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Conecta con tus herramientas existentes (opcional)',
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        // Integration cards
        _IntegrationTile(
          icon: LucideIcons.server,
          title: 'Conectar ERP',
          description: 'SAP, Oracle, Dynamics...',
          onConfigure: () {},
        ),
        const SizedBox(height: AppSpacing.xl),
        _IntegrationTile(
          icon: LucideIcons.mail,
          title: 'Servicio de email',
          description: 'Para envío automático de facturas',
          onConfigure: () {},
        ),
        const SizedBox(height: AppSpacing.xl),
        _IntegrationTile(
          icon: LucideIcons.code,
          title: 'API & Webhooks',
          description: 'Integración programática',
          onConfigure: () {},
        ),
        const SizedBox(height: AppSpacing.s32),

        // Footer
        _buildFooter(
          leftText: 'Paso 3 de 4',
          showBack: true,
          nextLabel: 'Omitir',
          nextIcon: LucideIcons.arrowRight,
          onBack: _previousStep,
          onNext: _nextStep,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Step 4 — Confirmación
  // ─────────────────────────────────────────────
  Widget _buildStepConfirmacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: context.colors.statusSuccessBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.checkCircle2,
            size: 32,
            color: context.colors.statusSuccess,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        Text(
          'Todo listo',
          style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Tu organización está configurada. Revisa el resumen.',
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s24),

        // Summary card
        _buildSummaryCard(),
        const SizedBox(height: AppSpacing.s32),

        // Action
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: 'Ir al Dashboard',
            icon: LucideIcons.arrowRight,
            isExpanded: true,
            onPressed: () => context.go(RoutePaths.dashboard),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: context.colors.bgGlass,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: const Column(
        children: [
          _SummaryRow(label: 'Empresa', value: 'Mi Empresa S.L.'),
          SizedBox(height: AppSpacing.xl),
          _SummaryRow(label: 'NIF / CIF', value: 'B12345678'),
          SizedBox(height: AppSpacing.xl),
          _SummaryRow(label: 'País', value: 'España'),
          SizedBox(height: AppSpacing.xl),
          _SummaryRow(label: 'Régimen fiscal', value: 'Régimen General'),
          SizedBox(height: AppSpacing.xl),
          _SummaryRow(label: 'Moneda', value: 'EUR — Euro'),
          SizedBox(height: AppSpacing.xl),
          _SummaryRow(label: 'Serie', value: 'FACT-000001'),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Footer helper
  // ─────────────────────────────────────────────
  Widget _buildFooter({
    required String leftText,
    required bool showBack,
    required String nextLabel,
    IconData? nextIcon,
    VoidCallback? onBack,
    VoidCallback? onNext,
  }) {
    return Row(
      children: [
        // Step counter
        Text(
          leftText,
          style: AppTypography.caption.copyWith(
            color: context.colors.textTertiary,
          ),
        ),
        const Spacer(),

        // Back button
        if (showBack) ...[
          SecondaryButton(label: 'Anterior', onPressed: onBack),
          const SizedBox(width: AppSpacing.buttonGap),
        ],

        // Next button
        PrimaryButton(label: nextLabel, icon: nextIcon, onPressed: onNext),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Integration tile (glass style)
// ─────────────────────────────────────────────
class _IntegrationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onConfigure;

  const _IntegrationTile({
    required this.icon,
    required this.title,
    required this.description,
    this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: context.colors.bgGlass,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.accentBlueSubtle,
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(icon, size: 20, color: context.colors.accentBlue),
          ),
          const SizedBox(width: AppSpacing.s16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Configure button
          GhostButton(label: 'Configurar', onPressed: onConfigure),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Summary row for confirmation step
// ─────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textTertiary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySmallMedium.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
