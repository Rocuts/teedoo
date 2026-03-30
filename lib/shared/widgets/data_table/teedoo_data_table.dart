import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../empty_state.dart';

/// Definición de columna para [TeeDooDataTable].
class TableColumn<T> {
  final String header;
  final double? width;
  final Widget Function(T item) cellBuilder;
  final int Function(T a, T b)? comparator;

  const TableColumn({
    required this.header,
    this.width,
    required this.cellBuilder,
    this.comparator,
  });
}

/// Tabla de datos genérica del Design System.
///
/// - Header row: bg-surface, padding 10/16, text 11px/600 text-tertiary
/// - Data rows: padding 12/16, border-bottom border-subtle
/// - Checkbox column: 40px width
/// - Hover effect on rows: bg-glass-hover
/// - Empty state when no rows
class TeeDooDataTable<T> extends StatefulWidget {
  final List<TableColumn<T>> columns;
  final List<T> rows;
  final bool showCheckbox;
  final Set<int> selectedRows;
  final ValueChanged<Set<int>>? onSelectionChanged;
  final String? emptyMessage;

  const TeeDooDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckbox = false,
    this.selectedRows = const {},
    this.onSelectionChanged,
    this.emptyMessage,
  });

  @override
  State<TeeDooDataTable<T>> createState() => _TeeDooDataTableState<T>();
}

class _TeeDooDataTableState<T> extends State<TeeDooDataTable<T>> {
  int? _hoveredRow;

  void _toggleRow(int index) {
    final newSelection = Set<int>.from(widget.selectedRows);
    if (newSelection.contains(index)) {
      newSelection.remove(index);
    } else {
      newSelection.add(index);
    }
    widget.onSelectionChanged?.call(newSelection);
  }

  void _toggleAll() {
    if (widget.selectedRows.length == widget.rows.length) {
      widget.onSelectionChanged?.call({});
    } else {
      widget.onSelectionChanged?.call(
        Set<int>.from(List.generate(widget.rows.length, (i) => i)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s48),
        child: EmptyState(title: widget.emptyMessage ?? 'No hay datos'),
      );
    }

    return Column(
      children: [
        // ── Header row ──
        Container(
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            border: Border(
              bottom: BorderSide(color: context.colors.borderSubtle),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              if (widget.showCheckbox) ...[
                SizedBox(
                  width: 40,
                  child: Checkbox(
                    value:
                        widget.selectedRows.length == widget.rows.length &&
                        widget.rows.isNotEmpty,
                    tristate:
                        widget.selectedRows.isNotEmpty &&
                        widget.selectedRows.length < widget.rows.length,
                    onChanged: (_) => _toggleAll(),
                    side: BorderSide(color: context.colors.borderSubtle),
                    activeColor: context.colors.accentBlue,
                    checkColor: context.colors.textOnAccent,
                  ),
                ),
              ],
              ...widget.columns.map(_buildHeaderCell),
            ],
          ),
        ),

        // ── Data rows ──
        ...List.generate(widget.rows.length, (index) {
          final item = widget.rows[index];
          final isSelected = widget.selectedRows.contains(index);
          final isHovered = _hoveredRow == index;

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredRow = index),
            onExit: (_) => setState(() => _hoveredRow = null),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.accentBlueSubtle
                    : isHovered
                    ? context.colors.bgGlassHover
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(color: context.colors.borderSubtle),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.xl,
              ),
              child: Row(
                children: [
                  if (widget.showCheckbox) ...[
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleRow(index),
                        side: BorderSide(color: context.colors.borderSubtle),
                        activeColor: context.colors.accentBlue,
                        checkColor: context.colors.textOnAccent,
                      ),
                    ),
                  ],
                  ...widget.columns.map((col) => _buildDataCell(col, item)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHeaderCell(TableColumn<T> column) {
    final child = Text(
      column.header,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: context.colors.textTertiary,
      ),
    );

    if (column.width != null) {
      return SizedBox(width: column.width, child: child);
    }
    return Expanded(child: child);
  }

  Widget _buildDataCell(TableColumn<T> column, T item) {
    final child = column.cellBuilder(item);

    if (column.width != null) {
      return SizedBox(width: column.width, child: child);
    }
    return Expanded(child: child);
  }
}
