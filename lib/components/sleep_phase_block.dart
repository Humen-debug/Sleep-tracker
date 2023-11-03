import 'package:flutter/material.dart';
import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

class SleepPhaseBlock extends StatelessWidget {
  const SleepPhaseBlock({
    Key? key,
    required this.color,
    required this.title,
    required this.desc,
  }) : super(key: key);
  final Color color;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 80),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            width: 8,
            height: 8,
          ),
          const SizedBox(width: Style.spacingXs),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: Style.spacingXs),
              Text(
                desc,
                style: dataTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              )
            ],
          )
        ],
      ),
    );
  }
}
