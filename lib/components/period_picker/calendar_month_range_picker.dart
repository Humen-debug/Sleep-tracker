import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/sliver.dart';
import 'package:flutter/src/rendering/sliver_grid.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/period_picker/const.dart';
import 'package:sleep_tracker/components/period_picker/utils.dart';
import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

class CalendarMonthRangePicker extends StatefulWidget {
  CalendarMonthRangePicker({
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
  State<CalendarMonthRangePicker> createState() => _CalendarMonthRangePickerState();
}

class _CalendarMonthRangePickerState extends State<CalendarMonthRangePicker> {
  late DateTime? _startDate = widget.selectedStartDate;
  late DateTime? _endDate = widget.selectedEndDate;
  int _initialYearIndex = 0;
  late final ScrollController _controller = ScrollController()..addListener(_scrollListener);
  int get _numberOfYears => widget.lastDate.year - widget.firstDate.year + 1;

  @override
  void initState() {
    super.initState();
    final DateTime initialDate = widget.selectedStartDate ?? widget.currentDate;
    if (!initialDate.isBefore(widget.firstDate) && !initialDate.isAfter(widget.lastDate)) {
      _initialYearIndex = widget.firstDate.year - initialDate.year;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {}

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
        _endDate = date;
        widget.onEndDateChanged?.call(_endDate);
      } else {
        _startDate = date;
        widget.onStartDateChanged?.call(_startDate!);
        if (_endDate != null) {
          _endDate = null;
          widget.onEndDateChanged?.call(_endDate);
        }
      }
    });
  }

  Widget _buildYearItems(BuildContext context, int index, bool beforeInitialYear) {
    final int yearIndex = beforeInitialYear ? _initialYearIndex - index - 1 : _initialYearIndex + index;
    final DateTime year = DateTime(widget.firstDate.year + yearIndex);
    return _YearItem(
      selectedDateStart: _startDate,
      selectedDateEnd: _endDate,
      currentDate: widget.currentDate,
      onChanged: _updateSelection,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedYear: year,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Key sliverAfterKey = Key('sliverAfterKey');
    return Column(
      children: [
        Expanded(
            child: CustomScrollView(
          controller: _controller,
          center: sliverAfterKey,
          slivers: <Widget>[
            SliverList(
                delegate: SliverChildBuilderDelegate(
              (context, index) => _buildYearItems(context, index, true),
              childCount: _initialYearIndex,
            )),
            SliverList(
                key: sliverAfterKey,
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildYearItems(context, index, false),
                  childCount: _numberOfYears - _initialYearIndex,
                )),
          ],
        ))
      ],
    );
  }
}

class _YearItem extends StatefulWidget {
  _YearItem(
      {this.selectedDateStart,
      this.selectedDateEnd,
      required this.currentDate,
      required this.onChanged,
      required this.firstDate,
      required this.lastDate,
      required this.displayedYear})
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
  final DateTime displayedYear;

  @override
  State<_YearItem> createState() => __YearItemState();
}

class __YearItemState extends State<_YearItem> {
  Color _highlightColor(BuildContext context) {
    return DatePickerTheme.of(context).rangeSelectionBackgroundColor ??
        DatePickerTheme.defaults(context).rangeSelectionBackgroundColor!;
  }

  Widget _buildMonthItem(BuildContext context, DateTime monthToBuild) {
    final bool isDisabled = monthToBuild.isAfter(widget.lastDate) || monthToBuild.isBefore(widget.firstDate);

    BoxDecoration? decoration;
    TextStyle? itemStyle = Theme.of(context).textTheme.bodyMedium;

    final bool isRangeSelected = widget.selectedDateStart != null && widget.selectedDateEnd != null;
    final bool isSelectedDayStart =
        widget.selectedDateStart != null && monthToBuild.isAtSameMomentAs(widget.selectedDateStart!);
    final bool isSelectedDayEnd =
        widget.selectedDateEnd != null && monthToBuild.isAtSameMomentAs(widget.selectedDateEnd!);
    final bool isInRange = isRangeSelected &&
        monthToBuild.isAfter(widget.selectedDateStart!) &&
        monthToBuild.isBefore(widget.selectedDateEnd!);

    final Set<MaterialState> states = <MaterialState>{
      if (isDisabled) MaterialState.disabled,
      if (isSelectedDayStart || isSelectedDayEnd) MaterialState.selected,
    };
    final Color highlightColor = _highlightColor(context);
    HighlightPainter? highlightPainter;

    if (isSelectedDayStart || isSelectedDayEnd) {
      itemStyle = itemStyle?.copyWith(color: Theme.of(context).colorScheme.background);
      decoration = BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(Style.radiusXl),
      );
      if (isRangeSelected && widget.selectedDateStart != widget.selectedDateEnd) {
        final HighlightPainterStyle style =
            isSelectedDayStart ? HighlightPainterStyle.highlightTrailing : HighlightPainterStyle.highlightLeading;
        highlightPainter = HighlightPainter(
          color: highlightColor,
          style: style,
        );
      }
    } else if (isInRange) {
      highlightPainter = HighlightPainter(
        color: highlightColor,
        style: HighlightPainterStyle.highlightAll,
      );
    } else if (isDisabled) {
      itemStyle = itemStyle?.copyWith(color: Style.grey3);
    } else if (DateUtils.isSameMonth(widget.currentDate, monthToBuild)) {
      itemStyle = itemStyle?.copyWith(color: Theme.of(context).colorScheme.primary);
      decoration = BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(Style.radiusXl),
      );
    }
    String monthText = DateFormat.MMM().format(monthToBuild);
    Widget monthWidget = Container(
      decoration: decoration,
      child: Center(child: Text(monthText, style: itemStyle)),
    );
    if (highlightPainter != null) {
      monthWidget = CustomPaint(
        painter: highlightPainter,
        child: monthWidget,
      );
    }

    if (!isDisabled) {
      monthWidget = InkResponse(
        onTap: () => widget.onChanged(monthToBuild),
        radius: monthPickerRowHeight / 2 + 4,
        statesController: MaterialStatesController(states),
        child: monthWidget,
      );
    }
    return monthWidget;
  }

  @override
  Widget build(BuildContext context) {
    final int year = widget.displayedYear.year;
    // final int month = widget.displayedYear.month;
    const months = (DateTime.monthsPerYear / monthPickerColumnCount);
    const double gridHeight = months * monthPickerRowHeight + (months - 1) * monthItemSpacingBetweenRows;
    final List<Widget> monthItems =
        List.generate(DateTime.monthsPerYear, (month) => _buildMonthItem(context, DateTime(year, month, 1)));

    // Add the leading/trailing edge containers to each week in order to
    // correctly extend the range highlight.
    final List<Widget> paddedDayItems = <Widget>[];
    for (int i = 0; i < months; i++) {
      final int start = i * monthPickerColumnCount;
      final int end = math.min(start + monthPickerColumnCount, monthItems.length);

      final List<Widget> monthList = monthItems.sublist(start, end);

      paddedDayItems.addAll(monthList);
    }
    return Column(
      children: [
        Container(
          height: monthPickerRowHeight,
          padding: const EdgeInsets.symmetric(horizontal: Style.spacingMd),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            widget.displayedYear.year.toString(),
            style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: gridHeight),
          child: GridView.custom(
            gridDelegate: _yearItemGridDelegate,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childrenDelegate: SliverChildListDelegate(monthItems, addRepaintBoundaries: false),
          ),
        ),
      ],
    );
  }
}

class _YearItemGridDelegate extends SliverGridDelegate {
  const _YearItemGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = monthPickerColumnCount;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(monthPickerRowHeight, constraints.viewportMainAxisExtent / (columnCount));
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

const _yearItemGridDelegate = _YearItemGridDelegate();
