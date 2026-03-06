import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Card de subida de logotipo de la empresa.
///
/// Ref Pencil: Settings - Organization / Card 2
/// Layout: Row con texto a la izquierda y zona de upload a la derecha.
/// On compact screens the layout stacks vertically.
class LogoUploadCard extends StatelessWidget {
  final String? logoUrl;
  final VoidCallback? onUpload;

  const LogoUploadCard({
    super.key,
    this.logoUrl,
    this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    final description = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logotipo de la empresa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Se mostrar\u00e1 en tus facturas y documentos. '
          'Formato PNG o SVG, m\u00e1ximo 2MB.',
          style: TextStyle(
            fontSize: 13,
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );

    final uploadArea = GestureDetector(
      onTap: onUpload,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: 160,
          height: 100,
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: context.colors.borderSubtle,
              radius: 12,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.upload,
                  size: 20,
                  color: context.colors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Subir logo',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (isCompact) {
      // Compact: stack vertically
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            description,
            const SizedBox(height: AppSpacing.s16),
            uploadArea,
          ],
        ),
      );
    }

    // Medium / Expanded: side-by-side row
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Left: Title + Description --
          Expanded(child: description),
          const SizedBox(width: AppSpacing.s24),

          // -- Right: Upload Area --
          uploadArea,
        ],
      ),
    );
  }
}

/// Painter para simular un borde punteado con esquinas redondeadas.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  static const double _dashWidth = 6;
  static const double _dashSpace = 4;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + _dashWidth).clamp(0.0, metric.length);
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance += _dashWidth + _dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}
