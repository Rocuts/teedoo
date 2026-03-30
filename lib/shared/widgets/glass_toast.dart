import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors_theme.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'badges/status_badge.dart';

/// GlassToast — Toast notification con glassmorphism.
///
/// - Positioned at top-right
/// - Glass background (blur 20, bg-glass, glass-border)
/// - Icon + message + optional close
/// - Types: success, warning, error, info (use StatusType)
/// - Auto-dismiss after 4 seconds
/// - Show via static method: `GlassToast.show(context, message: ..., type: ...)`
class GlassToast extends StatefulWidget {
  final String message;
  final StatusType type;
  final VoidCallback? onClose;
  final Duration duration;

  const GlassToast({
    super.key,
    required this.message,
    required this.type,
    this.onClose,
    this.duration = const Duration(seconds: 4),
  });

  /// Muestra un toast en la esquina superior derecha.
  static void show(
    BuildContext context, {
    required String message,
    StatusType type = StatusType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }

  @override
  State<GlassToast> createState() => _GlassToastState();
}

class _GlassToastState extends State<GlassToast> {
  @override
  Widget build(BuildContext context) {
    return _ToastCard(
      message: widget.message,
      type: widget.type,
      onClose: widget.onClose,
    );
  }
}

/// Wrapper posicionado que maneja la animación y auto-dismiss.
class _ToastOverlay extends StatefulWidget {
  final String message;
  final StatusType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    _dismissTimer?.cancel();
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppSpacing.s24,
      right: AppSpacing.s24,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _ToastCard(
            message: widget.message,
            type: widget.type,
            onClose: _dismiss,
          ),
        ),
      ),
    );
  }
}

/// El contenido visual del toast.
class _ToastCard extends StatelessWidget {
  final String message;
  final StatusType type;
  final VoidCallback? onClose;

  const _ToastCard({required this.message, required this.type, this.onClose});

  IconData get _icon => switch (type) {
    StatusType.success => LucideIcons.checkCircle,
    StatusType.warning => LucideIcons.alertTriangle,
    StatusType.error => LucideIcons.xCircle,
    StatusType.info => LucideIcons.info,
  };

  @override
  Widget build(BuildContext context) {
    final Color statusColor = switch (type) {
      StatusType.success => context.colors.statusSuccess,
      StatusType.warning => context.colors.statusWarning,
      StatusType.error => context.colors.statusError,
      StatusType.info => context.colors.statusInfo,
    };

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360, minWidth: 240),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: context.colors.bgGlass,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: context.colors.bgGlassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon, size: 18, color: statusColor),
                const SizedBox(width: AppSpacing.xl),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                if (onClose != null) ...[
                  const SizedBox(width: AppSpacing.xl),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onClose,
                      child: Icon(
                        LucideIcons.x,
                        size: 14,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
