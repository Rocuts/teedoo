import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_toast.dart';

/// Tab de gesti\u00f3n de usuarios.
///
/// Muestra una tabla con usuarios de ejemplo y un bot\u00f3n de invitaci\u00f3n.
class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header -- stacks vertically on compact
        if (isCompact) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gesti\u00f3n de usuarios y roles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Configura los permisos de acceso de tu equipo',
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              PrimaryButton(
                label: 'Invitar usuario',
                icon: LucideIcons.userPlus,
                onPressed: () {
                  GlassToast.show(context, message: 'Abriendo panel de invitaci\u00f3n de usuarios...', type: StatusType.info);
                },
              ),
            ],
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gesti\u00f3n de usuarios y roles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Configura los permisos de acceso de tu equipo',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
              PrimaryButton(
                label: 'Invitar usuario',
                icon: LucideIcons.userPlus,
                onPressed: () {
                  GlassToast.show(context, message: 'Abriendo panel de invitaci\u00f3n de usuarios...', type: StatusType.info);
                },
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.s24),

        // Table -- horizontally scrollable for narrow screens
        GlassCard(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 700),
              child: IntrinsicWidth(
                child: Column(
                  children: [
                    // Table header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: context.colors.borderSubtle),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Nombre',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textTertiary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textTertiary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              'Rol',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textTertiary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              'Estado',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textTertiary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              'Acciones',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Rows
                    _buildUserRow(context,
                      name: 'Johan Rocuts',
                      email: 'johan@teedoo.es',
                      role: 'Admin',
                      status: StatusType.success,
                      statusLabel: 'Activo',
                    ),
                    _buildUserRow(context,
                      name: 'Mar\u00eda Garc\u00eda',
                      email: 'maria.garcia@teedoo.es',
                      role: 'Editor',
                      status: StatusType.success,
                      statusLabel: 'Activo',
                    ),
                    _buildUserRow(context,
                      name: 'Carlos L\u00f3pez',
                      email: 'carlos.lopez@teedoo.es',
                      role: 'Viewer',
                      status: StatusType.warning,
                      statusLabel: 'Pendiente',
                      showBorder: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserRow(BuildContext context, {
    required String name,
    required String email,
    required String role,
    required StatusType status,
    required String statusLabel,
    bool showBorder = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(color: context.colors.borderSubtle),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              email,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              role,
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: StatusBadge(
              label: statusLabel,
              type: status,
            ),
          ),
          SizedBox(
            width: 80,
            child: Icon(
              LucideIcons.moreHorizontal,
              size: 16,
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
