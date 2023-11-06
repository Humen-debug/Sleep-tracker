import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tracker/components/period_pickers.dart';
import 'package:sleep_tracker/utils/style.dart';

const double _tabRowHeight = 50.0;
const double _appBarHeight = _tabRowHeight + Style.spacingMd * 2;

@RoutePage()
class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  late final ButtonStyle? _elevationButtonStyle = Theme.of(context).elevatedButtonTheme.style?.copyWith(
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
      padding:
          const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingSm)),
      minimumSize: const MaterialStatePropertyAll(Size(72.0, 32.0)));

  final List<String> _tabs = ['Days', 'Weeks', 'Months'];
  final List<PeriodPickerMode> _pickerModes = [PeriodPickerMode.weeks, PeriodPickerMode.weeks, PeriodPickerMode.months];
  final List<bool> _inRange = [false, true, true];

  int _tabIndex = 0;
  final DateTime lastDate = DateTime.now();
  final DateTime firstDate = DateTime.now().subtract(const Duration(days: 365)).copyWith(day: 1);
  DateTime selectedDate = DateTime.now();

  // dev use
  final List<String> _titles = ['Sleep Health', 'Sleep Duration', 'Most Asleep Time', 'Went to Sleep', 'Sleep Quality'];
  final List<bool> _hasMore = [true, false, false, false, false];

  void _handleTabChanged(int index) {
    if (_tabIndex != index) setState(() => _tabIndex = index);
  }

  Widget _buildItems(BuildContext context, int index) {
    final moreButton = ElevatedButton(
        onPressed: () {},
        style: _elevationButtonStyle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('More'),
            SvgPicture.asset('assets/icons/chevron-right.svg', color: Theme.of(context).primaryColor)
          ],
        ));

    final periodHeader = Row(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(onTap: () {}, child: SvgPicture.asset('assets/icons/chevron-left.svg', color: Style.grey1)),
      PeriodPicker(
        maxWidth: 100,
        mode: _pickerModes[_tabIndex],
        selectedDate: selectedDate,
        lastDate: lastDate,
        firstDate: firstDate,
        rangeSelected: _inRange[_tabIndex],
        onDateChanged: (value) {
          if (value != null && value != selectedDate) {
            setState(() {
              selectedDate = value;
            });
          }
        },
      ),
      GestureDetector(onTap: () {}, child: SvgPicture.asset('assets/icons/chevron-right.svg', color: Style.grey1)),
    ]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Style.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatisticHeader(
            title: _titles[index],
            topBarRightWidget: _hasMore[index] ? moreButton : periodHeader,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(_appBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.75),
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.all(Style.spacingMd),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary, borderRadius: BorderRadius.circular(100)),
              child: Row(
                  children: _tabs
                      .mapIndexed((index, title) => Expanded(
                              child: ElevatedButton(
                            onPressed: () => _handleTabChanged(index),
                            style: _elevationButtonStyle,
                            statesController:
                                MaterialStatesController({if (_tabIndex == index) MaterialState.selected}),
                            child: Container(height: _tabRowHeight, alignment: Alignment.center, child: Text(title)),
                          )))
                      .toList()),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        itemBuilder: _buildItems,
        separatorBuilder: (_, __) => const SizedBox(height: Style.spacingXxl),
        itemCount: _titles.length,
      ),
    );
  }
}

class _StatisticHeader extends StatelessWidget {
  const _StatisticHeader({required this.title, this.topBarRightWidget});
  final String title;
  final Widget? topBarRightWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (topBarRightWidget != null) topBarRightWidget!
      ],
    );
  }
}
