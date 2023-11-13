import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/sleep_timer.dart';
import 'package:sleep_tracker/utils/style.dart';

/// [SleepTimer] draws a timer/stopwatch of sleep events duration.
/// Sleep events can be divided into awaken, go to bed, and sleeping.
///
/// It shows the remaining and elapsed time between start and end date/time.
/// If the start and ent date/time are null (in [controller]), it can show an
/// infinity elapsed time.
class SleepTimer extends StatefulWidget {
  final SleepTimerController controller;
  const SleepTimer({super.key, required this.controller});

  @override
  State<SleepTimer> createState() => _SleepTimerState();
}

class _SleepTimerState extends State<SleepTimer> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.controller,
        builder: (BuildContext context, Widget? child) {
          String progress =
              '${widget.controller.isElapsed ? 'Elapsed' : 'Remained'}${widget.controller.showProgress ? ' (${(widget.controller.progress * 100).round()})%' : ''}';
          String time = widget.controller.isElapsed ? widget.controller.elapsedTime : widget.controller.remainedTime;

          return Stack(
            alignment: Alignment.center,
            children: [
              TimerPaint(progress: widget.controller.progress, reversed: !widget.controller.isElapsed),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.controller.ableToSwitchMode)
                    GestureDetector(
                      onTap: () => widget.controller.switchMode(),
                      child: SvgPicture.asset('assets/icons/switch.svg', color: Style.grey3),
                    ),
                  const SizedBox(height: Style.spacingXxs),
                  Text(
                    progress,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Style.grey3, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (widget.controller.endTime != null) ...[
                    const SizedBox(height: Style.spacingSm),
                    Text('End Time',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Style.grey3, fontWeight: FontWeight.w600)),
                    Text(
                        "${DateFormat.Md().format(widget.controller.endTime!)} ${DateFormat.Hm().format(widget.controller.endTime!)}")
                  ] else if (widget.controller.startTime != null) ...[
                    const SizedBox(height: Style.spacingSm),
                    Text('Start Time',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Style.grey3, fontWeight: FontWeight.w600)),
                    Text(
                        "${DateFormat.Md().format(widget.controller.startTime!)} ${DateFormat.Hm().format(widget.controller.startTime!)}")
                  ],
                  const SizedBox(height: Style.spacingMd),
                ],
              )
            ],
          );
        });
  }
}
