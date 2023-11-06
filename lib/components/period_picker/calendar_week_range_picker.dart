import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/sliver.dart';
import 'package:flutter/src/rendering/sliver_grid.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/period_picker/const.dart';
import 'package:sleep_tracker/utils/date_time.dart';
import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

class CalendarWeekRangePicker extends StatefulWidget {
  CalendarWeekRangePicker({
    super.key,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  })  : selectedStartDate = selectedStartDate != null ? DateUtils.dateOnly(selectedStartDate) : null,
        selectedEndDate = selectedEndDate != null ? DateUtils.dateOnly(selectedEndDate) : null,
        firstDate = DateUtils.dateOnly(firstDate),
        lastDate = DateUtils.dateOnly(lastDate),
        currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now()) {
    assert(
      this.selectedStartDate == null ||
          this.selectedEndDate == null ||
          !this.selectedStartDate!.isAfter(selectedEndDate!),
      'selectedStartDate must be on or before selectedEndDate.',
    );
    assert(
      !this.lastDate.isBefore(this.firstDate),
      'firstDate must be on or before lastDate.',
    );
  }
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime currentDate;
  final void Function(DateTime? value)? onStartDateChanged;
  final void Function(DateTime? value)? onEndDateChanged;

  @override
  State<CalendarWeekRangePicker> createState() => _CalendarWeekRangePickerState();
}

class _CalendarWeekRangePickerState extends State<CalendarWeekRangePicker> {
  late DateTime? _startDate = widget.selectedStartDate;
  late DateTime? _endDate = widget.selectedEndDate;
  int _initialMonthIndex = 0;
  late final ScrollController _controller;
  int get _numberOfMonths => DateUtils.monthDelta(widget.firstDate, widget.lastDate) + 1;
  late bool _showWeekBottomDivider;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_scrollListener);
    final DateTime initialDate = widget.selectedStartDate ?? widget.currentDate;
    if (!initialDate.isBefore(widget.firstDate) && !initialDate.isAfter(widget.lastDate)) {
      _initialMonthIndex = DateUtils.monthDelta(widget.firstDate, initialDate);
    }
    _showWeekBottomDivider = _initialMonthIndex != 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_controller.offset <= _controller.position.minScrollExtent) {
      setState(() {
        _showWeekBottomDivider = false;
      });
    } else if (!_showWeekBottomDivider) {
      setState(() {
        _showWeekBottomDivider = true;
      });
    }
  }

  // This updates the selected date range using this logic:
  //
  // * From the unselected state, selecting one date creates the start date.
  //   * If the next selection is before the start date, reset date range and
  //     set the start date to that selection.
  //   * If the next selection is on or after the start date, set the end date
  //     to that selection.
  // * After both start and end dates are selected, any subsequent selection
  //   resets the date range and sets start date to that selection.
  void _updateSelection(DateTime date) {
    setState(() {
      if (_startDate != null && _endDate == null && !date.isBefore(_startDate!)) {
        _endDate = DateTimeUtils.mostNearestWeekday(date, 6);
        widget.onEndDateChanged?.call(_endDate);
      } else {
        _startDate = DateTimeUtils.mostRecentWeekday(date, 0);
        widget.onStartDateChanged?.call(_startDate!);
        if (_endDate != null) {
          _endDate = null;
          widget.onEndDateChanged?.call(_endDate);
        }
      }
    });
  }

  Widget _dayHeader() {
    /// Build widgets showing abbreviated days of week.
    ///
    /// Returns:
    ///
    ///   W Su Mo Tu We Th Fr Sa
    List<Widget> dayHeaders() {
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

    final List<Widget> labels = dayHeaders();

    return Container(
      constraints: const BoxConstraints(minHeight: dayPickerRowHeight),
      child: GridView.custom(
          shrinkWrap: true,
          gridDelegate: _monthItemGridDelegate,
          childrenDelegate: SliverChildListDelegate(
            labels,
            addRepaintBoundaries: false,
          )),
    );
  }

  Widget _buildMonthItem(BuildContext context, int index, bool beforeInitialMonth) {
    final int monthIndex = beforeInitialMonth ? _initialMonthIndex - index - 1 : _initialMonthIndex + index;
    final DateTime month = DateUtils.addMonthsToMonthDate(widget.firstDate, monthIndex);

    return _MonthItem(
      selectedDateStart: _startDate,
      selectedDateEnd: _endDate,
      currentDate: widget.currentDate,
      onChanged: _updateSelection,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Key sliverAfterKey = Key('sliverAfterKey');
    return Column(
      children: [
        _dayHeader(),
        if (_showWeekBottomDivider) const Divider(height: 0),
        Expanded(
            child: CustomScrollView(
          controller: _controller,
          center: sliverAfterKey,
          slivers: <Widget>[
            SliverList(
                delegate: SliverChildBuilderDelegate(
              (context, index) => _buildMonthItem(context, index, true),
              childCount: _initialMonthIndex,
            )),
            SliverList(
                key: sliverAfterKey,
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildMonthItem(context, index, false),
                  childCount: _numberOfMonths - _initialMonthIndex,
                )),
          ],
        ))
      ],
    );
  }
}

class _MonthItem extends StatefulWidget {
  _MonthItem(
      {this.selectedDateStart,
      this.selectedDateEnd,
      required this.currentDate,
      required this.onChanged,
      required this.firstDate,
      required this.lastDate,
      required this.displayedMonth})
      : assert(!firstDate.isAfter(lastDate)),
        assert(selectedDateStart == null || !selectedDateStart.isBefore(firstDate)),
        assert(selectedDateEnd == null || !selectedDateEnd.isBefore(firstDate)),
        assert(selectedDateStart == null || !selectedDateStart.isAfter(lastDate)),
        assert(selectedDateEnd == null || !selectedDateEnd.isAfter(lastDate)),
        assert(selectedDateStart == null || selectedDateEnd == null || !selectedDateStart.isAfter(selectedDateEnd));

  /// The currently selected start date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDateStart;

  /// The currently selected end date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDateEnd;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The year whose months are displayed by this picker.
  final DateTime displayedMonth;

  @override
  State<_MonthItem> createState() => __MonthItemState();
}

class __MonthItemState extends State<_MonthItem> {
  Color _highlightColor(BuildContext context) {
    return DatePickerTheme.of(context).rangeSelectionBackgroundColor ??
        DatePickerTheme.defaults(context).rangeSelectionBackgroundColor!;
  }

  Widget _buildDayItem(BuildContext context, DateTime dayToBuild, int dayOffset) {
    final bool isDisabled = dayToBuild.isAfter(widget.lastDate) || dayToBuild.isBefore(widget.firstDate);
    BoxDecoration? decoration;
    TextStyle? itemStyle = Theme.of(context).textTheme.bodyMedium;

    final bool isRangeSelected = widget.selectedDateStart != null && widget.selectedDateEnd != null;

    final bool isInRange = isRangeSelected &&
        !dayToBuild.isBefore(widget.selectedDateStart!) &&
        !dayToBuild.isAfter(widget.selectedDateEnd!);

    final Set<MaterialState> states = <MaterialState>{
      if (isDisabled) MaterialState.disabled,
      if (isInRange) MaterialState.selected,
    };
    final Color highlightColor = _highlightColor(context);

    if (isInRange) {
      decoration = BoxDecoration(color: highlightColor);
    } else if (isDisabled) {
      itemStyle = itemStyle?.copyWith(color: Style.grey3);
    } else if (DateUtils.isSameDay(widget.currentDate, dayToBuild)) {
      itemStyle = itemStyle?.copyWith(color: Theme.of(context).colorScheme.primary);
      decoration = BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        shape: BoxShape.circle,
      );
    }
    String dayText = DateFormat.d().format(dayToBuild);
    Widget dayWidget = Container(
      decoration: decoration,
      child: Center(child: Text(dayText, style: itemStyle)),
    );

    if (!isDisabled) {
      dayWidget = InkResponse(
        onTap: () => widget.onChanged(dayToBuild),
        radius: dayPickerRowHeight / 2 + 4,
        statesController: MaterialStatesController(states),
        child: dayWidget,
      );
    }
    return dayWidget;
  }

  Widget _buildWeekItem(BuildContext context, DateTime dayToBuild, int dayOffset) {
    final bool isDisabled = dayToBuild.isAfter(widget.lastDate) || dayToBuild.isBefore(widget.firstDate);
    BoxDecoration? decoration;
    TextStyle? itemStyle = Theme.of(context).textTheme.bodyMedium;

    final bool isRangeSelected = widget.selectedDateStart != null && widget.selectedDateEnd != null;
    final bool isSelectedDayStart =
        widget.selectedDateStart != null && DateTimeUtils.isSameWeek(dayToBuild, widget.selectedDateStart!);
    final bool isSelectedDayEnd =
        widget.selectedDateEnd != null && DateTimeUtils.isSameWeek(dayToBuild, widget.selectedDateEnd!);
    final bool isInRange = isRangeSelected &&
        dayToBuild.isAfter(widget.selectedDateStart!) &&
        dayToBuild.isBefore(widget.selectedDateEnd!);

    final Set<MaterialState> states = <MaterialState>{
      if (isDisabled) MaterialState.disabled,
      if (isSelectedDayStart || isSelectedDayEnd) MaterialState.selected,
    };

    if (isSelectedDayStart || isSelectedDayEnd) {
      decoration = BoxDecoration(color: Theme.of(context).colorScheme.primary);
      itemStyle = itemStyle?.copyWith(color: Theme.of(context).colorScheme.background);
    } else if (isInRange) {
      decoration = BoxDecoration(color: Theme.of(context).colorScheme.secondary);
    } else if (isDisabled) {
      itemStyle = itemStyle?.copyWith(color: Style.grey3);
    }
    String weekText = DateTimeUtils.weekNumbers(dayToBuild).toString();
    Widget weekWidget = Container(
      decoration: decoration,
      child: Center(child: Text(weekText, style: itemStyle)),
    );

    if (!isDisabled) {
      weekWidget = InkResponse(
        onTap: () => widget.onChanged(dayToBuild),
        radius: dayPickerRowHeight / 2 + 4,
        statesController: MaterialStatesController(states),
        child: weekWidget,
      );
    }
    return weekWidget;
  }

  @override
  Widget build(BuildContext context) {
    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;

    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final int dayOffset = DateTimeUtils.firstDayOffset(year, month);

    final int weeks = ((daysInMonth + dayOffset) / DateTime.daysPerWeek).ceil();

    double gridHeight = weeks * dayPickerRowHeight + (weeks - 1) * monthItemSpacingBetweenRows;
    final List<Widget> dayItems = <Widget>[];

    for (int i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final int day = i - dayOffset + 1;
      if (day > daysInMonth) {
        break;
      }
      if (day < 1) {
        dayItems.add(Container());
      } else {
        final DateTime dayToBuild = DateTime(year, month, day);
        final Widget dayItem = _buildDayItem(
          context,
          dayToBuild,
          dayOffset,
        );
        dayItems.add(dayItem);
      }
    }

    for (int i = 0; i < weeks; i++) {
      final index = i * (DateTime.daysPerWeek + 1);
      final DateTime dayToBuild = DateTime(year, month, i * DateTime.daysPerWeek - dayOffset + 1);
      if (index < dayItems.length) dayItems.insert(index, _buildWeekItem(context, dayToBuild, dayOffset));
    }
    return Column(
      children: [
        Container(
          height: dayPickerRowHeight,
          padding: const EdgeInsets.symmetric(horizontal: Style.spacingMd),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            DateFormat.yMMM().format(widget.displayedMonth),
            style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: gridHeight),
          child: GridView.custom(
            gridDelegate: _monthItemGridDelegate,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childrenDelegate: SliverChildListDelegate(dayItems, addRepaintBoundaries: false),
          ),
        ),
      ],
    );
  }
}

class _MonthItemGridDelegate extends SliverGridDelegate {
  const _MonthItemGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek + 1;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(dayPickerRowHeight, constraints.viewportMainAxisExtent / (columnCount));
    return SliverGridRegularTileLayout(
        crossAxisCount: columnCount,
        mainAxisStride: tileHeight,
        crossAxisStride: tileWidth,
        childMainAxisExtent: tileHeight,
        childCrossAxisExtent: tileWidth,
        reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection));
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) => false;
}

const _monthItemGridDelegate = _MonthItemGridDelegate();
