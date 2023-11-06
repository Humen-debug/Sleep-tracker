import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/period_pickers.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

class PeriodPicker extends StatelessWidget {
  PeriodPicker({
    super.key,
    required this.mode,
    this.maxWidth = 150,
    this.rangeSelected = false,
    DateTime? selectedDate,
    DateTimeRange? selectedRange,
    required DateTime lastDate,
    required DateTime firstDate,
    this.onDateChanged,
    this.onRangeChanged,
  })  : selectedDate = selectedDate == null ? null : DateUtils.dateOnly(selectedDate),
        selectedRange = selectedRange == null ? null : DateUtils.datesOnly(selectedRange),
        lastDate = DateUtils.dateOnly(lastDate),
        firstDate = DateUtils.dateOnly(firstDate) {
    assert(!this.lastDate.isBefore(this.firstDate),
        'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.');
    assert(this.selectedDate == null ? true : !this.selectedDate!.isBefore(this.firstDate),
        'selectedDate ${this.selectedDate} must be on or after firstDate ${this.firstDate}.');
    assert(this.selectedDate == null ? true : !this.selectedDate!.isAfter(this.lastDate),
        'selectedDate ${this.selectedDate} must be on or before lastDate ${this.lastDate}.');
    assert(this.selectedRange == null || !this.selectedRange!.start.isBefore(this.firstDate),
        "selectedRange's start date must be on or after firstDate ${this.firstDate}.");
    assert(
      this.selectedRange == null || !(this.selectedRange!).end.isBefore(this.firstDate),
      "selectedRange's end date must be on or after firstDate ${this.firstDate}.",
    );
    assert(
      this.selectedRange == null || !(this.selectedRange!).start.isAfter(this.lastDate),
      "selectedRange's start date must be on or before lastDate {$this.lastDate}.",
    );
    assert(
      this.selectedRange == null || !this.selectedRange!.end.isAfter(this.lastDate),
      "selectedRange's end date must be on or before lastDate ${this.lastDate}.",
    );
  }

  final PeriodPickerMode mode;
  final double maxWidth;
  final bool rangeSelected;

  final DateTime? selectedDate;
  final DateTimeRange? selectedRange;
  final DateTime lastDate;
  final DateTime firstDate;

  final void Function(DateTime?)? onDateChanged;
  final void Function(DateTimeRange?)? onRangeChanged;

  String get label {
    if (rangeSelected) {
      switch (mode) {
        case PeriodPickerMode.days:
        case PeriodPickerMode.weeks:
          return '${DateFormat.Md().format(selectedRange?.start ?? DateTime.now())}-${DateFormat.Md().format(selectedRange?.end ?? DateTime.now())}';
        case PeriodPickerMode.months:
          return '${DateFormat.MMM().format(selectedRange?.start ?? DateTime.now())}-${DateFormat.MMM().format(selectedRange?.end ?? DateTime.now())}';
        default:
      }
    } else {
      final DateTime date = selectedDate ?? DateTime.now();
      switch (mode) {
        case PeriodPickerMode.days:
          return DateFormat.MMMd().format(date);
        case PeriodPickerMode.weeks:
          return '${DateFormat.Md().format(date)} - ${DateFormat.Md().format(date.add(const Duration(days: DateTime.daysPerWeek - 1)))}';
        case PeriodPickerMode.months:
          bool isSameYear = date.year == DateTime.now().year;
          return isSameYear ? DateFormat.MMM().format(date) : DateFormat.yMMM().format(date);
        default:
      }
    }
    return "";
  }

  void _handleDateSelected(DateTime? selected) {
    onDateChanged?.call(selected);
  }

  void _handleRangeSelected(DateTimeRange? selected) {
    onRangeChanged?.call(selected);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextButton(
              onPressed: () async {
                switch (mode) {
                  case PeriodPickerMode.days:
                    if (rangeSelected) {
                      final range = await showDateRangePicker(
                        context: context,
                        initialEntryMode: DatePickerEntryMode.calendarOnly,
                        currentDate: DateTime.now(),
                        initialDateRange: selectedRange,
                        firstDate: firstDate,
                        lastDate: lastDate,
                      );
                      _handleRangeSelected(range);
                    } else {
                      final date = await showDatePicker(
                          context: context,
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          initialDate: selectedRange?.start ?? DateTime.now(),
                          firstDate: firstDate,
                          lastDate: lastDate);
                      _handleDateSelected(date);
                    }
                    break;
                  case PeriodPickerMode.weeks:
                    if (!context.mounted) return;
                    if (rangeSelected) {
                      // dev
                      final range =
                          await showDateRangePicker(context: context, firstDate: firstDate, lastDate: lastDate);
                      _handleRangeSelected(range);
                    } else {
                      final date = await showWeekPicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: firstDate,
                        lastDate: lastDate,
                      );

                      _handleDateSelected(date);
                    }
                    break;
                  case PeriodPickerMode.months:
                    if (!context.mounted) return;
                    if (rangeSelected) {
                      final range = await showMonthRangePicker(
                        context: context,
                        initialDateRange: selectedRange,
                        firstDate: firstDate,
                        lastDate: lastDate,
                      );
                      _handleRangeSelected(range);
                    } else {
                      final date = await showMonthPicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: firstDate,
                        lastDate: lastDate,
                      );
                      _handleDateSelected(date);
                    }
                    break;
                }
              },
              child: Text(label,
                  style: dataTextTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}

enum PeriodPickerMode { days, weeks, months }
