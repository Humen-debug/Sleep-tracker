import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sleep_tracker/providers/auth_provider.dart';
import 'package:sleep_tracker/routers/app_router.dart';
import 'package:sleep_tracker/utils/style.dart';

@RoutePage()
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // dev
  bool silenceAsSystem = true;
  bool alarmOn = true;
  bool snoozeOn = true;
  String? _version;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final user = auth.user;
    final Widget divider = Divider(color: Theme.of(context).colorScheme.background, height: 0);
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Style.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Style.spacingLg),
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: Style.grey3, radius: 32),
                  const SizedBox(width: Style.spacingSm),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(user!.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: Style.spacingXxs),
                      Text(user.email, style: Theme.of(context).textTheme.labelSmall)
                    ],
                  )),
                  const SizedBox(width: Style.spacingSm),
                  OutlinedButton(
                      onPressed: () => context.pushRoute(const ProfileRoute()),
                      style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                          minimumSize: const MaterialStatePropertyAll(Size(64, 32)),
                          padding: const MaterialStatePropertyAll(
                              EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingSm))),
                      child: const Text('Edit'))
                ],
              ),
            ),
            const SizedBox(height: Style.spacingMd),
            ListTile(
              title: const Text('Sleep Diary'),
              onTap: () => context.pushRoute(const SleepDiaryRoute()),
              leading: SvgPicture.asset('assets/icons/diary.svg', color: Theme.of(context).primaryColor),
              trailing: SvgPicture.asset('assets/icons/chevron-right.svg', color: Style.grey1, width: 24, height: 24),
            ),
            // Alarm settings
            Padding(
              padding: const EdgeInsets.only(top: Style.spacingLg, bottom: Style.spacingXs),
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                SvgPicture.asset('assets/icons/bell-outline.svg', color: Theme.of(context).primaryColor),
                const SizedBox(width: Style.spacingXs),
                const Text('Alarm Settings', style: TextStyle(fontWeight: FontWeight.w500))
              ]),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Style.radiusSm),
                color: Theme.of(context).listTileTheme.tileColor,
              ),
              child: Column(children: [
                ListTile(
                  title: const Text('Silence alarm when system sound is off'),
                  trailing: CupertinoSwitch(
                    value: silenceAsSystem,
                    onChanged: (v) => setState(() => silenceAsSystem = v),
                    applyTheme: true,
                  ),
                ),
                divider,
                ListTile(
                  onTap: () => context.pushRoute(const AlarmSettingRoute()),
                  title: const Text('Alarm Sound'),
                  subtitle: Text(
                    'Puddles',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  trailing: CupertinoSwitch(
                    value: alarmOn,
                    onChanged: (v) => setState(() => alarmOn = v),
                    applyTheme: true,
                  ),
                ),
                divider,
                ListTile(
                  title: const Text('Snooze'),
                  subtitle: Text(
                    '5 minutes',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  trailing: CupertinoSwitch(
                    value: snoozeOn,
                    onChanged: (v) => setState(() => snoozeOn = v),
                    applyTheme: true,
                  ),
                ),
              ]),
            ),
            // About
            Padding(
              padding: const EdgeInsets.only(top: Style.spacingLg, bottom: Style.spacingXs),
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                SvgPicture.asset('assets/icons/info.svg', color: Theme.of(context).primaryColor),
                const SizedBox(width: Style.spacingXs),
                const Text('About', style: TextStyle(fontWeight: FontWeight.w500))
              ]),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Style.radiusSm),
                color: Theme.of(context).listTileTheme.tileColor,
              ),
              child: Column(children: [
                ListTile(
                  title: const Text('About Us'),
                  trailing:
                      SvgPicture.asset('assets/icons/chevron-right.svg', color: Style.grey1, width: 24, height: 24),
                ),
                divider,
                ListTile(
                  title: const Text('Terms of Use'),
                  trailing:
                      SvgPicture.asset('assets/icons/chevron-right.svg', color: Style.grey1, width: 24, height: 24),
                ),
                divider,
                ListTile(
                  title: const Text('Privacy'),
                  trailing:
                      SvgPicture.asset('assets/icons/chevron-right.svg', color: Style.grey1, width: 24, height: 24),
                ),
                divider,
                ListTile(
                  title: const Text('Version'),
                  trailing: Text(_version ?? '', style: const TextStyle(color: Style.grey3)),
                ),
              ]),
            ),
            const SizedBox(height: Style.spacingXxl),
            ListTile(
              title: const Text('Logout'),
              leading: SvgPicture.asset('assets/icons/logout.svg', color: Theme.of(context).primaryColor),
              trailing: SvgPicture.asset('assets/icons/chevron-right.svg', color: Style.grey1, width: 24, height: 24),
            ),

            const SizedBox(height: kBottomNavigationBarHeight),
          ],
        ),
      ),
    );
  }
}
