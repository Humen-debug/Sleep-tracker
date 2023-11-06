import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

/// [LineChart] draws a line chart using provided [data].
/// Currently it only draw one group of data.
class LineChart extends StatelessWidget {
  /// [data] contains the y-axis data for [LineChart] to render.
  /// the [length] of [data] determines the x-axis for [LineChart].
  const LineChart({
    Key? key,
    required this.data,
    this.gradientColors = const [],
    this.color,
    this.getXTitles,
    this.getYTitles,
    this.showDots = false,
  }) : super(key: key);
  // dev
  final List<double> data;

  /// Colors of the under bar area.
  final List<Color> gradientColors;

  /// Line chart color.
  final Color? color;

  /// Functions that takes the x-indices and returns the corresponding
  /// titles.
  final String Function(double value)? getXTitles;

  /// Functions that takes the y-indices data and returns the corresponding
  /// titles.
  final String Function(double value)? getYTitles;

  /// True if show dots on the line/curve.
  final bool showDots;

  @override
  Widget build(BuildContext context) {
    return fl.LineChart(
      fl.LineChartData(
        gridData: fl.FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingVerticalLine: (value) => fl.FlLine(color: Theme.of(context).colorScheme.tertiary, strokeWidth: 1),
          drawHorizontalLine: false,
        ),
        titlesData: fl.FlTitlesData(
          bottomTitles: fl.AxisTitles(
            sideTitles: fl.SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(getXTitles != null ? getXTitles!(value) : value.toString()),
            ),
          ),
          leftTitles: fl.AxisTitles(
            sideTitles: fl.SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) => Text(
                      getYTitles != null ? getYTitles!(value) : value.toString(),
                      textAlign: TextAlign.end,
                    )),
          ),
          topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
          rightTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
        ),
        lineBarsData: <fl.LineChartBarData>[
          fl.LineChartBarData(
            spots: data.mapIndexed((index, d) => fl.FlSpot(index.toDouble(), d)).toList(),
            dotData: fl.FlDotData(show: showDots),
            isCurved: true,
            barWidth: 3,
            color: color ?? Theme.of(context).primaryColor,
            belowBarData: gradientColors.isEmpty
                ? null
                : fl.BarAreaData(
                    show: true,
                    gradient:
                        LinearGradient(colors: gradientColors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
          ),
        ],
      ),
    );
  }
}
