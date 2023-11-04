import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

class SleepPlanPieChart extends StatelessWidget {
  const SleepPlanPieChart(
      {super.key,
      required this.sectors,
      required this.radius,
      required this.title,
      required this.desc,
      this.spacing = Style.spacingXs});
  final String title;
  final String desc;
  final double spacing;
  final List<Sector> sectors;
  final double radius;

  List<PieChartSectionData> _chartSections(List<Sector> sectors) {
    return sectors
        .map((sector) => PieChartSectionData(
            color: sector.color, value: sector.value, showTitle: false, borderSide: BorderSide.none, radius: radius))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: AspectRatio(
            aspectRatio: 1.0,
            child:
                PieChart(PieChartData(sections: _chartSections(sectors), centerSpaceRadius: 0.0, sectionsSpace: 0.0)),
          ),
        ),
        SizedBox(height: spacing),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        Text(
          desc,
          style: dataTextTheme.labelSmall?.copyWith(fontWeight: FontWeight.w100),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}

/// [Sector] has a [value] that determines how much it should occupy in a pie chart,
///  this is depends on sum of all sections, each section should occupy
/// ([value] / sumValues) * 360 degrees.
class Sector {
  final Color color;
  final double value;
  const Sector({required this.color, required this.value})
      : assert(value > 0, 'value $value must be larger than 0.0 in a pie chart.');
}
