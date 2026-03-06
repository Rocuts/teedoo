import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors_theme.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/glass_theme.dart';

/// GlassModal — Modal con glassmorphism.
///
/// - Overlay: bg-modal color
/// - Modal card: blur 40, bg-card fill, glass-border stroke, radius 16
/// - Header: title (18px/600) + optional close button (x icon)
/// - Content slot
/// - Actions row (optional)
/// - Show via static method: `GlassModal.show(context, builder: ...)`
class GlassModal extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final bool showClose;
  final double maxWidth;

  const GlassModal({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.showClose = true,
    this.maxWidth = 480,
  });

  /// Muestra el modal como overlay.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'GlassModal',
      barrierColor: context.colors.bgModal,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return builder(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            child: ClipRRect(
              borderRadius: AppRadius.cardAll,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: glass.blurSigma,
                  sigmaY: glass.blurSigma,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: glass.cardFill,
                    borderRadius: AppRadius.cardAll,
                    border: Border.all(
                      color: glass.glassBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header ──
                      if (title != null || showClose)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.cardPadding,
                            AppSpacing.s20,
                            AppSpacing.s16,
                            0,
                          ),
                          child: Row(
                            children: [
                              if (title != null)
                                Expanded(
                                  child: Text(
                                    title!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                ),
                              if (showClose)
                                Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                    hoverColor: context.colors.bgGlassHover,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        LucideIcons.x,
                                        size: 18,
                                        color: context.colors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // ── Content ──
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.cardPadding,
                          title != null ? AppSpacing.s16 : AppSpacing.cardPadding,
                          AppSpacing.cardPadding,
                          actions != null ? AppSpacing.s16 : AppSpacing.cardPadding,
                        ),
                        child: content,
                      ),

                      // ── Actions ──
                      if (actions != null && actions!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.cardPadding,
                            0,
                            AppSpacing.cardPadding,
                            AppSpacing.s20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              for (int i = 0; i < actions!.length; i++) ...[
                                if (i > 0)
                                  const SizedBox(width: AppSpacing.buttonGap),
                                actions![i],
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
