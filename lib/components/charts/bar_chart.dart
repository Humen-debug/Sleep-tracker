import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:sleep_tracker/utils/style.dart';

const double _yIndexWidth = 44.0;

class BarChart extends StatelessWidget {
  const BarChart(
      {super.key,
      required this.data,
      required this.gradientColors,
      this.getXTitles,
      this.getYTitles,
      this.chartHeight = 186.0});
  // dev
  final List<double> data;

  /// Gradient colors of the bar.
  final List<Color> gradientColors;

  /// Functions that takes the x-indices and returns the corresponding
  /// titles.
  final String Function(double value)? getXTitles;

  /// Functions that takes the y-indices data and returns the corresponding
  /// titles.
  final String Function(double value)? getYTitles;

  final double chartHeight;

  List<fl.BarChartGroupData> _chartGroups(BoxConstraints constraints) {
    return data
        .mapIndexed((x, y) => fl.BarChartGroupData(x: x.toInt(), barRods: [
              fl.BarChartRodData(
                toY: y,
                width: ((constraints.maxWidth - _yIndexWidth) / data.length) / 2,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Style.radiusSm / 2)),
                gradient:
                    LinearGradient(colors: gradientColors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
              )
            ]))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: chartHeight),
      child: LayoutBuilder(builder: (context, constraints) {
        return fl.BarChart(fl.BarChartData(
            barTouchData: fl.BarTouchData(
                enabled: true,
                touchTooltipData: fl.BarTouchTooltipData(
                  tooltipBgColor: Theme.of(context).colorScheme.background,
                  tooltipBorder:
                      BorderSide(color: gradientColors.firstOrNull ?? Theme.of(context).primaryColor, width: 2),
                  fitInsideHorizontally: true,
                  tooltipMargin: Style.spacingSm,
                  getTooltipItem: (fl.BarChartGroupData group, int groupIndex, fl.BarChartRodData rod, int rodIndex) {
                    final x = getXTitles?.call(groupIndex.toDouble()) ?? groupIndex.toString();
                    final y = (getYTitles?.call(rod.toY) ?? rod.toY).toString();
                    return fl.BarTooltipItem(
                      '$x, $y',
                      Theme.of(context).textTheme.bodySmall!.copyWith(color: rod.color, fontWeight: FontWeight.bold),
                    );
                  },
                )),
            gridData: fl.FlGridData(
              show: true,
              drawVerticalLine: false,
              drawHorizontalLine: true,
              getDrawingHorizontalLine: (value) =>
                  fl.FlLine(color: Theme.of(context).colorScheme.tertiary, strokeWidth: 1),
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
                    reservedSize: _yIndexWidth,
                    getTitlesWidget: (value, meta) => Text(
                          getYTitles != null ? getYTitles!(value) : value.toString(),
                          textAlign: TextAlign.end,
                        )),
              ),
              topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
              rightTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
            ),
            barGroups: _chartGroups(constraints)));
      }),
    );
  }
}
