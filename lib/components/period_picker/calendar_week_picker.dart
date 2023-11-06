import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/period_picker/const.dart';
import 'package:sleep_tracker/utils/date_time.dart';
import 'package:sleep_tracker/utils/style.dart';

/// Displays a grid of days for a given month and a column of corresponding week number of
/// the user to select a week number.
///
/// Days are arranged in a rectangular grid with one column for each day of the
/// week. Controls are provided to change the year and month that the grid is
/// showing.
///
class CalendarWeekPicker extends StatefulWidget {
  CalendarWeekPicker({
    super.key,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    required this.onDateChanged,
    this.onDisplayedMonthChanged,
  })  : initialDate = DateUtils.dateOnly(initialDate),
        firstDate = DateUtils.dateOnly(firstDate),
        lastDate = DateUtils.dateOnly(lastDate),
        currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now()) {
    assert(
      !this.lastDate.isBefore(this.firstDate),
      'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
      !this.initialDate.isBefore(this.firstDate),
      'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
      !this.initialDate.isAfter(this.lastDate),
      'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.',
    );
  }

  /// The initially selected [DateTime] that the picker should display.
  final DateTime initialDate;

  /// The earliest allowable [DateTime] that the user can select.
  final DateTime firstDate;

  /// The latest allowable [DateTime] that the user can select.
  final DateTime lastDate;

  /// The [DateTime] representing today. It will be highlighted in the day grid.
  final DateTime currentDate;

  /// Called when the user selects a date in the picker.
  final ValueChanged<DateTime> onDateChanged;

  /// Called when the user navigates to a new month/year in the picker.
  final ValueChanged<DateTime>? onDisplayedMonthChanged;

  @override
  State<CalendarWeekPicker> createState() => _CalendarWeekPickerState();
}

class _CalendarWeekPickerState extends State<CalendarWeekPicker> {
  late DateTime _selectedDate = widget.initialDate;

  void _handleDateChanged(DateTime value) {
    setState(() {
      _selectedDate = value;
      widget.onDateChanged(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _MonthPicker(
      initialMonth: _selectedDate,
      currentDate: widget.currentDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      selectedDate: _selectedDate,
      onChanged: _handleDateChanged,
    );
  }
}

class _MonthPicker extends StatefulWidget {
  /// Creates a month picker.
  _MonthPicker({
    required this.initialMonth,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(!selectedDate.isBefore(firstDate)),
        assert(!selectedDate.isAfter(lastDate));

  /// The initial month to display.
  final DateTime initialMonth;

  /// The current date.
  ///
  /// This date is subtly highlighted in the picker.
  final DateTime currentDate;

  /// The earliest date the user is permitted to pick.
  ///
  /// This date must be on or before the [lastDate].
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  ///
  /// This date must be on or after the [firstDate].
  final DateTime lastDate;

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  @override
  State<_MonthPicker> createState() => __MonthPickerState();
}

const Duration _monthScrollDuration = Duration(milliseconds: 200);

class __MonthPickerState extends State<_MonthPicker> {
  late DateTime _currentMonth = widget.initialMonth;
  late final PageController _pageController =
      PageController(initialPage: DateUtils.monthDelta(widget.firstDate, _currentMonth));

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleDateSelected(DateTime selectedDate) {
    _currentMonth = selectedDate;
    widget.onChanged(selectedDate);
  }

  /// True if the earliest allowable month is displayed.
  bool get _isDisplayingFirstMonth {
    return !_currentMonth.isAfter(
      DateTime(widget.firstDate.year, widget.firstDate.month),
    );
  }

  /// True if the latest allowable month is displayed.
  bool get _isDisplayingLastMonth {
    return !_currentMonth.isBefore(
      DateTime(widget.lastDate.year, widget.lastDate.month),
    );
  }

  void _handleMonthPageChanged(int monthPage) {
    final DateTime monthDate = DateUtils.addMonthsToMonthDate(widget.firstDate, monthPage);
    if (!DateUtils.isSameMonth(_currentMonth, monthDate)) {
      setState(() {
        _currentMonth = DateTime(monthDate.year, monthDate.month);
      });
    }
  }

  /// Navigate to the next month.
  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      _pageController.nextPage(
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  /// Navigate to the previous month.
  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      _pageController.previousPage(
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime month = DateUtils.addMonthsToMonthDate(widget.firstDate, index);
    return _WeekPicker(
      key: ValueKey<DateTime>(month),
      selectedDate: widget.selectedDate,
      currentDate: widget.currentDate,
      onChanged: _handleDateSelected,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: Style.spacingMd),
              child: Text(DateFormat.yMMM().format(_currentMonth), style: Theme.of(context).textTheme.bodySmall),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _handlePreviousMonth,
              child: Padding(
                padding: const EdgeInsets.all(Style.spacingXs),
                child: SvgPicture.asset('assets/icons/chevron-left.svg',
                    color: !_isDisplayingFirstMonth ? Style.grey1 : Style.grey3),
              ),
            ),
            GestureDetector(
              onTap: _handleNextMonth,
              child: Padding(
                padding: const EdgeInsets.all(Style.spacingXs),
                child: SvgPicture.asset('assets/icons/chevron-right.svg',
                    color: !_isDisplayingLastMonth ? Style.grey1 : Style.grey3),
              ),
            )
          ],
        ),
        Expanded(
            child: PageView.builder(
          controller: _pageController,
          itemBuilder: _buildItems,
          itemCount: DateUtils.monthDelta(widget.firstDate, widget.lastDate) + 1,
          onPageChanged: _handleMonthPageChanged,
        ))
      ],
    );
  }
}

class _WeekPicker extends StatefulWidget {
  _WeekPicker({
    super.key,
    required this.currentDate,
    required this.displayedMonth,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(!selectedDate.isBefore(firstDate)),
        assert(!selectedDate.isAfter(lastDate));

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  ///
  /// This date must be on or before the [lastDate].
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  ///
  /// This date must be on or after the [firstDate].
  final DateTime lastDate;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  @override
  State<_WeekPicker> createState() => __WeekPickerState();
}

class __WeekPickerState extends State<_WeekPicker> {
  /// Build widgets showing abbreviated days of week.
  ///
  /// Returns:
  ///
  ///   W Su Mo Tu We Th Fr Sa
  List<Widget> _dayHeaders() {
    final headerStyle = Theme.of(context).textTheme.bodySmall;
    final List<Widget> result = <Widget>[
      Center(
        child: Text('W', style: headerStyle),
      )
    ];
    for (int i = 0; i < DateTime.daysPerWeek; i++) {
      final String weekday = weekdaysNames[i];
      result.add(Center(child: Text(weekday, style: headerStyle)));
    }
    return result;
  }

  Color _highlightColor(BuildContext context) {
    return DatePickerTheme.of(context).rangeSelectionBackgroundColor ??
        DatePickerTheme.defaults(context).rangeSelectionBackgroundColor!;
  }

  Widget _buildDayItem(
      BuildContext context, DateTime dayToBuild, int dayOffset, DateTime firstDateInMonth, bool withinThisMonth) {
    final bool isInRange = DateTimeUtils.isSameWeek(widget.selectedDate, dayToBuild);
    final bool isDisabled = dayToBuild.isAfter(widget.lastDate) ||
        dayToBuild.isBefore(widget.firstDate) ||
        !DateUtils.isSameMonth(firstDateInMonth, dayToBuild);
    final bool isToday = DateUtils.isSameDay(widget.currentDate, dayToBuild);
    final Set<MaterialState> states = <MaterialState>{
      if (isDisabled) MaterialState.disabled,
      if (isInRange) MaterialState.selected,
    };
    final Color highlightColor = _highlightColor(context);
    final decoration = BoxDecoration(
      borderRadius: !isInRange ? BorderRadius.circular(Style.radiusXs) : null,
      border: states.contains(MaterialState.selected) || !isToday
          ? null
          : Border.all(color: Theme.of(context).primaryColor),
      color: states.contains(MaterialState.selected) ? highlightColor : null,
    );

    Color? dayForegroundColor;
    if (withinThisMonth) {
      // Build days that is in pre-month.
      dayForegroundColor = states.contains(MaterialState.selected)
          ? null
          : isToday
              ? Theme.of(context).primaryColor
              : Style.grey3;
    } else {
      // Build default day
      dayForegroundColor = states.contains(MaterialState.selected)
          ? null
          : isToday
              ? Theme.of(context).primaryColor
              : isDisabled
                  ? Style.grey3
                  : null;
    }

    // Build the day that is not in this month.
    Widget dayWidget = Container(
        decoration: decoration,
        child: Center(child: Text(DateFormat("d").format(dayToBuild), style: TextStyle(color: dayForegroundColor))));
    if (!isDisabled) {
      // Returns the most recent sunday as the start of week.
      dayWidget = InkResponse(
        onTap: () => widget.onChanged(DateTimeUtils.mostRecentWeekday(dayToBuild, 0)),
        statesController: MaterialStatesController(states),
        radius: dayPickerRowHeight / 2 + 4,
        child: dayWidget,
      );
    }
    return dayWidget;
  }

  @override
  Widget build(BuildContext context) {
    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;
    final DateTime firstDateInMonth = DateTime(year, month);

    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final int dayOffset = DateTimeUtils.firstDayOffset(year, month);
    final int dayRemains = DateTimeUtils.lastDayOffset(year, month);

    final int weeksInMonth = ((daysInMonth + dayOffset) ~/ DateTime.daysPerWeek).ceil();

    final List<Widget> dayItems = _dayHeaders();

    // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
    // a leap year.
    int day = -dayOffset;
    while (day < daysInMonth + dayRemains) {
      day++;
      final DateTime dayToBuild = DateTime(year, month, day);
      Widget dayWidget = _buildDayItem(context, dayToBuild, dayOffset, firstDateInMonth, day < 1);
      dayItems.add(dayWidget);
    }

    // Insert week widget. Plus one to skip the dayHeader's row.
    // Build the week number for beginning(leftmost) of every week.
    // since the grid is not start with 0-based day, recompute grid index(day) to
    // be 0-based, in order to set week number cell to be the leftmost.
    for (int i = 1; i <= weeksInMonth + 1; i++) {
      final index = i * (DateTime.daysPerWeek + 1);
      // Recomputed to 0-based indexed.
      final DateTime dayToBuild = DateTime(year, month, (i - 1) * DateTime.daysPerWeek - dayOffset + 1);

      final bool isSelectedWeek = DateTimeUtils.isSameWeek(widget.selectedDate, dayToBuild);
      final bool isDisabled = dayToBuild.isAfter(widget.lastDate) ||
          dayToBuild.isBefore(widget.firstDate) ||
          !DateUtils.isSameMonth(firstDateInMonth, dayToBuild);
      final Set<MaterialState> states = <MaterialState>{
        if (isDisabled) MaterialState.disabled,
        if (isSelectedWeek) MaterialState.selected,
      };
      final Color dayForegroundColor = isSelectedWeek
          ? Theme.of(context).colorScheme.background
          : isDisabled
              ? Style.grey3
              : Theme.of(context).primaryColor;
      final decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(Style.radiusXs),
        color: states.contains(MaterialState.selected) ? Theme.of(context).primaryColor : null,
      );

      // Back to 1-based by plus 1.
      final weekNumber = DateTimeUtils.weekNumbers(dayToBuild);

      Widget weekWidget = Container(
        decoration: decoration,
        child: Center(
          child: Text(weekNumber.toString(), style: TextStyle(color: dayForegroundColor, fontWeight: FontWeight.w500)),
        ),
      );
      if (!isDisabled) {
        weekWidget = InkResponse(
            onTap: () => widget.onChanged(dayToBuild),
            statesController: MaterialStatesController(states),
            radius: dayPickerRowHeight / 2 + 4,
            child: weekWidget);
      }
      if (index < dayItems.length) dayItems.insert(index, weekWidget);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: monthPickerHorizontalPadding),
      child: GridView.custom(
          gridDelegate: _weekPickerGridDelegate,
          childrenDelegate: SliverChildListDelegate(dayItems, addRepaintBoundaries: false)),
    );
  }
}

class _WeekPickerGridDelegate extends SliverGridDelegate {
  const _WeekPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek + 1;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(
      dayPickerRowHeight,
      constraints.viewportMainAxisExtent / (maxDayPickerRowCount + 1),
    );
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: tileHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_WeekPickerGridDelegate oldDelegate) => false;
}

const _WeekPickerGridDelegate _weekPickerGridDelegate = _WeekPickerGridDelegate();
