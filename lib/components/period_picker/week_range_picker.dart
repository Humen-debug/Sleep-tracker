import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/period_picker/calendar_week_range_picker.dart';
import 'package:sleep_tracker/utils/style.dart';

Future<DateTimeRange?> showWeekRangePicker({
  required BuildContext context,
  DateTimeRange? initialDateRange,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? currentDate,
  String? cancelText,
  String? confirmText,
  bool useRootNavigator = true,
  TransitionBuilder? builder,
}) async {
  initialDateRange = initialDateRange == null ? null : DateUtils.datesOnly(initialDateRange);
  firstDate = DateUtils.dateOnly(firstDate);
  lastDate = DateUtils.dateOnly(lastDate);
  assert(
    !lastDate.isBefore(firstDate),
    'lastDate $lastDate must be on or after firstDate $firstDate.',
  );
  assert(
    initialDateRange == null || !initialDateRange.start.isBefore(firstDate),
    "initialDateRange's start date must be on or after firstDate $firstDate.",
  );
  assert(
    initialDateRange == null || !initialDateRange.end.isBefore(firstDate),
    "initialDateRange's end date must be on or after firstDate $firstDate.",
  );
  assert(
    initialDateRange == null || !initialDateRange.start.isAfter(lastDate),
    "initialDateRange's start date must be on or before lastDate $lastDate.",
  );
  assert(
    initialDateRange == null || !initialDateRange.end.isAfter(lastDate),
    "initialDateRange's end date must be on or before lastDate $lastDate.",
  );
  currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now());

  Widget dialog = WeekRangePickerDialog(
    firstDate: firstDate,
    lastDate: lastDate,
    initialDateRange: initialDateRange,
    currentDate: currentDate,
    saveText: confirmText,
    cancelText: cancelText,
  );

  return showDialog(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (BuildContext context) {
        return builder == null ? dialog : builder(context, dialog);
      });
}

class WeekRangePickerDialog extends StatefulWidget {
  const WeekRangePickerDialog({
    super.key,
    this.initialDateRange,
    required this.firstDate,
    required this.lastDate,
    this.currentDate,
    this.cancelText = "CANCEL",
    this.saveText = "SAVE",
    this.helpText = "SELECT RANGE",
  });
  final DateTimeRange? initialDateRange;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? currentDate;
  final String? cancelText;
  final String? saveText;
  final String helpText;

  @override
  State<WeekRangePickerDialog> createState() => _WeekRangePickerDialogState();
}

class _WeekRangePickerDialogState extends State<WeekRangePickerDialog> {
  late DateTime? _selectedStart = widget.initialDateRange?.start;
  late DateTime? _selectedEnd = widget.initialDateRange?.end;
  bool get _hasSelectedDateRange => _selectedStart != null && _selectedEnd != null;

  void _handleOk() {
    final DateTimeRange? selectedRange =
        _hasSelectedDateRange ? DateTimeRange(start: _selectedStart!, end: _selectedEnd!) : null;
    Navigator.pop(context, selectedRange);
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleStartDateChanged(DateTime? date) {
    setState(() => _selectedStart = date);
  }

  void _handleEndDateChanged(DateTime? date) {
    setState(() => _selectedEnd = date);
  }

  @override
  Widget build(BuildContext context) {
    final DatePickerThemeData themeData = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final Color? headerBackground =
        themeData.rangePickerHeaderBackgroundColor ?? defaults.rangePickerHeaderBackgroundColor;
    final Color? headerForeground =
        themeData.rangePickerHeaderForegroundColor ?? defaults.rangePickerHeaderForegroundColor;
    final Color? headerDisabledForeground = headerForeground?.withOpacity(0.38);
    final TextStyle? headlineStyle =
        themeData.rangePickerHeaderHeadlineStyle ?? defaults.rangePickerHeaderHeadlineStyle;
    final TextStyle? headlineHelpStyle =
        (themeData.rangePickerHeaderHelpStyle ?? defaults.rangePickerHeaderHelpStyle)?.apply(color: headerForeground);
    final startDateText = _selectedStart != null ? DateFormat.Md().format(_selectedStart!) : "Start Date";
    final endDateText = _selectedEnd != null ? DateFormat.Md().format(_selectedEnd!) : "End Date";
    final TextStyle? startDateStyle = headlineStyle?.apply(
      color: _selectedStart != null ? headerForeground : headerDisabledForeground,
    );
    final TextStyle? endDateStyle = headlineStyle?.apply(
      color: _selectedEnd != null ? headerForeground : headerDisabledForeground,
    );
    final ButtonStyle buttonStyle =
        TextButton.styleFrom(foregroundColor: headerForeground, disabledForegroundColor: headerDisabledForeground);
    final Set<MaterialState> buttonStates = <MaterialState>{if (!_hasSelectedDateRange) MaterialState.disabled};
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Builder(builder: (BuildContext context) {
        return SafeArea(
            top: false,
            left: false,
            right: false,
            child: Scaffold(
              backgroundColor: DatePickerTheme.of(context).rangePickerBackgroundColor ??
                  DatePickerTheme.defaults(context).rangePickerBackgroundColor,
              appBar: AppBar(
                elevation: 3,
                backgroundColor: headerBackground,
                leading: CloseButton(onPressed: _handleCancel),
                actions: [
                  TextButton(
                    onPressed: _hasSelectedDateRange ? _handleOk : null,
                    style: buttonStyle,
                    statesController: MaterialStatesController(buttonStates),
                    child: Text(widget.saveText ?? 'SAVE'),
                  ),
                  const SizedBox(width: Style.spacingXs)
                ],
                bottom: PreferredSize(
                  preferredSize: const Size(double.infinity, 64.0),
                  child: Row(
                    children: [
                      SizedBox(width: MediaQuery.sizeOf(context).width < 360 ? 42 : 72),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.helpText, style: headlineHelpStyle),
                            const SizedBox(height: Style.spacingXs),
                            Row(
                              children: [
                                Text(
                                  startDateText,
                                  style: startDateStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  ' – ',
                                  style: startDateStyle,
                                ),
                                Flexible(
                                  child: Text(
                                    endDateText,
                                    style: endDateStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Style.spacingMd),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: CalendarWeekRangePicker(
                selectedStartDate: _selectedStart,
                selectedEndDate: _selectedEnd,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onStartDateChanged: _handleStartDateChanged,
                onEndDateChanged: _handleEndDateChanged,
              ),
            ));
      }),
    );
  }
}
