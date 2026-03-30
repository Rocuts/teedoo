import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_radius.dart';

class DropzoneArea extends StatefulWidget {
  final VoidCallback onUploadTap;
  final String title;
  final String subtitle;

  const DropzoneArea({
    super.key,
    required this.onUploadTap,
    this.title = 'Haz clic para explorar o arrastra un archivo aquí',
    this.subtitle = 'Soporta PDF, XML, JPG, PNG (hasta 20MB)',
  });

  @override
  State<DropzoneArea> createState() => _DropzoneAreaState();
}

class _DropzoneAreaState extends State<DropzoneArea> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onUploadTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: _isHovered
                ? context.colors.accentBlue.withValues(alpha: 0.05)
                : context.colors.bgInput.withValues(alpha: 0.5),
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: _isHovered
                  ? context.colors.accentBlue
                  : context.colors.borderSubtle,
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? context.colors.accentBlue.withValues(alpha: 0.1)
                      : context.colors.bgSurface,
                  shape: BoxShape.circle,
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: context.colors.accentBlue.withValues(
                              alpha: 0.2,
                            ),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  LucideIcons.uploadCloud,
                  size: 32,
                  color: _isHovered
                      ? context.colors.accentBlue
                      : context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Text
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isHovered
                      ? context.colors.accentBlue
                      : context.colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.textTertiary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
