import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sleep_tracker/utils/style.dart';

const double _tabRowHeight = 42.0;

class SleepPeriodTabBar extends StatefulWidget {
  const SleepPeriodTabBar({
    super.key,
    this.initialIndex = 0,
    this.onChanged,
    required this.labels,
  });
  final int initialIndex;
  final void Function(int value)? onChanged;
  final List<String> labels;

  @override
  State<SleepPeriodTabBar> createState() => _SleepPeriodTabBarState();
}

class _SleepPeriodTabBarState extends State<SleepPeriodTabBar> {
  late int _currentIndex = widget.initialIndex;

  void _handleOnChanged(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      widget.onChanged?.call(index);
    }
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
    return Container(
      constraints: const BoxConstraints(maxHeight: _tabRowHeight),
      decoration:
          BoxDecoration(color: Theme.of(context).colorScheme.tertiary, borderRadius: BorderRadius.circular(100)),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.labels
              .mapIndexed(
                (index, title) => Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleOnChanged(index),
                    style: elevationButtonStyle,
                    statesController: MaterialStatesController({if (_currentIndex == index) MaterialState.selected}),
                    child: Text(title),
                  ),
                ),
              )
              .toList()),
    );
  }
}
