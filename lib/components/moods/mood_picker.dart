import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tracker/components/moods/utils.dart';
import 'package:sleep_tracker/utils/num.dart';

import 'package:sleep_tracker/utils/style.dart';

class MoodPicker extends StatelessWidget {
  const MoodPicker({super.key, required this.value, required this.onChanged, this.onSlide});
  final double? value;
  final ValueChanged<double?> onChanged;
  final ValueChanged<bool>? onSlide;

  int? get _activeIndex => value != null ? value! ~/ 0.2 : null;

  void _handleIndexPressed(int i) {
    onChanged(i * 0.2);
  }

  void _handleChanged(double value) {
    onChanged(value);
  }

  void _handleOnSlide(bool isSliding) {
    if (onSlide != null) onSlide!(isSliding);
  }

  void reset() {
    onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: Style.spacingXl),
        Row(
          children: Mood.values.mapIndexed((i, mood) {
            return Expanded(
                child: GestureDetector(
                    onTap: () => _handleIndexPressed(i),
                    onLongPressStart: (_) => _handleOnSlide(true),
                    onLongPress: () => _handleIndexPressed(i),
                    onLongPressEnd: (_) => _handleOnSlide(false),
                    child: AnimatedScale(
                        scale: _activeIndex == i ? 2 : 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.bounceInOut,
                        child: SvgPicture.asset('assets/moods/${mood.name}.svg'))));
          }).toList(),
        ),
        const SizedBox(height: Style.spacingMd),
        Container(
          height: 64,
          alignment: Alignment.center,
          child: Slider(
            value: value ?? 0,
            label: NumFormat.toPercent(value ?? 0),
            onChangeStart: (_) => _handleOnSlide(true),
            onChanged: _handleChanged,
            onChangeEnd: (_) => _handleOnSlide(false),
          ),
        ),
      ],
    );
  }
}
