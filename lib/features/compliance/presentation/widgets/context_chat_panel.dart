import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_toast.dart';
import '../../../../shared/widgets/badges/status_badge.dart';

/// Panel lateral de chat con IA contextual a los resultados de compliance.
///
/// Ref Pencil: Results + Chat — Right panel (360px).
class ContextChatPanel extends StatefulWidget {
  const ContextChatPanel({super.key});

  @override
  State<ContextChatPanel> createState() => _ContextChatPanelState();
}

class _ContextChatPanelState extends State<ContextChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderSide = BorderSide(color: context.colors.borderSubtle);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        border: context.isExpanded
            ? Border(left: borderSide)
            : Border(top: borderSide),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          // Messages
          Expanded(child: _buildMessages()),
          // Input
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.borderSubtle)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.sparkles, size: 18, color: context.colors.aiPurple),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Asistente IA',
            style: AppTypography.h4.copyWith(color: context.colors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI message 1
          _buildAiMessage(
            'He encontrado 5 hallazgos en la INV-2026-092. Los 2 de prioridad '
            'alta necesitan correcci\u00f3n antes del env\u00edo. Los errores en '
            'NIF afectan la validaci\u00f3n del SII.',
          ),
          const SizedBox(height: AppSpacing.lg),

          // Quick actions
          _buildQuickActions(),
          const SizedBox(height: AppSpacing.xl),

          // User message
          _buildUserMessage('Explica el fallo del NIF con m\u00e1s detalle'),
          const SizedBox(height: AppSpacing.xl),

          // AI response
          _buildAiMessage(
            'El campo ReceptorTaxId contiene el valor "B1234567" que no '
            'cumple el formato NIF espa\u00f1ol. El formato v\u00e1lido es: '
            '8 d\u00edgitos + 1 letra de control (ej: 12345678Z). Para CIF '
            'de empresas, debe comenzar con una letra (A-H, J, N, P-S, U, W) '
            'seguida de 7 d\u00edgitos y un d\u00edgito/letra de control.',
          ),
          const SizedBox(height: AppSpacing.sm),

          // Citation card
          _buildCitationCard(),
        ],
      ),
    );
  }

  Widget _buildAiMessage(String text) {
    final glass = context.glass;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: glass.cardFill,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: glass.glassBorder),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: context.colors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.colors.accentBlueSubtle,
          borderRadius: AppRadius.lgAll,
        ),
        child: Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    const actions = [
      'Explicar fallo',
      'C\u00f3mo corregir',
      'Generar checklist',
      'Preparar para env\u00edo',
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: actions.map((label) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              GlassToast.show(
                context,
                message: 'Analizando contexto...',
                type: StatusType.info,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: context.colors.bgGlass,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: context.colors.borderSubtle),
              ),
              child: Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCitationCard() {
    final glass = context.glass;
    return Container(
      margin: const EdgeInsets.only(left: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: glass.cardFill,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: glass.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.fileText,
            size: 12,
            color: context.colors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Campo: TaxId \u00b7 L\u00ednea 42',
            style: AppTypography.captionSmall.copyWith(
              color: context.colors.textTertiary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _controller,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: context.colors.textTertiary,
                  ),
                  filled: true,
                  fillColor: context.colors.bgInput,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.inputAll,
                    borderSide: BorderSide(color: context.colors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.inputAll,
                    borderSide: BorderSide(color: context.colors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.inputAll,
                    borderSide: BorderSide(color: context.colors.accentBlue),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Send button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _controller.clear,
              child: Container(
                width: AppSpacing.s36,
                height: AppSpacing.s36,
                decoration: BoxDecoration(
                  color: context.colors.accentBlue,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.send,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
