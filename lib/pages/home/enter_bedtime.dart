import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/bedtime_input/index.dart';
import 'package:sleep_tracker/models/sleep_plan.dart';
import 'package:sleep_tracker/models/user.dart';
import 'package:sleep_tracker/providers/auth_provider.dart';
import 'package:sleep_tracker/utils/style.dart';

@RoutePage<DateTimeRange>()
class EnterBedtimePage extends ConsumerStatefulWidget {
  const EnterBedtimePage({
    super.key,
    this.initialRange,
  });
  final DateTimeRange? initialRange;

  @override
  ConsumerState<EnterBedtimePage> createState() => _EnterBedtimePageState();
}

class _EnterBedtimePageState extends ConsumerState<EnterBedtimePage> {
  late DateTimeRange _selectedRange;
  // dev
  bool _alarmOn = true;

  @override
  void initState() {
    super.initState();
    final User? user = ref.read(authStateProvider).user;
    final SleepPlan? plan = plans.firstWhereOrNull((plan) => plan.id == user?.sleepPlan);
    final DateTime now = DateTime.now();

    _selectedRange = widget.initialRange ??
        DateTimeRange(
          start: now,
          end: now.add(Duration(minutes: plan?.sleepMinutes.firstOrNull?.toInt() ?? 480)),
        );
  }

  void _handleCancel() {
    context.popRoute();
  }

  /// Returns the [_selectedRange] to home page.
  void _handleSave() {
    context.popRoute(_selectedRange);
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
