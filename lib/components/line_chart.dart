import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

class LineChart extends StatelessWidget {
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
  final List<Color> gradientColors;
  final Color? color;
  final String Function(double value)? getXTitles;
  final String Function(double value)? getYTitles;
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
          // getDrawingHorizontalLine: (value) => FlLine(color: Theme.of(context).primaryColor, strokeWidth: 1),
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
        lineBarsData: [
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
