import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/bar_chart.dart';
import 'package:sleep_tracker/components/line_chart.dart';
import 'package:sleep_tracker/components/period_pickers.dart';
import 'package:sleep_tracker/components/sleep_period_tab_bar.dart';
import 'package:sleep_tracker/routers/app_router.dart';
import 'package:sleep_tracker/utils/date_time.dart';
import 'package:sleep_tracker/utils/style.dart';

const double _tabRowHeight = 50.0;
const double _appBarHeight = _tabRowHeight + Style.spacingMd * 2;

@RoutePage()
class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  late final ButtonStyle? _elevationButtonStyle = Theme.of(context).elevatedButtonTheme.style?.copyWith(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return Theme.of(context).colorScheme.background;
          }
          return Theme.of(context).colorScheme.tertiary;
        },
      ),
      foregroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
      side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 2)),
      padding:
          const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingSm)),
      minimumSize: const MaterialStatePropertyAll(Size(72.0, 32.0)));

  final List<String> _tabs = ['Days', 'Weeks', 'Months'];
  final List<PeriodPickerMode> _pickerModes = [PeriodPickerMode.weeks, PeriodPickerMode.weeks, PeriodPickerMode.months];
  final List<bool> _inRange = [false, true, true];

  int _tabIndex = 0;

  /// Friday of this week as the last date.
  final DateTime lastDate = DateTimeUtils.mostNearestWeekday(DateTime.now(), 6);
  final DateTime firstDate = DateTime.now().subtract(const Duration(days: 365)).copyWith(day: 1);

  bool get _isDisplayingFirstDate => !selectedRange.start.isAfter(firstDate);
  bool get _isDisplayingLastDate => !selectedRange.end.isBefore(lastDate);

  late DateTimeRange selectedRange =
      DateTimeRange(start: DateTimeUtils.mostRecentWeekday(DateTime.now(), 0), end: lastDate);

  // dev use
  final List<String> _titles = ['Sleep Health', 'Sleep Duration', 'Most Asleep Time', 'Went to Sleep', 'Sleep Quality'];
  final List<bool> _hasMore = [true, false, false, false, false];
  final List<bool> _isBarChart = [false, true, true, false, false];
  late final List<List<double>> _dataGroups =
      List.generate(5, (index) => List.generate(DateTime.daysPerWeek, (day) => Random().nextDouble() * 100));
  late final List<Color> _chartColors = [
    Style.highlightGold,
    Theme.of(context).primaryColor,
    Theme.of(context).primaryColor,
    Style.highlightPurple,
    Style.successColor
  ];

  void _handleTabChanged(int index) {
    setState(() => _tabIndex = index);
  }

  void _handlePreviousPeriod() {
    if (!_isDisplayingFirstDate) {
      switch (_tabIndex) {
        // According to the PeriodPickerMode. 0 index refers to the "DAYS"
        // selection, which has constant 7-day per week as range.
        case 0:
          break;
        case 1:
        case 2:
        default:
      }
    }
  }

  void _handleNextPeriod() {
    if (!_isDisplayingLastDate) {}
  }

  Widget _buildItems(BuildContext context, int index) {
    final moreButton = ElevatedButton(
        onPressed: () {
          // dev. Since there is only one more button among all statistic chart.
          // It is assumed the [onPressed] only handle the [SleepHealth] case.

          context.pushRoute(const SleepHealthRoute());
        },
        style: _elevationButtonStyle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('More'),
            SvgPicture.asset('assets/icons/chevron-right.svg', color: Theme.of(context).primaryColor)
          ],
        ));

    final periodHeader = Row(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
          onTap: _handlePreviousPeriod, child: SvgPicture.asset('assets/icons/chevron-left.svg', color: Style.grey1)),
      PeriodPicker(
        maxWidth: 100,
        mode: _pickerModes[_tabIndex],
        selectedDate: selectedRange.start,
        selectedRange: selectedRange,
        lastDate: lastDate,
        firstDate: firstDate,
        rangeSelected: _inRange[_tabIndex],
        onDateChanged: (value) {
          if (value != null && value != selectedRange.start) {
            setState(() {
              selectedRange =
                  DateTimeRange(start: value, end: value.add(const Duration(days: DateTime.daysPerWeek - 1)));
            });
          }
        },
      ),
      GestureDetector(
          onTap: _handleNextPeriod, child: SvgPicture.asset('assets/icons/chevron-right.svg', color: Style.grey1)),
    ]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Style.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatisticHeader(
            title: _titles[index],
            topBarRightWidget: _hasMore[index] ? moreButton : periodHeader,
          ),
          const SizedBox(height: Style.spacingXl),
          ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 186),
              child: (!_isBarChart[index])
                  ? LineChart(
                      data: List.generate(_dataGroups[index].length, (i) => Point(i, _dataGroups[index][i])),
                      color: _chartColors[index],
                      gradientColors: [_chartColors[index].withOpacity(0.8), _chartColors[index].withOpacity(0.1)],

                      /// Computes the x-indices as the selected date rang
                      getXTitles: (value) {
                        if (value == value.roundToDouble()) {
                          final date = selectedRange.start.add(Duration(days: value.toInt()));
                          return DateFormat.Md().format(date);
                        }
                        return "";
                      },

                      getYTitles: (value) {
                        if (value == value.roundToDouble()) {
                          return "${value.toInt()}%";
                        }
                        return "";
                      },
                    )
                  : BarChart(
                      data: _dataGroups[index],
                      gradientColors: [_chartColors[index], Theme.of(context).colorScheme.tertiary],

                      /// Computes the x-indices as the selected date rang
                      getXTitles: (value) {
                        if (value == value.roundToDouble()) {
                          final date = selectedRange.start.add(Duration(days: value.toInt()));
                          return DateFormat.Md().format(date);
                        }
                        return "";
                      },
                    )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(_appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.75),
          elevation: 0,
          flexibleSpace: Padding(
              padding: const EdgeInsets.all(Style.spacingMd),
              child: SleepPeriodTabBar(
                labels: _tabs,
                initialIndex: _tabIndex,
                onChanged: _handleTabChanged,
              )),
        ),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemBuilder: _buildItems,
        separatorBuilder: (_, __) => const SizedBox(height: Style.spacingXxl),
        itemCount: _titles.length,
      ),
    );
  }
}

class _StatisticHeader extends StatelessWidget {
  const _StatisticHeader({required this.title, this.topBarRightWidget});
  final String title;
  final Widget? topBarRightWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (topBarRightWidget != null) topBarRightWidget!
      ],
    );
  }
}
