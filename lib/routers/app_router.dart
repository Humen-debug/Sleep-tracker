import 'package:auto_route/auto_route.dart';

import 'package:sleep_tracker/pages/home/index.dart';
import 'package:sleep_tracker/pages/main.dart';
import 'package:sleep_tracker/pages/plans.dart';
import 'package:sleep_tracker/pages/settings/change_password.dart';
import 'package:sleep_tracker/pages/statistic/index.dart';
import 'package:sleep_tracker/pages/statistic/sleep_health.dart';
import 'package:sleep_tracker/pages/settings/index.dart';
import 'package:sleep_tracker/pages/settings/profile.dart';
import 'package:sleep_tracker/pages/settings/alarm.dart';
import 'package:sleep_tracker/routers/empty_routers.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/', page: MainRoute.page, initial: true, children: [
          AutoRoute(page: HomeRoute.page),
          AutoRoute(page: PlansRoute.page),
          AutoRoute(page: StatisticRouter.page, path: 'statistic', children: [
            AutoRoute(page: StatisticRoute.page, initial: true),
            AutoRoute(page: SleepHealthRoute.page),
          ]),
          AutoRoute(page: SettingsRoute.page),
        ]),
        AutoRoute(page: ChangePasswordRoute.page),
        AutoRoute(page: ProfileRoute.page),
        AutoRoute(page: AlarmSettingRoute.page),
      ];
}
