import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_toast.dart';
import '../../../../shared/widgets/badges/status_badge.dart';

/// Tab de integraciones.
///
/// Muestra 4 cards de integraci\u00f3n disponibles:
/// ERP, Email, API REST, Webhooks.
class IntegrationsTab extends StatelessWidget {
  const IntegrationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Integraciones',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Conecta TeDoo con tus herramientas y servicios externos',
          style: TextStyle(
            fontSize: 13,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),

        // Integration cards grid
        Row(
          children: [
            Expanded(
              child: _buildIntegrationCard(
                context,
                icon: LucideIcons.server,
                iconColor: context.colors.accentBlue,
                iconBg: context.colors.accentBlueSubtle,
                title: 'Conectar con tu ERP',
                description: 'SAP, Oracle, Microsoft Dynamics',
              ),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: _buildIntegrationCard(
                context,
                icon: LucideIcons.mail,
                iconColor: context.colors.statusSuccess,
                iconBg: context.colors.statusSuccessBg,
                title: 'Servicio de correo',
                description: 'Para env\u00edo autom\u00e1tico de facturas',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        Row(
          children: [
            Expanded(
              child: _buildIntegrationCard(
                context,
                icon: LucideIcons.code,
                iconColor: context.colors.aiPurple,
                iconBg: context.colors.aiPurpleBg,
                title: 'API REST',
                description: 'Documentaci\u00f3n y claves de acceso',
              ),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: _buildIntegrationCard(
                context,
                icon: LucideIcons.webhook,
                iconColor: context.colors.statusWarning,
                iconBg: context.colors.statusWarningBg,
                title: 'Webhooks',
                description: 'Notificaciones en tiempo real',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntegrationCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String description,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          SecondaryButton(
            label: 'Configurar',
            onPressed: () {
                GlassToast.show(context, message: 'Iniciando flujo de conexión segura con la integración...', type: StatusType.info);
            },
          ),
        ],
      ),
    );
  }
}
