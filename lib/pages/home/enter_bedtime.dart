import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/bedtime_input/index.dart';
import 'package:sleep_tracker/utils/style.dart';

@RoutePage()
class EnterBedtimePage extends StatefulWidget {
  const EnterBedtimePage({super.key});

  @override
  State<EnterBedtimePage> createState() => _EnterBedtimePageState();
}

class _EnterBedtimePageState extends State<EnterBedtimePage> {
  late DateTimeRange _selectedRange;
  // dev
  bool _alarmOn = true;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateUtils.dateOnly(DateTime.now());
    // todo: add personalization or plan recommendation
    _selectedRange = DateTimeRange(start: now, end: now.add(const Duration(hours: 8)));
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleSave() {
    Navigator.pop(context);
  }

  void _handleAlarmChanged(bool value) {
    if (_alarmOn != value) setState(() => _alarmOn = value);
  }

  Widget _buildTimeLabel(String label, DateTime date) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime now = DateTime.now();
    String dateText = DateFormat.Hm().format(date);
    dateText = DateUtils.isSameDay(date, now)
        ? 'Today, $dateText'
        : DateUtils.isSameDay(date, now.add(const Duration(days: 1)))
            ? 'Tomorrow, $dateText'
            : '${DateFormat.Md().format(date)} $dateText';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: Style.grey3),
        ),
        const SizedBox(height: Style.spacingXxs),
        Text(dateText, maxLines: 2, style: textTheme.bodyMedium)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    final EdgeInsets safePadding = EdgeInsets.only(top: MediaQuery.paddingOf(context).top);

    final Widget footer = Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.only(top: Style.spacingXs, bottom: Style.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: Style.spacingXxl, right: Style.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _buildTimeLabel('BEDTIME', _selectedRange.start),
                    const Spacer(),
                    _buildTimeLabel('WAKE UP', _selectedRange.end),
                  ],
                ),
                const SizedBox(height: Style.spacingLg),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ALARM',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Style.grey3),
                          ),
                          Text(
                            _alarmOn ? 'ON' : 'OFF',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 80.0),
                      child: Center(
                        child: CupertinoSwitch(
                          value: _alarmOn,
                          onChanged: _handleAlarmChanged,
                          activeColor: Style.highlightPurple,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Style.spacingLg),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _handleCancel,
                  child: const Text('CANCEL', style: TextStyle(color: Style.grey3)),
                ),
              ),
              Expanded(child: TextButton(onPressed: _handleSave, child: const Text('SAVE'))),
            ],
          )
        ],
      ),
    );

    final Widget picker = Center(
      child: BedtimeInput(
        initialRange: _selectedRange,
        onChanged: (value) => setState(() {
          _selectedRange = value;
        }),
      ),
    );

    return Scaffold(
      body: (isPortrait)
          ? Column(
              children: [
                Expanded(child: SingleChildScrollView(padding: safePadding, child: picker)),
                footer,
              ],
            )
          : SingleChildScrollView(
              padding: safePadding,
              child: Column(children: [picker, footer]),
            ),
    );
  }
}
