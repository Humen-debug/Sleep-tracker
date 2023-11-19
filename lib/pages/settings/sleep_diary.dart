import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/moods/utils.dart';
import 'package:sleep_tracker/components/sleep_phase_block.dart';
import 'package:sleep_tracker/models/sleep_record.dart';
import 'package:sleep_tracker/providers/sleep_records_provider.dart';
import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

@RoutePage()
class SleepDiaryPage extends ConsumerStatefulWidget {
  const SleepDiaryPage({super.key});

  @override
  ConsumerState<SleepDiaryPage> createState() => _SleepDiaryPageState();
}

class _SleepDiaryPageState extends ConsumerState<SleepDiaryPage> {
  final ScrollController _scrollController = ScrollController();
  final int _dayToGenerate = 30 * 3;
  bool _showFab = false;
  final Duration _fabAnimationDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleFabListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleFabListener() {
    final double height = MediaQuery.sizeOf(context).height;
    final double offset = _scrollController.offset;
    if (!_showFab && offset > height) {
      setState(() => _showFab = true);
    } else if (_showFab && offset <= height) {
      setState(() => _showFab = false);
    }
  }

  Widget _buildItems(BuildContext context, int index) {
    final ThemeData themeData = Theme.of(context);

    final DateTime date = DateTime.now().subtract(Duration(days: index));
    final Iterable<SleepRecord> records = ref.watch(daySleepRecordsProvider(date));
    final moods = records.map((record) => record.sleepQuality).whereNotNull();
    final double? moodValue = moods.isNotEmpty ? moods.average : null;
    final List<DateTimeRange> slots = records
        .where((record) => record.wakeUpAt != null)
        .map((record) => DateTimeRange(start: record.start, end: record.wakeUpAt!))
        .toList();

    if (records.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingMd),
      margin: const EdgeInsets.only(bottom: Style.spacingSm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Style.radiusSm),
        gradient: LinearGradient(
          colors: [themeData.colorScheme.tertiary, themeData.colorScheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.MMMMd().format(date),
                      style: themeData.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: Style.spacingXxs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Time asleep', style: themeData.textTheme.bodySmall?.copyWith(color: Style.grey3)),
                            Text('7hr 23min', style: dataTextTheme.bodyMedium)
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Sleep Efficiency',
                              style: themeData.textTheme.bodySmall?.copyWith(color: Style.grey3),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              '97%',
                              style: dataTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              textAlign: TextAlign.end,
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              if (moodValue != null) ...[
                const SizedBox(width: Style.spacingLg),
                Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Style.grey1),
                    child: Center(
                      child: SvgPicture.asset('assets/moods/${valueToMood(moodValue).name}.svg', width: 32, height: 32),
                    ))
              ]
            ],
          ),
          // dev
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Style.spacingLg),
            child: _TimeSlotChart(
              range: DateTimeRange(
                start: (records.first.start),
                end: (records.last.wakeUpAt ?? records.last.end),
              ),
              slots: slots,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SleepPhaseBlock(color: Style.highlightGold, title: 'Awake', desc: '3%'),
              SleepPhaseBlock(color: Theme.of(context).primaryColor, title: 'Sleep', desc: '74%'),
              const SleepPhaseBlock(color: Style.highlightPurple, title: 'Deep Sleep', desc: '23%'),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Diary')),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
        child: AnimatedSlide(
          offset: _showFab ? Offset.zero : const Offset(0, 2),
          duration: _fabAnimationDuration,
          child: FloatingActionButton(
            onPressed: () {
              _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
            },
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Style.radiusSm)),
            child: SvgPicture.asset('assets/icons/to-top.svg',
                color: Theme.of(context).primaryColor, width: 32, height: 32),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // dev list
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(Style.spacingMd),
        controller: _scrollController,
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: _buildItems,
              itemCount: _dayToGenerate,
            ),
            Divider(color: Theme.of(context).colorScheme.tertiary, height: Style.spacingSm * 2),
            Text(
              'You have scrolled to the bottom',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: kBottomNavigationBarHeight),
          ],
        ),
      ),
    );
  }
}

/// [_TimeSlotChart] renders the time slots within the [range] by provided [slots]
///
/// It is assumed that the [range] is only one-day long. Hence the labels of start
/// and end is in the format of Md.
class _TimeSlotChart extends StatelessWidget {
  _TimeSlotChart({required this.range, required this.slots}) {
    assert(slots.isEmpty || !slots.sorted((a, b) => a.start.compareTo(b.start)).last.start.isBefore(range.start),
        'slot must be on or after ${range.start}.');
    assert(slots.isEmpty || !slots.sorted((a, b) => a.end.compareTo(b.end)).last.end.isBefore(range.start),
        'slot must be on or before ${range.end}.');
  }

  /// [range] determines the limits of the chart.
  final DateTimeRange range;

  /// [slots] renders the boxes on chart.
  final List<DateTimeRange> slots;

  double _computeHorizontalPercent(DateTime date) {
    final int milliSecond = date.millisecondsSinceEpoch;
    final int startMilliSecond = range.start.millisecondsSinceEpoch;
    final int endMilliSecond = range.end.millisecondsSinceEpoch;

    if ((endMilliSecond - startMilliSecond) == 0) return 0;
    return (milliSecond - startMilliSecond) / (endMilliSecond - startMilliSecond);
  }

  Widget _buildChart(BuildContext context, BoxConstraints constraints) {
    final BorderRadius borderRadius = BorderRadius.circular(2);
    return Container(
      constraints: constraints.copyWith(minHeight: 8, maxWidth: constraints.maxWidth),
      decoration: BoxDecoration(borderRadius: borderRadius),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // background line
          Container(color: Style.grey3, width: double.infinity, height: 1),
          ...slots.map((slot) {
            final double left = constraints.maxWidth * _computeHorizontalPercent(slot.start);
            final double right = constraints.maxWidth * _computeHorizontalPercent(slot.end);

            return Positioned(
              top: 0,
              bottom: 0,
              left: left,
              width: math.min(right - left, constraints.maxWidth - left),
              child: Container(
                decoration: BoxDecoration(borderRadius: borderRadius, color: Theme.of(context).primaryColor),
              ),
            );
          })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(fontWeight: FontWeight.w300);
    return Row(children: [
      Text(DateFormat.Hm().format(range.start), style: textStyle),
      const SizedBox(width: Style.spacingXs),
      Expanded(child: LayoutBuilder(builder: _buildChart)),
      const SizedBox(width: Style.spacingXs),
      Text(DateFormat.Hm().format(range.end), style: textStyle),
    ]);
  }
}
