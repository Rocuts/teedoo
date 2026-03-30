import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_radius.dart';

/// Opción individual para [TeeDooSelect].
class SelectOption {
  final String value;
  final String label;

  const SelectOption({required this.value, required this.label});
}

/// Dropdown select del Design System.
///
/// Ref Pencil: Onboarding screen — dropdown with label.
/// - Fill: bg-input
/// - Stroke: 1px border-subtle
/// - Radius: 10px
/// - Chevron-down icon
/// - Label: 12px/500 text-secondary (matches TeeDooTextField)
class TeeDooSelect extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final String? value;
  final List<SelectOption> options;
  final ValueChanged<String?>? onChanged;

  const TeeDooSelect({
    super.key,
    this.label,
    this.placeholder,
    this.value,
    this.options = const [],
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: 44,
          child: DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: value,
            onChanged: onChanged,
            icon: Icon(
              LucideIcons.chevronDown,
              size: 16,
              color: context.colors.textTertiary,
            ),
            dropdownColor: context.colors.bgSecondary,
            style: TextStyle(fontSize: 13, color: context.colors.textPrimary),
            hint: placeholder != null
                ? Text(
                    placeholder!,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textTertiary,
                    ),
                  )
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: context.colors.bgInput,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
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
            items: options
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option.value,
                    child: Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
