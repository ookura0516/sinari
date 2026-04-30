import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EquityCurveChart extends StatelessWidget {
  final List<double> equityCurve;

  const EquityCurveChart({super.key, required this.equityCurve});

  @override
  Widget build(BuildContext context) {
    if (equityCurve.isEmpty) {
      return const Center(child: Text('データがありません'));
    }

    final spots = equityCurve
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final minY = equityCurve.reduce((a, b) => a < b ? a : b);
    final maxY = equityCurve.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    final colorScheme = Theme.of(context).colorScheme;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (v, meta) => Text(
                _formatCompact(v),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompact(double v) {
    if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}
