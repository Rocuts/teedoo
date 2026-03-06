import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/services/ai_voice_service.dart';

class OrbitVisualizer extends StatefulWidget {
  final AiVoiceState state;
  final double size;

  const OrbitVisualizer({
    super.key,
    required this.state,
    this.size = 64.0,
  });

  @override
  State<OrbitVisualizer> createState() => _OrbitVisualizerState();
}

class _OrbitVisualizerState extends State<OrbitVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _OrbitPainter(
            colors: context.colors,
            state: widget.state,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final AppColorsTheme colors;
  final AiVoiceState state;
  final double animationValue;

  _OrbitPainter({
    required this.colors,
    required this.state,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    _drawCore(canvas, center, radius);

    switch (state) {
      case AiVoiceState.idle:
        _drawIdleAura(canvas, center, radius);
      case AiVoiceState.connecting:
        _drawConnectingPulse(canvas, center, radius);
      case AiVoiceState.listening:
        _drawListeningWaves(canvas, center, radius);
      case AiVoiceState.processing:
        _drawProcessingSwirls(canvas, center, radius);
      case AiVoiceState.speaking:
        _drawSpeakingSpikes(canvas, center, radius);
      case AiVoiceState.error:
        _drawErrorGlow(canvas, center, radius);
    }
  }

  void _drawCore(Canvas canvas, Offset center, double radius) {
    final Color coreColor;
    switch (state) {
      case AiVoiceState.idle:
        coreColor = colors.textSecondary;
      case AiVoiceState.error:
        coreColor = colors.statusError;
      default:
        coreColor = colors.aiPurple;
    }

    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          coreColor,
          colors.bgSurface.withValues(alpha: 0.8),
        ],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.8));

    // Slight breathing effect on core
    final scale = 1.0 + 0.05 * sin(animationValue * 2 * pi);
    canvas.drawCircle(center, radius * 0.6 * scale, corePaint);
  }

  void _drawIdleAura(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = colors.textTertiary.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius * 0.8, paint);
  }

  void _drawConnectingPulse(Canvas canvas, Offset center, double radius) {
    // Pulsing ring that grows and shrinks
    final pulseProgress = (sin(animationValue * 2 * pi) + 1) / 2; // 0..1
    final ringRadius = radius * (0.7 + 0.3 * pulseProgress);
    final opacity = 0.3 + 0.4 * pulseProgress;

    final paint = Paint()
      ..color = colors.aiPurple.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, ringRadius, paint);

    // Second ring offset in phase
    final pulse2 = (sin(animationValue * 2 * pi + pi) + 1) / 2;
    final ring2Radius = radius * (0.7 + 0.3 * pulse2);
    final opacity2 = 0.2 + 0.3 * pulse2;

    final paint2 = Paint()
      ..color = colors.aiPurple.withValues(alpha: opacity2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, ring2Radius, paint2);
  }

  void _drawListeningWaves(Canvas canvas, Offset center, double radius) {
    // Expanding rings
    for (int i = 0; i < 3; i++) {
      final progress = (animationValue + i / 3.0) % 1.0;
      final waveRadius = radius * 0.6 + (radius * 0.4 * progress);
      final opacity = 1.0 - progress;

      final paint = Paint()
        ..color = colors.accentBlue.withValues(alpha: opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, waveRadius, paint);
    }
  }

  void _drawProcessingSwirls(Canvas canvas, Offset center, double radius) {
    // Rotating arc
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          colors.aiPurple,
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(animationValue * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      0,
      2 * pi,
      false,
      paint,
    );
  }

  void _drawSpeakingSpikes(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = colors.aiPurple.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Simulate audio frequencies
    final path = Path();
    const numSpikes = 32;
    for (int i = 0; i < numSpikes; i++) {
      final angle = (i * 2 * pi) / numSpikes;
      // Fast jittery movement for speaking
      final noise = sin(angle * 10 + animationValue * 40) * cos(angle * 5 - animationValue * 20);
      final spikeLength = radius * 0.6 + (radius * 0.4 * noise.abs());

      final px = center.dx + cos(angle) * spikeLength;
      final py = center.dy + sin(angle) * spikeLength;

      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawErrorGlow(Canvas canvas, Offset center, double radius) {
    // Static red glow ring
    final paint = Paint()
      ..color = colors.statusError.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius * 0.8, paint);

    // Subtle outer glow
    final glowPaint = Paint()
      ..color = colors.statusError.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, radius * 0.85, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.state != state;
  }
}
