import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors_theme.dart';


/// File dropzone del Design System.
///
/// Ref Pencil: Compliance Quick Check
/// - Dashed border container (simulated via CustomPaint)
/// - Upload icon (lucide upload, 24px, text-tertiary)
/// - Text "Arrastra PDF, XML, UBL o Facturae" (13px text-tertiary)
/// - Text "o haz clic para seleccionar" (12px accent-blue)
/// - Height: 180, radius: 14, fill: bg-input
class FileDropzone extends StatefulWidget {
  final ValueChanged<List<PlatformFile>>? onFilesDropped;
  final String description;
  final String actionText;
  final List<String>? allowedExtensions;

  const FileDropzone({
    super.key,
    this.onFilesDropped,
    this.description = 'Arrastra PDF, XML, UBL o Facturae',
    this.actionText = 'o haz clic para seleccionar',
    this.allowedExtensions,
  });

  @override
  State<FileDropzone> createState() => _FileDropzoneState();
}

class _FileDropzoneState extends State<FileDropzone> {
  bool _isHovering = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: widget.allowedExtensions != null
          ? FileType.custom
          : FileType.any,
      allowedExtensions: widget.allowedExtensions,
    );

    if (result != null && result.files.isNotEmpty) {
      widget.onFilesDropped?.call(result.files);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _pickFiles,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: _isHovering
                ? context.colors.accentBlue
                : context.colors.borderSubtle,
            radius: 14,
            strokeWidth: 2,
            dashLength: 8,
            gapLength: 5,
          ),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _isHovering
                  ? context.colors.accentBlueSubtle
                  : context.colors.bgInput,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.upload,
                  size: 24,
                  color: _isHovering
                      ? context.colors.accentBlue
                      : context.colors.textTertiary,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.actionText,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.accentBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter que dibuja un borde punteado (dashed) con esquinas
/// redondeadas, simulando la propiedad CSS `border-style: dashed`.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);

    final dashPath = _createDashedPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source) {
    final dashedPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0, metric.length);
        dashedPath.addPath(
          metric.extractPath(distance, end.toDouble()),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
