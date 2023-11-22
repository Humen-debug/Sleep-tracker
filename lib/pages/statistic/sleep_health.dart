import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/charts/line_chart.dart';
import 'package:sleep_tracker/components/range_indicator.dart';
import 'package:sleep_tracker/components/sleep_period_tab_bar.dart';
import 'package:sleep_tracker/models/sleep_record.dart';
import 'package:sleep_tracker/providers/auth/auth_provider.dart';
import 'package:sleep_tracker/providers/sleep_records_provider.dart';
import 'package:sleep_tracker/utils/date_time.dart';
import 'package:sleep_tracker/utils/num.dart';
import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

const double _tabRowHeight = 42.0;
const double _tabBarHeight = _tabRowHeight + Style.spacingMd;
const double _appBarHeight = _tabBarHeight + kToolbarHeight;
const double _infoButtonHeight = 20.0;

@RoutePage()
class SleepHealthPage extends ConsumerStatefulWidget {
  const SleepHealthPage({super.key});

  @override
  ConsumerState<SleepHealthPage> createState() => _SleepHealthPageState();
}

class _SleepHealthPageState extends ConsumerState<SleepHealthPage> {
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
  final List<String Function(double value)> _formats = [
    NumFormat.toPercent,
    (value) => "${value ~/ 60}h ${value.remainder(60).round()}m",
    NumFormat.toPercent,
    (value) => "${value ~/ 60}h ${value.remainder(60).round()}m",
    NumFormat.toPercent,
  ];

  final List<double> _maxs = [1.0, 1440, 1.0, 1440, 1.0];
  final List<double> _upperPercent = [1.0, 604.5 / 1440, 1.0, 427 / 1440, 1];
  final List<double> _lowerPercent = [0.6, 420 / 1440, 0.5, 0.0, 0.5];

  /// [_data] returns the computed data for each statistic.
  ///
  /// Element's value will be computed again when the [selectedRange] changes.
  List<double?> _data = [null, null, null, null, null];

  /// [_trends] returns the computed the trends compared with intervals shown in [_tabs]
  /// for each statistic.
  ///
  /// Element's value will be computed again when the [selectedRange] changes.
  List<double?> _trends = [null, null, null, null, null];

  final List<String> _tabs = ['One Week', '6 Weeks', '6 Months'];

  int _tabIndex = 0;
  static const int _chartLength = 6;

  /// Friday of this week as the last date.
  late final DateTime lastDate;
  late final DateTime firstDate;

  late DateTimeRange selectedRange;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    final DateTime first = ref.read(authStateProvider).sleepRecords.lastOrNull?.start ?? now;
    firstDate =
        DateUtils.addMonthsToMonthDate(DateUtils.dateOnly(DateTimeUtils.mostRecentWeekday(first, 0)), -_chartLength);
    lastDate = now;
    selectedRange = DateTimeRange(start: DateTimeUtils.mostRecentWeekday(now, 0), end: lastDate);
  }

  void _handleTabChanged(int index) {
    final DateTime end = selectedRange.end;
    DateTime start;
    setState(() {
      _tabIndex = index;
      if (_tabIndex == 0) {
        start = DateUtils.addDaysToDate(end, -_chartLength);
      } else if (_tabIndex == 1) {
        start = DateUtils.addDaysToDate(end, -(DateTime.daysPerWeek * _chartLength) + 1);
      } else {
        start = DateUtils.addMonthsToMonthDate(end, -_chartLength);
      }
      selectedRange = DateTimeRange(start: start, end: end);
    });
  }

  Widget _buildItems(BuildContext context, int index) {
    final String title = _titles[index];
    final String? info = _info[index];
    final double? data = _data[index];
    final double? trend = _trends[index];
    final double max = _maxs[index];
    final String Function(double) format = _formats[index];
    final double upperLimit = max * _upperPercent[index];
    final double lowerLimit = max * _lowerPercent[index];
    const Color headerForegroundColor = Style.grey3;

    Widget rangeDescription;
    if (data == null) {
      rangeDescription = const SizedBox.shrink();
    } else if (data <= upperLimit && data >= lowerLimit) {
      rangeDescription = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/icons/success-circle-outline.svg', color: Style.successColor, width: 16, height: 16),
          const SizedBox(width: Style.spacingXxs),
          const Flexible(child: Text('Within the recommended range', style: TextStyle(color: Style.successColor)))
        ],
      );
    } else {
      String verb = data > upperLimit ? 'Exceeds' : 'Below';
      rangeDescription = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/icons/fail-circle-outline.svg',
              color: Theme.of(context).colorScheme.error, width: 16, height: 16),
          const SizedBox(width: Style.spacingXxs),
          Flexible(
              child: Text('$verb the recommended range', style: TextStyle(color: Theme.of(context).colorScheme.error)))
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).colorScheme.tertiary))),
      padding: const EdgeInsets.all(Style.spacingLg),
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
                    Text(data == null ? 'No Data' : format(data),
                        style: dataTextTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: data == null ? Style.grey3 : Style.grey1,
                        )),
                    const SizedBox(width: Style.spacingSm),
                    if (trend != null) _TrendIndicator(value: trend, indicatorColor: Style.highlightGold),
                  ],
                ),
                const SizedBox(height: Style.spacingXs),
                rangeDescription,
              ],
            ),
          ),
          RangeIndicator(
            value: data,
            max: max,
            min: 0,
            upperLimit: upperLimit,
            lowerLimit: lowerLimit,
            canvasSize: const Size(72, 72),
          )
        ],
      ),
    );
  }

  /// The first element is the [sleepEfficiencies] for the line chart.
  /// The other elements are the average sleep efficiency, average time asleep,
  /// regularity, average WASO and average sleep quality.
  List _computeStatistic(DateTime start, DateTime end) {
    // Stores mean sleep efficiency per record.
    List<Point<DateTime, double?>> sleepEfficiencies = [];
    double totalSleepEfficiency = 0;
    // Store average mood
    double? meanMood;
    // Stores total WASO (i.e. amount of awaken time after first fall asleep and before getting
    // out of bed)
    double wasoInMinutes = 0.0;
    double totalAsleepMinutes = 0.0;
    // Stores the similarity when to bed
    double? regularity;

    int moodCount = 0;
    int count = 0;

    int interval;
    if (_tabIndex == 0) {
      //  interval as single day
      interval = 1;
    } else if (_tabIndex == 1) {
      //  interval as single week
      interval = DateTime.daysPerWeek;
    } else {
      interval = DateUtils.getDaysInMonth(start.year, start.month);
    }
    while (!start.isAfter(end)) {
      // update interval if [_tabIndex] == 2
      if (_tabIndex == 2) interval = DateUtils.getDaysInMonth(start.year, start.month);
      final DateTime next = DateUtils.addDaysToDate(start, interval);
      final Iterable<SleepRecord> sleepRecords =
          ref.watch(rangeSleepRecordsProvider(DateTimeRange(start: start, end: next)));

      final List<Point<DateTime, double?>> sleepEfficiency = [];
      for (final record in sleepRecords) {
        count++;

        final double? mood = record.sleepQuality;
        meanMood ??= mood;
        if (mood != null) moodCount++;
        if (meanMood != null && mood != null) {
          meanMood = (meanMood * (moodCount - 1) + mood) / moodCount;
        }

        final DateTime start = record.start;
        final sleepEvents = record.events;
        double awakenMinutes = 0.0;
        bool hasFellAsleep = false;

        for (int i = 0; i < sleepEvents.length - 1; i++) {
          final log = sleepEvents.elementAt(i);
          final nextLog = sleepEvents.elementAt(i + 1);
          final time = nextLog.time.difference(log.time).inMilliseconds / (60 * 1000);

          if (log.type != SleepType.awaken && !hasFellAsleep) {
            hasFellAsleep = true;
          }

          // According to our sleep-wake classification algorithm, type is divided into
          // SleepType.awaken and SleepType.deepSleep;
          if (log.type == SleepType.awaken) {
            awakenMinutes += time;
            if (hasFellAsleep) {
              wasoInMinutes += time;
            }
          }
        }

        if (sleepEvents.isNotEmpty && sleepRecords.last.wakeUpAt != null) {
          final last = sleepEvents.last;
          final time = (sleepRecords.last.wakeUpAt!.difference(last.time).inMilliseconds).abs() / (60 * 1000);
          if (last.type == SleepType.awaken) {
            awakenMinutes += time;
          }
        }
        double minutesInBed = sleepRecords
            .where((record) => record.wakeUpAt != null)
            .fold(0.0, (previousValue, record) => previousValue + record.wakeUpAt!.difference(record.start).inMinutes);

        double asleepMinutes = minutesInBed - awakenMinutes;
        totalAsleepMinutes += asleepMinutes;
        double efficiency = asleepMinutes / minutesInBed;
        totalSleepEfficiency += efficiency;
        sleepEfficiency.add(Point(start, minutesInBed == 0 ? null : efficiency));
      }

      start = next;
      sleepEfficiencies.addAll(sleepEfficiency.isEmpty ? [Point(start, null)] : sleepEfficiency);
    }
    double? meanEfficiency = count == 0 ? null : totalSleepEfficiency / count;
    double? meanAsleepTime = count == 0 ? null : totalAsleepMinutes / count;
    double? meanWASO = count == 0 ? null : wasoInMinutes / count;
    return [
      sleepEfficiencies,
      meanEfficiency,
      meanAsleepTime,
      regularity,
      meanWASO,
      meanMood,
    ];
  }

  @override
  Widget build(BuildContext context) {
    DateTime start = DateUtils.dateOnly(selectedRange.start);
    DateTime end = DateUtils.dateOnly(selectedRange.end);
    final currentData = _computeStatistic(start, end);
    // Stores mean sleep efficiency per record.
    List<Point<DateTime, double?>> sleepEfficiencies = currentData[0];
    // Returns statistic in current interval.
    _data = List<double?>.from(currentData.sublist(1));

    // Computes previous interval
    if (_tabIndex == 0) {
      end = DateUtils.addDaysToDate(end, -_chartLength);
      start = DateUtils.addDaysToDate(end, -_chartLength);
    } else if (_tabIndex == 1) {
      end = DateUtils.addDaysToDate(end, -(DateTime.daysPerWeek * _chartLength) + 1);
      start = DateUtils.addDaysToDate(end, -(DateTime.daysPerWeek * _chartLength) + 1);
    } else {
      end = DateUtils.addMonthsToMonthDate(end, -_chartLength);
      start = DateUtils.addMonthsToMonthDate(end, -_chartLength);
    }
    final previousData = List<double?>.from(_computeStatistic(start, end).sublist(1));
    _trends = _data.mapIndexed((index, data) {
      final previous = previousData[index];
      if (previous == null || data == null) return null;
      return data - previous;
    }).toList();

    int interval;
    if (_tabIndex == 0) {
      //  interval as single day
      interval = 1;
    } else if (_tabIndex == 1) {
      //  interval as single week
      interval = DateTime.daysPerWeek;
    } else {
      interval = DateUtils.getDaysInMonth(start.year, start.month);
    }

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
                  data: sleepEfficiencies,
                  getSpot: (x, y) {
                    // compute dx as index in unit [day]
                    final dx = x.millisecondsSinceEpoch;
                    return Point(dx, y);
                  },
                  getYTitles: NumFormat.toPercent,
                  getXTitles: (double value) {
                    // value is in milliSecondsSinceEpoch.
                    if (value == value.roundToDouble()) {
                      DateFormat format;

                      if (_tabIndex == 0) {
                        format = DateFormat.Md();
                      } else if (_tabIndex == 1) {
                        format = DateFormat.Md();
                      } else {
                        format = DateFormat.MMM();
                      }

                      return format.format(DateTime.fromMillisecondsSinceEpoch(value.toInt()));
                    }
                    return '';
                  },
                  color: Style.highlightGold,
                  showDots: true,
                  minX: selectedRange.start.millisecondsSinceEpoch.toDouble(),
                  maxX: selectedRange.end.millisecondsSinceEpoch.toDouble(),
                  minY: 0.0,
                  intervalX: interval * (24.0 * 3600 * 1000),
                )),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: Style.spacingLg),
            //   child: periodHeader,
            // ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: Style.spacingLg),
              itemCount: _titles.length,
              itemBuilder: _buildItems,
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
    final String label = '${value.isNegative ? '-' : '+'}${NumFormat.toPercent(value.abs())}';
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
