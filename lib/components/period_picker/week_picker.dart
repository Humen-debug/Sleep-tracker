import 'package:flutter/material.dart';
import 'package:sleep_tracker/components/period_picker/calendar_week_picker.dart';
import 'package:sleep_tracker/components/period_picker/const.dart';
import 'package:sleep_tracker/utils/style.dart';

Future<DateTime?> showWeekPicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? currentDate,
  String? cancelText,
  String? confirmText,
  bool useRootNavigator = true,
  TransitionBuilder? builder,
}) async {
  initialDate = DateUtils.dateOnly(initialDate);
  firstDate = DateUtils.dateOnly(firstDate);
  lastDate = DateUtils.dateOnly(lastDate);
  assert(
    !lastDate.isBefore(firstDate),
    'lastDate $lastDate must be on or after firstDate $firstDate.',
  );
  assert(
    !initialDate.isBefore(firstDate),
    'initialDate $initialDate must be on or after firstDate $firstDate.',
  );
  assert(
    !initialDate.isAfter(lastDate),
    'initialDate $initialDate must be on or before lastDate $lastDate.',
  );
  Widget dialog = WeekPickerDialog(
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    cancelText: cancelText,
    confirmText: confirmText,
  );

  return showDialog<DateTime>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (BuildContext context) {
        return builder == null ? dialog : builder(context, dialog);
      });
}

const double _actionHeight = 52.0;

class WeekPickerDialog extends StatefulWidget {
  WeekPickerDialog({
    super.key,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    this.cancelText,
    this.confirmText,
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
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? currentDate;
  final String? cancelText;
  final String? confirmText;

  @override
  State<WeekPickerDialog> createState() => _WeekPickerDialogState();
}

class _WeekPickerDialogState extends State<WeekPickerDialog> {
  late DateTime _selectedDate = widget.initialDate;

  void _handleOk() {
    Navigator.pop(context, _selectedDate);
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  late final Size _dialogSize = Size(
      dayPickerRowHeight * (DateTime.daysPerWeek + 1) + monthPickerHorizontalPadding * 2,
      (dayPickerRowHeight *
              (DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month) ~/ DateTime.daysPerWeek + 1)) +
          _actionHeight +
          60);

  @override
  Widget build(BuildContext context) {
    final actions = Container(
      alignment: AlignmentDirectional.centerEnd,
      constraints: const BoxConstraints(minHeight: _actionHeight),
      padding: const EdgeInsets.symmetric(horizontal: Style.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _handleCancel,
            child: Text(widget.cancelText ?? 'CANCEL', style: const TextStyle(color: Style.grey3)),
          ),
          const SizedBox(width: Style.spacingXs),
          TextButton(
            onPressed: _handleOk,
            child: Text(widget.cancelText ?? 'OK'),
          )
        ],
      ),
    );
    final picker = CalendarWeekPicker(
      initialDate: _selectedDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      onDateChanged: _handleDateChanged,
    );
    return Dialog(
      child: Builder(builder: (context) {
        return SizedBox(
          width: _dialogSize.width,
          height: _dialogSize.height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Expanded(child: picker), actions],
          ),
        );
      }),
    );
  }
}
