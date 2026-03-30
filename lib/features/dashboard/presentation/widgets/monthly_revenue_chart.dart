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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              maxY: 110,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
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
                    interval: 25,
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
                    _values.length,
                    (i) => FlSpot(i.toDouble(), _values[i]),
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
