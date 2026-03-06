import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Card de certificado digital.
///
/// Ref Pencil: Settings - Organization / Card 3
/// Muestra el estado del certificado y permite subir uno nuevo.
class CertificateCard extends StatelessWidget {
  final String? certificateName;
  final DateTime? certificateExpiry;
  final VoidCallback? onUpload;

  const CertificateCard({
    super.key,
    this.certificateName,
    this.certificateExpiry,
    this.onUpload,
  });

  String _formatExpiry(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      header: GlassCardHeader(
        title: 'Certificado digital',
        trailing: SizedBox(
          height: 34,
          child: SecondaryButton(
            label: 'Subir certificado',
            icon: LucideIcons.upload,
            onPressed: onUpload,
          ),
        ),
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Certificado necesario para la firma electr\u00f3nica de facturas. '
              'Compatible con formatos .p12 y .pfx.',
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            if (certificateName != null) ...[
              const SizedBox(height: AppSpacing.s16),
              _buildCertificateRow(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateRow(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: context.colors.bgInput,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.colors.statusSuccessBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              LucideIcons.shieldCheck,
              size: 16,
              color: context.colors.statusSuccess,
            ),
          ),
          const SizedBox(width: AppSpacing.xl),

          // Certificate info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                certificateName!,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textPrimary,
                ),
              ),
              if (certificateExpiry != null) ...[
                const SizedBox(height: 2),
                Text(
                  'V\u00e1lido hasta: ${_formatExpiry(certificateExpiry!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
