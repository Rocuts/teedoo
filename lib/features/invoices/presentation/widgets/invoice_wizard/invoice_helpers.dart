import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors_theme.dart';
import '../../../../../core/theme/app_radius.dart';

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
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: context.colors.textSecondary,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.bgInput,
          borderRadius: AppRadius.inputAll,
          border: Border.all(color: context.colors.borderSubtle),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: TextStyle(
            fontSize: 13,
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
        style: TextStyle(
          color: isBold ? context.colors.textPrimary : context.colors.textSecondary,
          fontSize: isBold ? 15 : 13,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: valueColor ?? context.colors.textPrimary,
          fontSize: isBold ? 18 : 14,
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
      style: TextStyle(
        fontSize: 13,
        color: context.colors.textPrimary,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        prefixText: prefix,
        prefixStyle: TextStyle(
          fontSize: 13,
          color: context.colors.textTertiary,
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          fontSize: 13,
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
