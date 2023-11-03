import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tracker/components/moods/utils.dart';

import 'package:sleep_tracker/utils/string.dart';
import 'package:sleep_tracker/utils/style.dart';

class MoodBoard extends StatefulWidget {
  const MoodBoard({super.key});

  @override
  State<MoodBoard> createState() => _MoodBoardState();
}

class _MoodBoardState extends State<MoodBoard> {
  // dev. It should be fetched from the today's sleeping quality
  /// the sleeping quality, in range of 0 to 1.
  double? value;

  int? get _activeIndex => value != null ? value! ~/ 0.2 : null;
  bool _isSliding = false;
  bool get _onFocused => (value == null) || _isSliding;

  void reset() {
    setState(() => value = null);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Style.spacingMd, 0, Style.spacingMd, Style.spacingXs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_onFocused ? 'How Are You Today?' : 'Today Mood',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
              if (!_onFocused)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: ElevatedButton(
                    onPressed: reset,
                    style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (states) {
                              if (states.contains(MaterialState.disabled)) {
                                return Theme.of(context).colorScheme.tertiary.withOpacity(0.5);
                              }
                              return Theme.of(context).colorScheme.tertiary;
                            },
                          ),
                          padding: const MaterialStatePropertyAll(
                              EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingSm)),
                        ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Reset',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: Style.spacingXxs),
                        SvgPicture.asset(
                          'assets/icons/reset.svg',
                          height: 16,
                          width: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
          !_onFocused
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: Style.spacingSm),
                    SvgPicture.asset('assets/moods/${valueToMood(value!).name}.svg', height: 85),
                    const SizedBox(height: Style.spacingXs),
                    Text(
                      valueToMood(value!).name.capitalize(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    )
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: Style.spacingXl),
                    Row(
                      children: Mood.values.mapIndexed((i, mood) {
                        return Expanded(
                            child: GestureDetector(
                                onTap: () => setState(() => value = (i * 0.2)),
                                onLongPressStart: (_) => setState(() => _isSliding = true),
                                onLongPress: () {
                                  setState(() => value = (i * 0.2));
                                },
                                onLongPressEnd: (_) => setState(() => _isSliding = false),
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
                        label: ((value ?? 0) * 100).round().toString(),
                        onChangeStart: (_) => setState(() => _isSliding = true),
                        onChanged: (v) => setState(() => value = v),
                        onChangeEnd: (_) => setState(() => _isSliding = false),
                      ),
                    ),
                  ],
                )
        ],
      ),
    );
  }
}
