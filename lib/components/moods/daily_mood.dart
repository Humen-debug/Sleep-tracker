import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/moods/utils.dart';
import 'package:sleep_tracker/components/period_picker/period_picker.dart';
import 'package:sleep_tracker/utils/style.dart';

const double _moodBoardCrossAxisSpacing = Style.spacingXs;
const double _moodBoardMainAxisSpacing = Style.spacingXs;
const int _moodBoardColumnCount = DateTime.daysPerWeek;
const Duration _monthScrollDuration = Duration(milliseconds: 200);

class DailyMood extends StatefulWidget {
  const DailyMood({super.key});

  @override
  State<DailyMood> createState() => _DailyMoodState();
}

class _DailyMoodState extends State<DailyMood> {
  final DateTime _now = DateTime.now();
  // dev use
  late final DateTime firstDate = DateUtils.dateOnly(_now.subtract(const Duration(days: 365)).copyWith(day: 1));
  late int monthToGenerate = DateUtils.monthDelta(firstDate, _now) + 1;
  late final List<List<double?>> data = List.generate(monthToGenerate, (index) {
    int currentMonth = _now.month;
    int month = (currentMonth - index > 0) ? currentMonth - index : index % monthToGenerate;
    int year = currentMonth - index <= 0 ? _now.year - 1 : _now.year;
    return List.generate(
      DateUtils.getDaysInMonth(year, month),
      (day) => (index > 0) || day + 1 <= _now.day ? Random().nextDouble() : null,
    );
  }).reversed.toList();

  DateTime _currentMonth = DateUtils.dateOnly(DateTime.now()).copyWith(day: 1);

  late final PageController _pageController =
      PageController(initialPage: DateUtils.monthDelta(firstDate, _currentMonth));

  int get average {
    int index = DateUtils.monthDelta(firstDate, _currentMonth);

    return (data[index].whereNotNull().average * 100).round();
  }

  bool get _isDisplayingFirstMonth => !_currentMonth.isAfter(DateTime(firstDate.year, firstDate.month));
  bool get _isDisplayingLastMonth => !_currentMonth.isBefore(DateTime(_now.year, _now.month));

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      _pageController.previousPage(duration: _monthScrollDuration, curve: Curves.ease);
      setState(() {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      });
    }
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      _pageController.nextPage(duration: _monthScrollDuration, curve: Curves.ease);
      setState(() {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      });
    }
  }

  void _handleMonthPageChanged(int monthPage) {
    final DateTime monthDate = DateUtils.addMonthsToMonthDate(firstDate, monthPage);
    if (!DateUtils.isSameMonth(_currentMonth, monthDate)) {
      setState(() {
        _currentMonth = DateTime(monthDate.year, monthDate.month);
      });
    }
  }

  void _handleMonthChanged(DateTime? monthDate) {
    if (monthDate == null) return;
    if (!DateUtils.isSameMonth(_currentMonth, monthDate)) {
      int index = DateUtils.monthDelta(firstDate, monthDate);
      _pageController.jumpToPage(index);
      setState(() {
        _currentMonth = DateTime(monthDate.year, monthDate.month);
      });
    }
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime month = DateUtils.addMonthsToMonthDate(firstDate, index);
    return _MoodBoard(
      key: ValueKey<DateTime>(month),
      data: data[index],
      displayedMonth: month,
    );
  }

  Size _boardSize(BuildContext context) {
    final double width = MediaQuery.of(context).size.shortestSide;
    final double gridCellSize = width / _moodBoardColumnCount;
    final double height =
        (DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month).toDouble() / _moodBoardColumnCount).ceil() *
            gridCellSize;
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Style.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Mood',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _handlePreviousMonth,
                    child: SvgPicture.asset('assets/icons/chevron-left.svg',
                        color: _isDisplayingFirstMonth ? Style.grey3 : Style.grey1),
                  ),
                  PeriodPicker(
                    maxWidth: 100,
                    mode: PeriodPickerMode.months,
                    selectedDate: _currentMonth,
                    firstDate: firstDate,
                    lastDate: _now,
                    onDateChanged: _handleMonthChanged,
                  ),
                  GestureDetector(
                    onTap: _handleNextMonth,
                    child: SvgPicture.asset('assets/icons/chevron-right.svg',
                        color: _isDisplayingLastMonth ? Style.grey3 : Style.grey1),
                  ),
                ],
              )
            ],
          ),
          // Board

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _boardSize(context).width,
            height: _boardSize(context).height,
            curve: Curves.easeIn,
            child: PageView.builder(
              controller: _pageController,
              itemCount: monthToGenerate,
              itemBuilder: _buildItems,
              onPageChanged: _handleMonthPageChanged,
            ),
          ),
          // daily average
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Average',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Style.grey3),
              ),
              Text('$average%', style: Theme.of(context).textTheme.headlineSmall)
            ],
          )
        ],
      ),
    );
  }
}

class _MoodBoard extends StatefulWidget {
  const _MoodBoard({Key? key, required this.data, required this.displayedMonth}) : super(key: key);
  final List<double?> data;
  final DateTime displayedMonth;

  @override
  State<_MoodBoard> createState() => __MoodBoardState();
}

class __MoodBoardState extends State<_MoodBoard> {
  int? _activeIndex;

  String? get label {
    if (_activeIndex != null) {
      String date = DateFormat.MMMd().format(widget.displayedMonth.copyWith(day: _activeIndex! + 1));
      int value = ((widget.data[_activeIndex!] ?? 0) * 100).round();
      return '$date, $value%';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double gridWidth = MediaQuery.of(context).size.shortestSide;
    double gridCellSize = (gridWidth) / _moodBoardColumnCount;

    Widget valueIndicator() {
      final int column = _activeIndex!.remainder(_moodBoardColumnCount);
      final int row = _activeIndex! ~/ _moodBoardColumnCount;
      // if selected cell is in the left most two columns, move the indicator to the left.
      final double left =
          (column * gridCellSize) + (column >= _moodBoardColumnCount - 2 ? (-2 * gridCellSize) : gridCellSize / 2);
      // if selected cell is in the top row, move the indicator to the bottom
      final double top = row * gridCellSize + (row > 0 ? -gridCellSize / 4 : gridCellSize);

      return AnimatedPositioned(
          top: top,
          left: left,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Style.spacingSm, vertical: Style.radiusXs),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(Style.radiusXs),
              boxShadow: const [BoxShadow(offset: Offset(0, 4), color: Colors.black38, blurRadius: 8)],
            ),
            child: Text(label!),
          ));
    }

    return Container(
      constraints: BoxConstraints(maxWidth: gridWidth),
      child: GestureDetector(
        onLongPressMoveUpdate: (details) {
          int row = (details.localPosition.dy / gridCellSize).floor();
          int col = (details.localPosition.dx / gridCellSize).floor();
          int index = col + row * 7;
          int lastDay = DateUtils.isSameMonth(DateTime.now(), widget.displayedMonth)
              ? DateTime.now().day
              : DateUtils.getDaysInMonth(widget.displayedMonth.year, widget.displayedMonth.month);

          if (index != _activeIndex && index + 1 <= lastDay) setState(() => _activeIndex = index);
        },
        child: Stack(
          children: [
            GridView.count(
              crossAxisCount: _moodBoardColumnCount,
              shrinkWrap: true,
              crossAxisSpacing: _moodBoardCrossAxisSpacing,
              mainAxisSpacing: _moodBoardMainAxisSpacing,
              padding: const EdgeInsets.symmetric(vertical: Style.spacingMd),
              physics: const NeverScrollableScrollPhysics(),
              children: widget.data
                  .mapIndexed((index, v) => v != null
                      ? GestureDetector(
                          onTap: () {
                            if (_activeIndex != index) setState(() => _activeIndex = index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _activeIndex == index ? Style.grey1 : Style.highlightDarkPurple.withOpacity(0.15)),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              child: SvgPicture.asset(
                                'assets/moods/${valueToMood(v).name}${_activeIndex == index ? '' : '-outline'}.svg',
                                // if awful mood, the color is too deep for showing
                                color: valueToMood(v) == Mood.awful && _activeIndex != index
                                    ? Style.highlightPurple
                                    : null,
                              ),
                            ),
                          ))
                      : Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Style.grey3)),
                        ))
                  .toList(),
            ),
            // value indicator
            if (_activeIndex != null) valueIndicator(),
          ],
        ),
      ),
    );
  }
}
