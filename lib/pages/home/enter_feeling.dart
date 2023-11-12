import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tracker/components/moods/mood_picker.dart';
import 'package:sleep_tracker/components/moods/utils.dart';
import 'package:sleep_tracker/utils/string.dart';
import 'package:sleep_tracker/utils/style.dart';

@RoutePage<double>()
class EnterFeelingPage extends StatefulWidget {
  const EnterFeelingPage({super.key});

  @override
  State<EnterFeelingPage> createState() => _EnterFeelingPageState();
}

class _EnterFeelingPageState extends State<EnterFeelingPage> {
  double? _value;
  bool _isSliding = false;
  final Duration _transitionDuration = const Duration(milliseconds: 300);
  final Duration _animationDuration = const Duration(seconds: 3);

  Future<void> _handleSave(bool isSliding) async {
    setState(() => _isSliding = isSliding);
    if (!_isSliding && _value != null) {
      await Future.delayed(_animationDuration, () {
        context.popRoute(_value);
      });
    }
  }

  void _handleSkip() {
    context.popRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: AnimatedCrossFade(
          firstChild: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('How Do You Feel Today?', style: Theme.of(context).textTheme.headlineSmall),
              MoodPicker(
                value: _value,
                onChanged: (value) => setState(() => _value = value),
                onSlide: _handleSave,
              ),
              const SizedBox(height: Style.spacingXxl),
              Align(
                alignment: Alignment.bottomRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: OutlinedButton(
                    style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                        padding: const MaterialStatePropertyAll(
                            EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingSm))),
                    onPressed: _handleSkip,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Skip'),
                        SvgPicture.asset('assets/icons/chevron-right.svg', color: Theme.of(context).primaryColor)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          secondChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/moods/${valueToMood(_value ?? 0).name}.svg', width: 113, height: 113),
              const SizedBox(height: Style.spacingLg),
              Text(valueToMood(_value ?? 0).name.capitalize())
            ],
          ),
          crossFadeState: (_value != null && !_isSliding) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: _transitionDuration,
        ),
      ),
    );
  }
}
