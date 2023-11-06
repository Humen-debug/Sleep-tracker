import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/period_picker/const.dart';
import 'package:sleep_tracker/utils/style.dart';

class _MonthPickerHeader extends StatelessWidget {
  const _MonthPickerHeader(
      {required this.titleText,
      required this.handlePrevious,
      required this.handleNext,
      required this.hasNext,
      required this.hasPrevious});
  final String titleText;
  final void Function() handlePrevious;
  final void Function() handleNext;
  final bool hasNext;
  final bool hasPrevious;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Style.spacingMd),
          child: Text(titleText, style: Theme.of(context).textTheme.bodySmall),
        ),
        const Spacer(),
        GestureDetector(
          onTap: handlePrevious,
          child: Padding(
            padding: const EdgeInsets.all(Style.spacingXs),
            child: SvgPicture.asset('assets/icons/chevron-left.svg', color: hasPrevious ? Style.grey1 : Style.grey3),
          ),
        ),
        GestureDetector(
          onTap: handleNext,
          child: Padding(
            padding: const EdgeInsets.all(Style.spacingXs),
            child: SvgPicture.asset('assets/icons/chevron-right.svg', color: hasNext ? Style.grey1 : Style.grey3),
          ),
        ),
      ],
    );
  }
}

class CalendarMonthPicker extends StatefulWidget {
  const CalendarMonthPicker({
    super.key,
    required this.initialMonth,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    required this.selectedDate,
    this.scrollDirection = Axis.vertical,
  });

  final DateTime initialMonth;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selectedDate;
  final void Function(DateTime value) onChanged;
  final Axis scrollDirection;

  @override
  State<CalendarMonthPicker> createState() => _CalendarMonthPickerState();
}

class _CalendarMonthPickerState extends State<CalendarMonthPicker> {
  late DateTime _currentYear = widget.initialMonth;
  late final PageController _pageController = PageController(initialPage: _currentYear.year - widget.firstDate.year);
  final Duration _yearScrollDuration = const Duration(milliseconds: 300);

  /// it is used for avoiding multi-scrolling page;
  bool _isScrolling = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleMonthSelected(DateTime selectedMonth) {
    widget.onChanged(selectedMonth);
  }

  bool get _isDisplayingFirstYear => _currentYear.year == widget.firstDate.year;
  bool get _isDisplayingLastYear => _currentYear.year == widget.lastDate.year;

  FutureOr _handlePreviousYear() async {
    if (!_isDisplayingFirstYear) {
      await _pageController.previousPage(duration: _yearScrollDuration, curve: Curves.ease);
      setState(() => _currentYear = _currentYear.copyWith(year: _currentYear.year - 1));
    }
  }

  FutureOr _handleNextYear() async {
    if (!_isDisplayingLastYear) {
      await _pageController.nextPage(duration: _yearScrollDuration, curve: Curves.ease);
      setState(() => _currentYear = _currentYear.copyWith(year: _currentYear.year + 1));
    }
  }

  void _handleYearPageScrolled(double offset) async {
    if (_isScrolling) return;
    setState(() => _isScrolling = true);
    try {
      if (offset > 0) {
        await _handleNextYear();
      } else {
        await _handlePreviousYear();
      }
    } finally {
      setState(() => _isScrolling = false);
    }
  }

  void _handleYearPageChanged(int page) {
    final yearDate = DateTime(widget.firstDate.year + page);
    if (_currentYear.year != yearDate.year) {
      setState(() {
        _currentYear = DateTime(yearDate.year);
      });
    }
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime year = widget.firstDate.copyWith(year: widget.firstDate.year + index);
    return _MonthPicker(
      key: ValueKey<DateTime>(year),
      selectedDate: widget.selectedDate,
      currentDate: widget.initialMonth,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      onChanged: _handleMonthSelected,
      displayedYear: year,
    );
  }

  @override
  Widget build(BuildContext context) {
    final header = _MonthPickerHeader(
      titleText: _currentYear.year.toString(),
      handlePrevious: _handlePreviousYear,
      handleNext: _handleNextYear,
      hasNext: !_isDisplayingLastYear,
      hasPrevious: !_isDisplayingFirstYear,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        Expanded(
            child: GestureDetector(
          onVerticalDragUpdate: (details) {
            _handleYearPageScrolled(details.delta.dy * -1);
          },
          onPanUpdate: (details) {
            _handleYearPageScrolled(details.delta.dy * -1);
          },
          behavior: HitTestBehavior.opaque,
          child: Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                _handleYearPageScrolled(event.scrollDelta.dy);
              }
            },
            child: PageView.builder(
              scrollDirection: widget.scrollDirection,
              controller: _pageController,
              onPageChanged: widget.scrollDirection == Axis.horizontal ? _handleYearPageChanged : null,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: _buildItems,
              itemCount: (widget.lastDate.year - widget.firstDate.year) + 1,
            ),
          ),
        ))
      ],
    );
  }
}

class _MonthPicker extends StatefulWidget {
  _MonthPicker({
    super.key,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
    required this.displayedYear,
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
  final DateTime displayedYear;

  @override
  State<_MonthPicker> createState() => __MonthPickerState();
}

class __MonthPickerState extends State<_MonthPicker> {
  @override
  Widget build(BuildContext context) {
    return GridView.custom(
        gridDelegate: _monthPickerGridDelegate,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childrenDelegate: SliverChildListDelegate(
          List.generate(
            DateTime.monthsPerYear,
            (index) {
              final DateTime monthToBuild = DateTime(widget.displayedYear.year, index + 1);
              final bool isDisabled = monthToBuild.isAfter(widget.lastDate) || monthToBuild.isBefore(widget.firstDate);
              final bool isSelectedMonth =
                  widget.selectedDate.year == monthToBuild.year && widget.selectedDate.month == monthToBuild.month;
              final String monthText = DateFormat.MMM().format(widget.displayedYear.copyWith(month: index + 1));
              if (isSelectedMonth) {
                return ElevatedButton(
                  onPressed: isDisabled ? null : () => widget.onChanged(monthToBuild),
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                      padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry?>((_) => EdgeInsets.zero)),
                  child: Text(monthText),
                );
              } else {
                return TextButton(
                    onPressed: isDisabled ? null : () => widget.onChanged(monthToBuild),
                    child: Text(
                      monthText,
                      style: TextStyle(color: isDisabled ? Style.grey3 : Theme.of(context).colorScheme.onSurface),
                    ));
              }
            },
          ),
          addRepaintBoundaries: false,
        ));
  }
}

class _MonthPickerGridDelegate extends SliverGridDelegate {
  const _MonthPickerGridDelegate();

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

const _MonthPickerGridDelegate _monthPickerGridDelegate = _MonthPickerGridDelegate();
