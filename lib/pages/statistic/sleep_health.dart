import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/line_chart.dart';
import 'package:sleep_tracker/components/period_picker/period_picker.dart';
import 'package:sleep_tracker/components/range_indicator.dart';
import 'package:sleep_tracker/components/sleep_period_tab_bar.dart';
import 'package:sleep_tracker/utils/date_time.dart';
import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

const double _tabRowHeight = 42.0;
const double _tabBarHeight = _tabRowHeight + Style.spacingMd;
const double _appBarHeight = _tabBarHeight + kToolbarHeight;
const double _infoButtonHeight = 20.0;

@RoutePage()
class SleepHealthPage extends StatefulWidget {
  const SleepHealthPage({super.key});

  @override
  State<SleepHealthPage> createState() => _SleepHealthPageState();
}

class _SleepHealthPageState extends State<SleepHealthPage> {
  // dev use
  final List<double> data = List.generate(DateTime.daysPerWeek, (day) => Random().nextDouble() * 100);
  final List<String> _titles = [
    'Avg. Sleep Efficiency',
    'Avg. Time asleep',
    'Regularity',
    'Avg. WASO',
    'Avg. Sleep Quality'
  ];
  final List<String?> _info = [
    'Your sleep efficiency is a measure of how well you are sleeping and is used as a guideline for your sleep therapy. It is calculated by dividing your Total Sleep Time (TST) by your Time In Bed (TIB).',
    null,
    'Regularity is calculated by your routine of when to bed',
    'WASO (Wake After Sleep Onset)  is the amount of time that you were awake after first falling asleep and before getting out of bed',
    'Your sleep quality is your feeling of satisfaction with sleep.'
  ];
  final List<double> _detailData = [67, 812, 69, 80, 54];

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
    final String title = _titles[index];
    final String? info = _info[index];
    final double data = _detailData[index];
    const Color headerForegroundColor = Style.grey3;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Style.spacingMd, horizontal: Style.spacingLg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _infoButtonHeight),
                  child: GestureDetector(
                    onTap: info != null
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                  child: Padding(
                                padding: const EdgeInsets.all(Style.spacingMd),
                                child: Text(info),
                              )),
                            );
                          }
                        : null,
                    child: Row(
                      children: [
                        Text(title, style: const TextStyle(color: headerForegroundColor)),
                        if (info != null && info.isNotEmpty) ...[
                          const SizedBox(width: Style.spacingXxs),
                          SvgPicture.asset('assets/icons/info.svg', color: headerForegroundColor, width: 16, height: 16)
                        ]
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(data.toString(), style: dataTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: Style.spacingSm),
                    _TrendIndicator(value: Random().nextDouble(), indicatorColor: Style.highlightGold)
                  ],
                ),
              ],
            ),
          ),
          RangeIndicator(
            value: Random().nextDouble(),
            max: 1,
            min: 0,
            upperLimit: 0.8,
            lowerLimit: 0.5,
            canvasSize: const Size(72, 72),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    final overview = Row(
      children: [
        Flexible(
          flex: 3,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _infoButtonHeight),
            child: Row(
              children: [
                const Text(
                  'Avg. Sleep Health',
                  style: TextStyle(color: Style.grey3),
                ),
                const SizedBox(width: Style.spacingXxs),
                SvgPicture.asset('assets/icons/info.svg', color: Style.grey3, width: 16, height: 16),
              ],
            ),
          ),
        ),
        Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingSm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '78%',
                    style: dataTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.w600, color: Style.grey1),
                  ),
                  const SizedBox(width: Style.spacingXxs),
                  _TrendIndicator(value: 0.21, indicatorColor: Style.highlightGold)
                ],
              ),
            ))
      ],
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(_appBarHeight),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.75),
          elevation: 0,
          centerTitle: false,
          title: const Text("Sleep Health"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(_tabBarHeight),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Style.spacingMd),
                child: SleepPeriodTabBar(labels: _tabs, initialIndex: _tabIndex, onChanged: _handleTabChanged)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: _appBarHeight + Style.spacingXl),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 186),
              child: LineChart(
                data: List.generate(data.length, (index) => Point(index, data[index])),
                color: Style.highlightGold,
                gradientColors: [Style.highlightGold.withOpacity(0.8), Style.highlightGold.withOpacity(0.1)],

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
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Style.spacingLg),
              child: periodHeader,
            ),
            Padding(
              padding: const EdgeInsets.only(left: Style.spacingLg, right: Style.spacingMd),
              child: overview,
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: Style.spacingLg),
              itemCount: _titles.length,
              itemBuilder: _buildItems,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: Style.spacingXs),
                child: Divider(color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            const SizedBox(height: kBottomNavigationBarHeight),
          ],
        ),
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  _TrendIndicator({
    required this.value,
    required this.indicatorColor,
    this.rangeConditions = const [],
  })  : assert(value >= -1.0 && value <= 1.0),
        assert(rangeConditions.isEmpty || rangeConditions.length == 2);

  /// [value] draws the amount/trend in percentage.
  /// It only accepts double range from -1 to 1.
  final double value;

  /// [indicatorColor] determines the foreground color.
  final Color indicatorColor;

  /// [rangeConditions] determines whether should the [value] falls into
  /// Increased/Decreased/Neutral. Length of [rangeConditions] is therefore restricted
  /// into two.
  ///
  /// If [rangeConditions] is not provided. the default Neutral condition is 0.
  ///
  /// For example, the [rangeConditions] is [-0.1, 0.1]. If [value] is smaller than -0.1,
  /// then it is regarded as Decreased. If [value] is larger than 0.1, it is regarded as Increased.
  /// If [value] falls between -0.1 and 0.1, then it is regarded as Neutral.
  ///
  final List<double> rangeConditions;

  Widget _buildIndicator() {
    Widget indicator;
    double upperValue = rangeConditions.isEmpty ? 0 : rangeConditions.max;
    double lowerValue = rangeConditions.isEmpty ? 0 : rangeConditions.min;
    bool isNeutral = (rangeConditions.isEmpty && value == 0) ||
        (rangeConditions.isNotEmpty && value >= lowerValue && value <= upperValue);
    if (isNeutral) {
      indicator = Container(width: 8, height: 1, color: indicatorColor);
    } else if (value > upperValue) {
      indicator = SvgPicture.asset('assets/icons/arrow-up.svg', color: indicatorColor);
    } else {
      indicator = SvgPicture.asset('assets/icons/arrow-down.svg', color: indicatorColor);
    }
    return SizedBox(height: 8, child: Center(child: indicator));
  }

  @override
  Widget build(BuildContext context) {
    final String label = '${value.isNegative ? '-' : '+'}${(value.abs() * 100).round()}%';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIndicator(),
        Text(
          label,
          style: dataTextTheme.bodySmall?.copyWith(color: indicatorColor, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
