import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_radius.dart';

/// Item individual del stepper.
class StepItem {
  final String label;

  const StepItem({required this.label});
}

/// Stepper horizontal del Design System.
///
/// Ref Pencil: Onboarding (Z7HXm), Invoice Wizard (DBnBX)
/// - Numbered circles: 28x28, radius 14
/// - States: completed (fill status-success, check icon),
///           active (fill accent-blue, number),
///           pending (outline border-subtle, number)
/// - Lines between steps: completed=accent-blue, pending=border-subtle, 2px h
/// - Labels below: 13px, active=500+accent-blue, pending=normal+text-tertiary
class TeeDooStepper extends StatelessWidget {
  final List<StepItem> steps;
  final int currentStep;

  const TeeDooStepper({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _StepCircle(
            index: i,
            label: steps[i].label,
            state: _stepState(i),
          ),
          if (i < steps.length - 1)
            _StepLine(
              isCompleted: i < currentStep,
            ),
        ],
      ],
    );
  }

  _StepState _stepState(int index) {
    if (index < currentStep) return _StepState.completed;
    if (index == currentStep) return _StepState.active;
    return _StepState.pending;
  }
}

enum _StepState { completed, active, pending }

class _StepCircle extends StatelessWidget {
  final int index;
  final String label;
  final _StepState state;

  const _StepCircle({
    required this.index,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final Color fillColor = switch (state) {
      _StepState.completed => context.colors.statusSuccess,
      _StepState.active => context.colors.accentBlue,
      _StepState.pending => Colors.transparent,
    };

    final Color labelColor = switch (state) {
      _StepState.completed => context.colors.textSecondary,
      _StepState.active => context.colors.accentBlue,
      _StepState.pending => context.colors.textTertiary,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppRadius.stepperCircle),
            border: state == _StepState.pending
                ? Border.all(color: context.colors.borderSubtle, width: 1.5)
                : null,
          ),
          alignment: Alignment.center,
          child: _buildCircleContent(context),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: state == _StepState.active
                ? FontWeight.w500
                : FontWeight.w400,
            color: labelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCircleContent(BuildContext context) {
    if (state == _StepState.completed) {
      return Icon(
        LucideIcons.check,
        size: 14,
        color: context.colors.textOnAccent,
      );
    }

    return Text(
      '${index + 1}',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: state == _StepState.active
            ? context.colors.textOnAccent
            : context.colors.textTertiary,
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isCompleted;

  const _StepLine({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        width: 48,
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isCompleted
              ? context.colors.accentBlue
              : context.colors.borderSubtle,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
