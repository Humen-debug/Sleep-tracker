import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/moods/utils.dart';
import 'package:sleep_tracker/components/period_picker/period_picker.dart';
import 'package:sleep_tracker/utils/style.dart';

class DailyMood extends StatefulWidget {
  const DailyMood({super.key});

  @override
  State<DailyMood> createState() => _DailyMoodState();
}

class _DailyMoodState extends State<DailyMood> {
  // dev use
  List<double?> data = List.generate(31, (index) => index + 1 <= 24 ? Random().nextDouble() : null);

  final DateTime _now = DateTime.now();
  DateTime? _date = DateTime.now();
  int? _activeIndex;

  String? get label {
    if (_activeIndex != null) {
      String date = DateFormat.MMMd().format(DateTime.now().copyWith(day: _activeIndex! + 1));
      int value = ((data[_activeIndex!] ?? 0) * 100).round();
      return '$date, $value%';
    }
    return null;
  }

  int get average {
    return (data.whereNotNull().average * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    double gridWidth = MediaQuery.of(context).size.shortestSide;
    double gridCellSize = (gridWidth) / 7;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Style.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Mood',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              PeriodPicker(
                maxWidth: 100,
                mode: PeriodPickerMode.months,
                selectedDate: _date,
                firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
                lastDate: _now,
                onDateChanged: (v) {
                  setState(() => _date = v);
                },
              )
            ],
          ),
          // Board
          Container(
            constraints: BoxConstraints(maxWidth: gridWidth),
            child: GestureDetector(
              onLongPressMoveUpdate: (details) {
                int row = (details.localPosition.dy / gridCellSize).floor();
                int col = (details.localPosition.dx / gridCellSize).floor();
                int index = col + row * 7;
                if (index != _activeIndex && index + 1 <= 24) setState(() => _activeIndex = index);
              },
              child: Stack(
                children: [
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    crossAxisSpacing: Style.spacingXs,
                    mainAxisSpacing: Style.radiusXs,
                    padding: const EdgeInsets.symmetric(vertical: Style.spacingMd),
                    physics: const NeverScrollableScrollPhysics(),
                    children: data
                        .mapIndexed((index, v) => v != null
                            ? GestureDetector(
                                onTap: () {
                                  if (_activeIndex != index) setState(() => _activeIndex = index);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _activeIndex == index
                                          ? Style.grey1
                                          : Style.highlightDarkPurple.withOpacity(0.15)),
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    child: SvgPicture.asset(
                                      'assets/moods/${valueToMood(v).name}${_activeIndex == index ? '' : '-outline'}.svg',
                                      // if awful mood, the color is too deep for showing
                                      color: valueToMood(v) == Mood.awful && _activeIndex != index
                                          ? Style.highlightPurple
                                          : null,
                                    ),
                                  ),
                                ))
                            : Container(
                                margin: const EdgeInsets.all(2),
                                decoration:
                                    BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Style.grey3)),
                              ))
                        .toList(),
                  ),
                  // value indicator
                  if (_activeIndex != null)
                    AnimatedPositioned(
                        top: (_activeIndex! ~/ 7) * gridCellSize + gridCellSize,
                        // if left exceed screen width, move it to right
                        left: (_activeIndex!.remainder(7) * gridCellSize) +
                            (_activeIndex!.remainder(7) * gridCellSize > gridWidth - gridCellSize * 3
                                ? (-2 * gridCellSize)
                                : gridCellSize),
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Style.spacingSm, vertical: Style.radiusXs),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(Style.radiusXs),
                            boxShadow: const [BoxShadow(offset: Offset(0, 4), color: Colors.black38, blurRadius: 8)],
                          ),
                          child: Text(label!),
                        ))
                ],
              ),
            ),
          ),
          // daily average
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Average',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Style.grey3),
              ),
              Text('$average%', style: Theme.of(context).textTheme.headlineSmall)
            ],
          )
        ],
      ),
    );
  }
}
