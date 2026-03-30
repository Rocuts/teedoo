import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../core/mock/mock_data.dart';

/// Gráfico de ingresos mensuales — LineChart con área rellena.
///
/// Ref screenshot: "Ingresos Mensuales — Resumen del año fiscal 2025"
class MonthlyRevenueChart extends StatelessWidget {
  const MonthlyRevenueChart({super.key});

  static List<String> get _months => MockData.chartMonths;

  static List<double> get _values => MockData.chartValues;

  /// Calcula un intervalo "limpio" para el eje Y (e.g. 5, 10, 25, 50, 100, 250…).
  static num _niceInterval(double maxValue) {
    if (maxValue <= 0) return 5;
    final rough = maxValue / 4; // apunta a ~4-5 líneas de grid
    final magnitude = pow(10, (log(rough) / ln10).floor());
    final normalized = rough / magnitude;
    final nice = normalized <= 1.5
        ? 1
        : (normalized <= 3.5 ? 2.5 : (normalized <= 7.5 ? 5 : 10));
    return (nice * magnitude).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final values = _values;

    // Escala adaptativa: redondea el máximo al siguiente múltiplo "limpio"
    final rawMax = values.isEmpty ? 10.0 : values.reduce(max);
    final interval = _niceInterval(rawMax);
    final maxY = (rawMax / interval).ceil() * interval;

    return GlassCard(
      header: GlassCardHeader(
        title: 'Ingresos Mensuales',
        subtitle: 'Resumen del año fiscal ${DateTime.now().year}',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.accentBlue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Ingresos',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.s20,
          AppSpacing.s24,
          AppSpacing.s20,
        ),
        child: SizedBox(
          height: 280,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY.toDouble(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval.toDouble(),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colors.borderSubtle,
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= _months.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          _months[idx],
                          style: AppTypography.captionSmall.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    interval: interval.toDouble(),
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}k €',
                        style: AppTypography.captionSmall.copyWith(
                          color: colors.textTertiary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    values.length,
                    (i) => FlSpot(i.toDouble(), values[i]),
                  ),
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: colors.accentBlue,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colors.accentBlue.withValues(alpha: 0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => colors.bgSurface,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)}k €',
                        AppTypography.button.copyWith(
                          color: colors.textPrimary,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
