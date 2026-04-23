import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/models/fiscal_rule.dart';

/// Gráfico interactivo de ahorro por impuesto.
///
/// Interacción bidireccional: tocar barra o botón selecciona el impuesto.
/// Callback onTaxSelected notifica el filtro activo.
class TaxBreakdownChart extends StatefulWidget {
  final Map<TaxType, double> savingsByTax;
  final TaxType? selectedTax;
  final ValueChanged<TaxType?> onTaxSelected;

  const TaxBreakdownChart({
    super.key,
    required this.savingsByTax,
    required this.selectedTax,
    required this.onTaxSelected,
  });

  @override
  State<TaxBreakdownChart> createState() => _TaxBreakdownChartState();
}

class _TaxBreakdownChartState extends State<TaxBreakdownChart> {
  int? _touchedBarIndex;

  static const _taxOrder = [TaxType.irpf, TaxType.iva, TaxType.sociedades];

  List<_TaxEntry> get _entries =>
      _taxOrder.map((t) => _TaxEntry(t, widget.savingsByTax[t] ?? 0)).toList();

  int? get _selectedIndex {
    if (widget.selectedTax == null) return null;
    final idx = _taxOrder.indexOf(widget.selectedTax!);
    return idx >= 0 ? idx : null;
  }

  void _selectIndex(int? index) {
    if (index == null) {
      widget.onTaxSelected(null);
    } else if (index >= 0 && index < _taxOrder.length) {
      final tax = _taxOrder[index];
      widget.onTaxSelected(widget.selectedTax == tax ? null : tax);
    }
  }

  Color _taxColor(int index, AppColorsTheme colors) {
    return switch (index) {
      0 => colors.statusSuccess,
      1 => colors.accentBlue,
      _ => colors.statusWarning,
    };
  }

  String _taxLabel(int index) {
    return switch (index) {
      0 => 'IRPF',
      1 => 'IVA',
      _ => 'IS',
    };
  }

  IconData _taxIcon(int index) {
    return switch (index) {
      0 => LucideIcons.receipt,
      1 => LucideIcons.percent,
      _ => LucideIcons.building,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final entries = _entries;
    final maxVal = entries.fold(0.0, (m, e) => e.amount > m ? e.amount : m);

    return GlassCard(
      header: GlassCardHeader(
        title: 'Ahorro por Impuesto',
        subtitle: 'Distribución del ahorro estimado',
        trailing: widget.selectedTax != null
            ? InkWell(
                onTap: () => widget.onTaxSelected(null),
                borderRadius: AppRadius.mdAll,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.x, size: 14, color: colors.textTertiary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Limpiar filtro',
                        style: AppTypography.caption.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.xl,
          AppSpacing.s24,
          AppSpacing.s20,
        ),
        child: Column(
          children: [
            // ── Tax selector buttons ──
            Row(
              children: [
                for (int i = 0; i < entries.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _TaxButton(
                      label: _taxLabel(i),
                      icon: _taxIcon(i),
                      amount: entries[i].amount,
                      isActive: _selectedIndex == i,
                      color: _taxColor(i, colors),
                      onTap: () => _selectIndex(i),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.s20),

            // ── Bar chart ──
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal > 0 ? maxVal * 1.2 : 100,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: false,
                    touchCallback:
                        (FlTouchEvent event, BarTouchResponse? response) {
                          if (response != null &&
                              response.spot != null &&
                              event is FlTapUpEvent) {
                            _selectIndex(response.spot!.touchedBarGroupIndex);
                          }
                          setState(() {
                            if (response != null &&
                                response.spot != null &&
                                event is! FlTapUpEvent &&
                                event is! FlPanEndEvent &&
                                event is! FlLongPressEnd) {
                              _touchedBarIndex =
                                  response.spot!.touchedBarGroupIndex;
                            } else {
                              _touchedBarIndex = null;
                            }
                          });
                        },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          colors.bgSurface.withValues(alpha: 0.95),
                      tooltipBorderRadius: BorderRadius.circular(8),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final entry = entries[group.x];
                        final count = entry.amount > 0 ? 1 : 0;
                        return BarTooltipItem(
                          '${_taxLabel(group.x)}\n',
                          AppTypography.captionSmallBold.copyWith(
                            color: _taxColor(group.x, colors),
                          ),
                          children: [
                            TextSpan(
                              text: '${_formatCurrency(entry.amount)}\n',
                              style: AppTypography.bodySmallMedium.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: '$count optimizaciones',
                              style: AppTypography.captionSmall.copyWith(
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: maxVal > 0 ? (maxVal / 3).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            _formatShort(value),
                            style: AppTypography.captionSmall.copyWith(
                              color: colors.textTertiary,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          final isSelected = _selectedIndex == idx;
                          final isTouched = _touchedBarIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _taxLabel(idx),
                                  style: AppTypography.captionSmallBold
                                      .copyWith(
                                        color: isSelected || isTouched
                                            ? _taxColor(idx, colors)
                                            : colors.textTertiary,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: isSelected ? 6 : 0,
                                  height: isSelected ? 6 : 0,
                                  decoration: BoxDecoration(
                                    color: _taxColor(idx, colors),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxVal > 0
                        ? (maxVal / 3).ceilToDouble()
                        : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colors.borderSubtle,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (int i = 0; i < entries.length; i++)
                      BarChartGroupData(
                        x: i,
                        showingTooltipIndicators: _touchedBarIndex == i
                            ? [0]
                            : [],
                        barRods: [
                          BarChartRodData(
                            toY: entries[i].amount,
                            width: _selectedIndex == i
                                ? 56
                                : (_touchedBarIndex == i ? 48 : 40),
                            borderRadius: AppRadius.smAll,
                            color: _barColor(i, colors),
                            borderSide: _selectedIndex == i
                                ? BorderSide(
                                    color: _taxColor(i, colors),
                                    width: 2,
                                  )
                                : BorderSide.none,
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxVal > 0 ? maxVal * 1.2 : 100,
                              color: _selectedIndex == i
                                  ? _taxColor(i, colors).withValues(alpha: 0.04)
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _barColor(int index, AppColorsTheme colors) {
    final base = _taxColor(index, colors);
    if (_selectedIndex == index) return base;
    if (_touchedBarIndex == index) return base.withValues(alpha: 0.6);
    return base.withValues(alpha: 0.2);
  }

  static String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
      buffer.write(intPart[i]);
    }
    return '$buffer,$decPart \u20ac';
  }

  static String _formatShort(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k \u20ac';
    }
    return '${value.toStringAsFixed(0)} \u20ac';
  }
}

class _TaxEntry {
  final TaxType type;
  final double amount;
  const _TaxEntry(this.type, this.amount);
}

String _formatCurrencyGlobal(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  final intPart = parts[0];
  final decPart = parts[1];
  final buffer = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
    buffer.write(intPart[i]);
  }
  return '$buffer,$decPart \u20ac';
}

class _TaxButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final double amount;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _TaxButton({
    required this.label,
    required this.icon,
    required this.amount,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: isActive ? color : colors.borderSubtle,
            width: isActive ? 2 : 1,
          ),
          color: isActive ? color.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isActive ? color : color.withValues(alpha: 0.6),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: AppTypography.captionSmallBold.copyWith(
                    color: isActive ? color : colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatCurrencyGlobal(amount),
              style: (isActive ? AppTypography.h3 : AppTypography.h4).copyWith(
                color: isActive ? colors.textPrimary : colors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
