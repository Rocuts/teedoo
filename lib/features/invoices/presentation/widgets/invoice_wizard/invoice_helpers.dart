import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Shared helper widgets and functions for the invoice wizard.

String formatCurrency(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  final intPart = parts[0];
  final decPart = parts[1];

  final buffer = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(intPart[i]);
  }

  return '\u20ac$buffer,$decPart';
}

double parseNumber(String value) {
  final cleaned = value.replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(cleaned) ?? 0;
}

Widget buildReadOnlyField(BuildContext context, String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: AppTypography.captionMedium.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Container(
        width: double.infinity,
        height: 44,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: context.colors.bgInput,
          borderRadius: AppRadius.inputAll,
          border: Border.all(color: context.colors.borderSubtle),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textTertiary,
          ),
        ),
      ),
    ],
  );
}

Widget buildTotalRow(
  BuildContext context,
  String label,
  String value, {
  bool isBold = false,
  Color? valueColor,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: (isBold ? AppTypography.h4 : AppTypography.bodySmall).copyWith(
          color: isBold
              ? context.colors.textPrimary
              : context.colors.textSecondary,
        ),
      ),
      Text(
        value,
        style: (isBold ? AppTypography.logo : AppTypography.bodyMedium)
            .copyWith(
              color: valueColor ?? context.colors.textPrimary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
      ),
    ],
  );
}

Widget buildCompactInput(
  BuildContext context, {
  required String value,
  required TextEditingController controller,
  String? prefix,
  String? suffix,
  ValueChanged<String>? onChanged,
}) {
  return SizedBox(
    height: 38,
    child: TextFormField(
      controller: controller,
      onChanged: onChanged,
      style: AppTypography.bodySmall.copyWith(
        color: context.colors.textPrimary,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        prefixText: prefix,
        prefixStyle: AppTypography.bodySmall.copyWith(
          color: context.colors.textTertiary,
        ),
        suffixText: suffix,
        suffixStyle: AppTypography.bodySmall.copyWith(
          color: context.colors.textTertiary,
        ),
        filled: true,
        fillColor: context.colors.bgInput,
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
  );
}
