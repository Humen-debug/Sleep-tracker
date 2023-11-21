import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:sleep_tracker/utils/style.dart';

const double _lineChartHeight = 186.0;

/// [LineChart] draws a line chart using provided [data].
/// Currently it only draw one group of data.
class LineChart<T extends Object?, K extends num?> extends StatelessWidget {
  /// [data] contains the y-axis data for [LineChart] to render.
  /// the [length] of [data] determines the x-axis for [LineChart].
  LineChart({
    super.key,
    required this.data,
    List<Color>? gradientColors,
    this.color,
    this.chartHeight = _lineChartHeight,
    this.getXTitles,
    this.getYTitles,
    this.getSpot,
    this.showDots = false,
    this.yTitleWidth = 44.0,
    this.minX,
    this.maxX,
    this.baselineX,
    this.minY,
    this.maxY,
    this.baseLineY,
    this.intervalX,
    this.intervalY,
  }) : gradientColors =
            gradientColors ?? (color != null ? <Color>[color.withOpacity(0.8), color.withOpacity(0.1)] : []);

  final List<Point<T, K>> data;

  /// Colors of the under bar area.
  final List<Color> gradientColors;

  /// Line chart color.
  final Color? color;

  final double chartHeight;

  /// Functions that takes the x-indices and returns the corresponding
  /// titles.
  final String Function(double value)? getXTitles;

  /// Functions that takes the y-indices data and returns the corresponding
  /// titles.
  final String Function(double value)? getYTitles;

  /// Functions that takes the index and y-axis value and returns the
  /// corresponding spot.
  ///
  /// In default, getSpot = fl.FlSpot(index, value)
  final Point<num, num?> Function(T x, K y)? getSpot;

  /// True if show dots on the line/curve.
  final bool showDots;

  final double yTitleWidth;

  final double? minX;
  final double? maxX;
  final double? baselineX;
  final double? minY;
  final double? maxY;
  final double? baseLineY;
  final double? intervalX;
  final double? intervalY;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: chartHeight,
      child: fl.LineChart(
        fl.LineChartData(
          minY: minY,
          minX: minX,
          maxY: maxY,
          maxX: maxX,
          baselineX: baselineX,
          baselineY: baseLineY,
          lineTouchData: fl.LineTouchData(
              enabled: true,
              touchTooltipData: fl.LineTouchTooltipData(
                tooltipBgColor: Theme.of(context).colorScheme.background,
                tooltipBorder: BorderSide(color: color ?? Theme.of(context).primaryColor, width: 2),
                showOnTopOfTheChartBoxArea: false,
                fitInsideHorizontally: true,
                tooltipMargin: Style.spacingSm,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map(
                    (fl.LineBarSpot touchedSpot) {
                      final index = touchedSpot.x;
                      final value = touchedSpot.y;
                      final x = getXTitles?.call(index) ?? index.toString();
                      final y = getYTitles?.call(value) ?? value.toString();
                      return fl.LineTooltipItem(
                        '$x${x.isNotEmpty ? ',' : ''} $y',
                        Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: touchedSpot.bar.color, fontWeight: FontWeight.bold),
                      );
                    },
                  ).toList();
                },
              )),
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
                getTitlesWidget: (value, meta) => Text(
                  getXTitles != null ? getXTitles!(value) : value.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
                interval: intervalX,
              ),
            ),
            leftTitles: fl.AxisTitles(
              sideTitles: fl.SideTitles(
                showTitles: true,
                reservedSize: yTitleWidth,
                getTitlesWidget: (value, meta) => Text(
                  getYTitles != null ? getYTitles!(value) : value.toString(),
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
                interval: intervalY,
              ),
            ),
            topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
            rightTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
          ),
          lineBarsData: <fl.LineChartBarData>[
            fl.LineChartBarData(
              spots: data.mapIndexed((index, d) {
                Point<num, num?>? pair = getSpot?.call(d.x, d.y);
                final double x = (pair?.x ?? index).toDouble();
                final double? y = (pair?.y ?? d.y)?.toDouble();
                return y == null ? fl.FlSpot.nullSpot : fl.FlSpot(x, y);
              }).toList(),
              dotData: fl.FlDotData(show: showDots),
              isCurved: true,
              barWidth: 3,
              curveSmoothness: .3,
              preventCurveOverShooting: true,
              color: color ?? Theme.of(context).primaryColor,
              belowBarData: gradientColors.isEmpty
                  ? null
                  : fl.BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                          colors: gradientColors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class Point<T extends Object?, K extends num?> {
  const Point(this.x, this.y);
  final T x;
  final K y;

  @override
  String toString() => 'Point(x: $x, y: $y)';
}
