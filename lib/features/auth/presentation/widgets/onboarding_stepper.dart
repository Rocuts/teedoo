import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';

/// Stepper horizontal para el flujo de onboarding.
///
/// Ref Pencil: Auth - Onboarding (Z7HXm) — stepper row.
/// - Cada paso: círculo numerado (28x28, radius 14) + label (13px)
/// - Activo: fill accent-blue, text white, label accent-blue w500
/// - Completado: fill status-success, check icon white, label text-primary
/// - Pendiente: border border-subtle, text text-tertiary, label text-tertiary
/// - Líneas: h 2px, w 60px, completado accent-blue, pendiente border-subtle
class OnboardingStepper extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const OnboardingStepper({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(steps.length * 2 - 1, (index) {
        // Even indices are step circles, odd are connector lines
        if (index.isEven) {
          final stepIndex = index ~/ 2;
          return _StepIndicator(
            label: steps[stepIndex],
            stepNumber: stepIndex + 1,
            isActive: stepIndex == currentStep,
            isCompleted: stepIndex < currentStep,
          );
        } else {
          final beforeStep = index ~/ 2;
          final isCompleted = beforeStep < currentStep;
          return Container(
            width: 60,
            height: 2,
            margin: const EdgeInsets.only(bottom: 20),
            color: isCompleted
                ? context.colors.accentBlue
                : context.colors.borderSubtle,
          );
        }
      }),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final String label;
  final int stepNumber;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.label,
    required this.stepNumber,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circle
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _circleColor(context),
            shape: BoxShape.circle,
            border: _isPending
                ? Border.all(color: context.colors.borderSubtle, width: 1.5)
                : null,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(
                  LucideIcons.check,
                  size: 14,
                  color: Colors.white,
                )
              : Text(
                  '$stepNumber',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _isPending
                        ? context.colors.textTertiary
                        : Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 8),

        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            color: _labelColor(context),
          ),
        ),
      ],
    );
  }

  bool get _isPending => !isActive && !isCompleted;

  Color _circleColor(BuildContext context) {
    if (isCompleted) return context.colors.statusSuccess;
    if (isActive) return context.colors.accentBlue;
    return Colors.transparent;
  }

  Color _labelColor(BuildContext context) {
    if (isCompleted) return context.colors.textPrimary;
    if (isActive) return context.colors.accentBlue;
    return context.colors.textTertiary;
  }
}
