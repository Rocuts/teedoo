import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_radius.dart';

/// Input de búsqueda del Design System.
///
/// Ref Pencil: Invoices List — search with icon left, optional filter button.
/// - Height: 40px
/// - Radius: 10px
/// - Fill: bg-input
/// - Stroke: 1px border-subtle
/// - Search icon left, placeholder text, optional filter button right
class SearchInput extends StatelessWidget {
  final String placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool showFilter;

  const SearchInput({
    super.key,
    this.placeholder = 'Buscar...',
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.showFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
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
                  vertical: 10,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(
                    LucideIcons.search,
                    size: 16,
                    color: context.colors.textTertiary,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 40,
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
          if (showFilter) ...[
            const SizedBox(width: 8),
            Material(
              color: context.colors.bgGlass,
              borderRadius: AppRadius.inputAll,
              child: InkWell(
                onTap: onFilterTap,
                borderRadius: AppRadius.inputAll,
                hoverColor: context.colors.bgGlassHover,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.inputAll,
                    border: Border.all(color: context.colors.borderSubtle),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    LucideIcons.slidersHorizontal,
                    size: 16,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
