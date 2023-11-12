import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sleep_tracker/components/bedtime_input/painter.dart';
import 'package:sleep_tracker/components/bedtime_input/utils.dart';
import 'package:sleep_tracker/utils/style.dart';

const double _tabRowHeight = 42.0;

class BedtimeInput extends StatefulWidget {
  const BedtimeInput({
    super.key,
    required this.initialRange,
    this.onChanged,
  });
  final DateTimeRange initialRange;
  final ValueChanged<DateTimeRange>? onChanged;

  @override
  State<BedtimeInput> createState() => _BedtimeInputState();
}

class _BedtimeInputState extends State<BedtimeInput> {
  late DateTimeRange _selectedRange;

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final DateTime start = widget.initialRange.start;
    final DateTime end = widget.initialRange.end;

    /// Separate date and time to handle time selection that is before and after 0 am.
    _selectedDate = DateUtils.dateOnly(start);
    _selectedRange = DateTimeRange(
      start: start.copyWith(minute: roundUp(start.minute, 5), second: 0),
      end: end.copyWith(minute: roundUp(end.minute, 5), second: 0),
    );
  }

  final List<String> _tabs = ['Date', 'Time'];
  int _tabIndex = 1;

  void _handleTabChanged(int index) {
    setState(() => _tabIndex = index);
  }

  void _handleDateChanged(DateTime value) {
    setState(() {
      _selectedDate = DateUtils.dateOnly(value);
    });
    final Duration duration = _selectedRange.duration;
    final DateTime start = value.copyWith(hour: _selectedRange.start.hour, minute: _selectedRange.start.minute);
    final DateTime end = start.add(duration);
    final DateTimeRange range = DateTimeRange(start: start, end: end);

    widget.onChanged?.call(range);
  }

  void _handleTimeChanged(DateTimeRange value) {
    final DateTime dateOnlyStart = DateUtils.dateOnly(_selectedDate);
    DateTime start = dateOnlyStart.copyWith(hour: value.start.hour, minute: value.start.minute);
    DateTime end = start.add(value.duration);
    DateTime now = DateTime.now();
    const day = Duration(days: 1);
    // Ensure end is after now.
    if (!end.isAfter(now)) {
      start = start.add(day);
      end = end.add(day);
    }

    final DateTimeRange range = DateTimeRange(start: start, end: end);
    setState(() {
      _selectedRange = range;
    });
    widget.onChanged?.call(range);
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle? elevationButtonStyle = Theme.of(context).elevatedButtonTheme.style?.copyWith(
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
        padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingSm)),
        minimumSize: const MaterialStatePropertyAll(Size(72.0, 32.0)));

    Widget tabs = Container(
      constraints: const BoxConstraints(maxHeight: _tabRowHeight),
      decoration:
          BoxDecoration(color: Theme.of(context).colorScheme.tertiary, borderRadius: BorderRadius.circular(100)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _tabs
            .mapIndexed(
              (index, title) => Expanded(
                child: ElevatedButton(
                    onPressed: () => _handleTabChanged(index),
                    style: elevationButtonStyle,
                    statesController: MaterialStatesController({if (_tabIndex == index) MaterialState.selected}),
                    child: Text(title)),
              ),
            )
            .toList(),
      ),
    );

    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(Style.spacingMd), child: tabs),
        AnimatedCrossFade(
          firstChild: Padding(
            padding: const EdgeInsets.only(top: Style.spacingMd),
            child: CalendarDatePicker(
              initialDate: _selectedRange.start,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(
                Duration(
                    days: DateUtils.getDaysInMonth(widget.initialRange.start.year, widget.initialRange.start.month)),
              ),
              onDateChanged: _handleDateChanged,
            ),
          ),
          secondChild: Column(
            children: [
              LayoutBuilder(builder: (context, constraints) {
                final double shortestSize = MediaQuery.of(context).size.shortestSide;
                final double size = math.min(shortestSize, constraints.maxWidth);
                return Container(
                  constraints: constraints.copyWith(maxHeight: size),
                  child: Center(
                    child: BedtimeInputPaint(
                      radius: size / 2 - Style.spacingXxl,
                      initialRange: _selectedRange,
                      onChanged: _handleTimeChanged,
                    ),
                  ),
                );
              }),
              Text(
                'Sleep Time: ${_selectedRange.duration.inHours % 24} hours ${_selectedRange.duration.inMinutes % 60} minutes',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Style.grey3),
              ),
            ],
          ),
          crossFadeState: _tabIndex == 1 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
