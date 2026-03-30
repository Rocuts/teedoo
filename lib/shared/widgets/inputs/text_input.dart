import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_radius.dart';

/// Input de texto del Design System.
///
/// Ref Pencil: Component/InputField (68wos)
/// - Width: fill
/// - Gap: 6 (label → input)
/// - Label: 13px/500, text-secondary
/// - Input: height 40, radius 10, fill bg-input, stroke 1px border-subtle
/// - Placeholder: 14px/400, text-tertiary
class TeeDooTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const TeeDooTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
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
          height: maxLines > 1 ? null : 44,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            maxLines: maxLines,
            style: TextStyle(fontSize: 13, color: context.colors.textPrimary),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 13,
                color: context.colors.textTertiary,
              ),
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
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: BorderSide(color: context.colors.statusError),
              ),
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}
