import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tracker/utils/style.dart';

@RoutePage()
class AlarmSettingPage extends StatefulWidget {
  const AlarmSettingPage({super.key});

  @override
  State<AlarmSettingPage> createState() => _AlarmSettingPageState();
}

class _AlarmSettingPageState extends State<AlarmSettingPage> {
  // dev use
  double _soundVolume = 0.5;
  int _selectedIndex = 0;

  void _handleOnSaved() {
    context.popRoute();
  }

  void _handleSoundChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildSoundItem(BuildContext context, int index) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      onTap: () => _handleSoundChanged(index),
      title: Text('Sound ${index + 1}'),
      trailing: isSelected ? SvgPicture.asset('assets/icons/tick.svg', color: Style.grey1) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm Sound'),
      ),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingLg),
            child: Column(
              children: [
                SizedBox(
                  height: 64.0,
                  child: Center(
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/icons/sound.svg',
                            color: Theme.of(context).colorScheme.primary, width: 24, height: 24),
                        Expanded(
                            child:
                                Slider(value: _soundVolume, onChanged: (value) => setState(() => _soundVolume = value)))
                      ],
                    ),
                  ),
                ),
                // dev generated sound list
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Style.radiusSm),
                      color: Theme.of(context).colorScheme.tertiary),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: _buildSoundItem,
                    separatorBuilder: (_, __) =>
                        Divider(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5), height: 0),
                    itemCount: 12,
                  ),
                )
              ],
            ),
          )),
          Container(
              padding: const EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingMd),
              child: SizedBox(
                  width: double.infinity, child: ElevatedButton(onPressed: _handleOnSaved, child: const Text('Save'))))
        ],
      ),
    );
  }
}
