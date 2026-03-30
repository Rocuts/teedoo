import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/services/ai_voice_service.dart';
import '../../../app.dart';
import 'orbit_visualizer.dart';

class AiOrbitWidget extends ConsumerWidget {
  const AiOrbitWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(aiVoiceProvider);
    final state = service.state;
    final transcript = service.lastTranscript;
    final errorMsg = service.errorMessage;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Invisible WebRTC Audio Renderer for browser playback
        SizedBox(
          width: 1,
          height: 1,
          child: RTCVideoView(service.audioRenderer),
        ),

        // Floating Data Card (speaking with transcript, or error)
        if (state == AiVoiceState.speaking && transcript != null)
          Positioned(
            bottom: 80,
            right: 0,
            child: _buildDataCard(context, transcript)
                .animate()
                .fadeIn(duration: AppMotion.durationNormal)
                .slideY(begin: 0.1, duration: AppMotion.durationNormal),
          ),

        if (state == AiVoiceState.error && errorMsg != null)
          Positioned(
            bottom: 80,
            right: 0,
            child: _buildErrorCard(context, errorMsg)
                .animate()
                .fadeIn(duration: AppMotion.durationNormal)
                .slideY(begin: 0.1, duration: AppMotion.durationNormal),
          ),

        // AI Orb Button
        GestureDetector(
          onTap: service.toggleListening,
          child: AnimatedContainer(
            duration: AppMotion.durationNormal,
            width: _orbSize(state),
            height: _orbSize(state),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.bgSurface,
              boxShadow: [
                BoxShadow(
                  color: _orbGlowColor(context, state),
                  blurRadius: state == AiVoiceState.idle ? 10 : 20,
                  spreadRadius: state == AiVoiceState.idle ? 0 : 10,
                ),
              ],
            ),
            child: Center(
              child: OrbitVisualizer(
                state: state,
                size: state == AiVoiceState.idle
                    ? AppDimensions.aiOrbVisualizerIdle
                    : AppDimensions.aiOrbVisualizerActive,
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _orbSize(AiVoiceState state) {
    return state == AiVoiceState.idle
        ? AppDimensions.aiOrbIdle
        : AppDimensions.aiOrbActive;
  }

  Color _orbGlowColor(BuildContext context, AiVoiceState state) {
    switch (state) {
      case AiVoiceState.idle:
        return context.colors.textTertiary.withValues(alpha: 0.1);
      case AiVoiceState.error:
        return context.colors.statusError.withValues(alpha: 0.3);
      default:
        return context.colors.aiPurple.withValues(alpha: 0.3);
    }
  }

  Widget _buildDataCard(BuildContext context, String data) {
    return Container(
      width: AppDimensions.aiCardWidth,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: context.colors.aiPurpleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.insights, size: 16, color: context.colors.aiPurple),
              const SizedBox(width: 8),
              Text(
                'Insights de TeDoo',
                style: TextStyle(
                  color: context.colors.aiPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Container(
      width: AppDimensions.aiCardWidth,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: AppRadius.xlAll,
        border: Border.all(
          color: context.colors.statusError.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: context.colors.statusError,
              ),
              const SizedBox(width: 8),
              Text(
                'Error de conexión',
                style: TextStyle(
                  color: context.colors.statusError,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el orb para reintentar',
            style: TextStyle(color: context.colors.textTertiary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
