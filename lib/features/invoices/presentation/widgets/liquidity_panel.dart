import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/models/invoice_model.dart';

/// Panel de previsión de liquidez a 15, 30 y 45 días.
///
/// Solo considera facturas a crédito pendientes de cobro
/// cuyo vencimiento cae dentro de cada ventana temporal.
/// Interacción bidireccional: tocar botón o barra del gráfico
/// selecciona el horizonte y muestra su detalle.
class LiquidityPanel extends StatefulWidget {
  const LiquidityPanel({super.key});

  @override
  State<LiquidityPanel> createState() => _LiquidityPanelState();
}

class _LiquidityPanelState extends State<LiquidityPanel> {
  int _selectedHorizon = 1; // 0=15d, 1=30d, 2=45d
  int? _touchedBarIndex;

  static final _today = DateTime(2026, 3, 30);

  /// Facturas a crédito pendientes de cobro.
  static List<Invoice> get _creditPending {
    return MockData.invoices
        .where(
          (i) =>
              i.paymentTerm == PaymentTerm.credito &&
              i.dueDate != null &&
              (i.status == InvoiceStatus.sent ||
                  i.status == InvoiceStatus.pendingReview ||
                  i.status == InvoiceStatus.readyToSend ||
                  i.status == InvoiceStatus.draft),
        )
        .toList();
  }

  static _LiquidityData _compute(int days) {
    final horizon = _today.add(Duration(days: days));
    final inRange = _creditPending.where((i) {
      final due = i.dueDate;
      if (due == null) return false;
      return !due.isBefore(_today) && !due.isAfter(horizon);
    }).toList();
    final total = inRange.fold<double>(0, (s, i) => s + i.total);
    return _LiquidityData(
      days: days,
      total: total,
      count: inRange.length,
      invoices: inRange,
    );
  }

  static final _data15 = _compute(15);
  static final _data30 = _compute(30);
  static final _data45 = _compute(45);

  List<_LiquidityData> get _allData => [_data15, _data30, _data45];

  _LiquidityData get _selected => _allData[_selectedHorizon];

  void _selectHorizon(int index) {
    if (index == _selectedHorizon) return;
    setState(() => _selectedHorizon = index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxTotal = _allData
        .map((d) => d.total)
        .reduce((a, b) => a > b ? a : b);

    return GlassCard(
      header: GlassCardHeader(
        title: 'Previsión de Liquidez',
        subtitle: 'Cobros esperados — solo facturas a crédito',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.info, size: 14, color: colors.textTertiary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${_creditPending.length} facturas pendientes',
              style: AppTypography.caption.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
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
            // ── Horizon selector buttons ──
            Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _HorizonButton(
                      label: '${_allData[i].days} días',
                      total: _allData[i].total,
                      count: _allData[i].count,
                      isActive: _selectedHorizon == i,
                      color: _horizonColor(i, colors),
                      onTap: () => _selectHorizon(i),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.s20),

            // ── Interactive Bar chart ──
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxTotal * 1.15,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: false,
                    touchCallback:
                        (FlTouchEvent event, BarTouchResponse? response) {
                          // On tap/touch, select that bar's horizon
                          if (response != null &&
                              response.spot != null &&
                              event is FlTapUpEvent) {
                            final idx = response.spot!.touchedBarGroupIndex;
                            if (idx >= 0 && idx < 3) {
                              _selectHorizon(idx);
                            }
                          }
                          // Track hover/touch state for visual feedback
                          setState(() {
                            if (response != null &&
                                response.spot != null &&
                                (event is! FlTapUpEvent &&
                                    event is! FlPanEndEvent &&
                                    event is! FlLongPressEnd)) {
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
                        final d = _allData[group.x];
                        final labels = ['15 días', '30 días', '45 días'];
                        return BarTooltipItem(
                          '${labels[group.x]}\n',
                          AppTypography.captionSmallBold.copyWith(
                            color: _horizonColor(group.x, colors),
                          ),
                          children: [
                            TextSpan(
                              text: '${_formatCurrency(d.total)}\n',
                              style: AppTypography.bodySmallMedium.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: '${d.count} facturas',
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
                        interval: maxTotal > 0
                            ? (maxTotal / 3).ceilToDouble()
                            : 1,
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
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final labels = ['15 días', '30 días', '45 días'];
                          final idx = value.toInt();
                          if (idx < 0 || idx >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          final isSelected = idx == _selectedHorizon;
                          final isTouched = idx == _touchedBarIndex;
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  labels[idx],
                                  style: AppTypography.captionSmallBold
                                      .copyWith(
                                        color: isSelected || isTouched
                                            ? _horizonColor(idx, colors)
                                            : colors.textTertiary,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                // Selection indicator dot
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: isSelected ? 6 : 0,
                                  height: isSelected ? 6 : 0,
                                  decoration: BoxDecoration(
                                    color: _horizonColor(idx, colors),
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
                    horizontalInterval: maxTotal > 0
                        ? (maxTotal / 3).ceilToDouble()
                        : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colors.borderSubtle,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (int i = 0; i < 3; i++)
                      BarChartGroupData(
                        x: i,
                        showingTooltipIndicators: _touchedBarIndex == i
                            ? [0]
                            : [],
                        barRods: [
                          BarChartRodData(
                            toY: _allData[i].total,
                            width: i == _selectedHorizon
                                ? 52
                                : (_touchedBarIndex == i ? 48 : 40),
                            borderRadius: AppRadius.smAll,
                            color: _barColor(i, colors),
                            borderSide: i == _selectedHorizon
                                ? BorderSide(
                                    color: _horizonColor(i, colors),
                                    width: 2,
                                  )
                                : BorderSide.none,
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxTotal * 1.15,
                              color: i == _selectedHorizon
                                  ? _horizonColor(
                                      i,
                                      colors,
                                    ).withValues(alpha: 0.04)
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
            const SizedBox(height: AppSpacing.s20),

            // ── Detail section (animated on selection change) ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildDetailSection(
                colors,
                key: ValueKey(_selectedHorizon),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(AppColorsTheme colors, {Key? key}) {
    if (_selected.invoices.isEmpty) {
      return Padding(
        key: key,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          'No hay cobros pendientes a crédito en este período',
          style: AppTypography.bodySmall.copyWith(color: colors.textTertiary),
        ),
      );
    }

    return Column(
      key: key,
      children: [
        // Summary header with color accent
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: _horizonColor(
              _selectedHorizon,
              colors,
            ).withValues(alpha: 0.08),
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: _horizonColor(
                _selectedHorizon,
                colors,
              ).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Colored left accent
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _horizonColor(_selectedHorizon, colors),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flujo de caja a ${_selected.days} días',
                      style: AppTypography.bodySmallMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cobros esperados entre hoy y el ${_formatDate(_today.add(Duration(days: _selected.days)))}',
                      style: AppTypography.captionSmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(_selected.total),
                    style: AppTypography.h4.copyWith(
                      color: _horizonColor(_selectedHorizon, colors),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${_selected.count} facturas',
                    style: AppTypography.captionSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Table header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  'Factura',
                  style: AppTypography.captionSmallBold.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Cliente',
                  style: AppTypography.captionSmallBold.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  'Vence',
                  textAlign: TextAlign.center,
                  style: AppTypography.captionSmallBold.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  'Importe',
                  textAlign: TextAlign.right,
                  style: AppTypography.captionSmallBold.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Divider(color: colors.borderSubtle, height: 1),

        // Invoice rows
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _selected.invoices.length,
            itemBuilder: (context, index) {
              final inv = _selected.invoices[index];
              final daysLeft = inv.dueDate?.difference(_today).inDays ?? 0;
              final accentColor = _horizonColor(_selectedHorizon, colors);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colors.borderSubtle),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        inv.number,
                        style: AppTypography.captionSmallBold.copyWith(
                          color: colors.accentBlue,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        inv.receiverName,
                        style: AppTypography.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: daysLeft <= 7
                              ? colors.statusWarningBg
                              : accentColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          daysLeft == 0 ? 'Hoy' : '${daysLeft}d',
                          textAlign: TextAlign.center,
                          style: AppTypography.captionSmallBold.copyWith(
                            color: daysLeft <= 7
                                ? colors.statusWarning
                                : accentColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        _formatCurrency(inv.total),
                        textAlign: TextAlign.right,
                        style: AppTypography.captionSmallBold.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _barColor(int index, AppColorsTheme colors) {
    final base = _horizonColor(index, colors);
    if (index == _selectedHorizon) return base;
    if (index == _touchedBarIndex) return base.withValues(alpha: 0.6);
    return base.withValues(alpha: 0.2);
  }

  Color _horizonColor(int index, AppColorsTheme colors) {
    switch (index) {
      case 0:
        return colors.statusSuccess;
      case 1:
        return colors.accentBlue;
      default:
        return colors.statusWarning;
    }
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

  static String _formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _LiquidityData {
  final int days;
  final double total;
  final int count;
  final List<Invoice> invoices;

  const _LiquidityData({
    required this.days,
    required this.total,
    required this.count,
    required this.invoices,
  });
}

class _HorizonButton extends StatelessWidget {
  final String label;
  final double total;
  final int count;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _HorizonButton({
    required this.label,
    required this.total,
    required this.count,
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isActive ? 10 : 8,
                  height: isActive ? 10 : 8,
                  decoration: BoxDecoration(
                    color: isActive ? color : color.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
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
              _LiquidityPanelState._formatCurrency(total),
              style: (isActive ? AppTypography.h3 : AppTypography.h4).copyWith(
                color: isActive ? colors.textPrimary : colors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count facturas',
              style: AppTypography.captionSmall.copyWith(
                color: isActive ? color : colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
