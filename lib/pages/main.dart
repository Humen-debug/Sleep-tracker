import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tracker/routers/app_router.dart';

@RoutePage()
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: _routes.map((e) => e.route).toList(),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          bottomNavigationBar: BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedFontSize: 0,
              unselectedFontSize: 0,
              backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.75),
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              onTap: (i) {
                tabsRouter.setActiveIndex(i);
              },
              currentIndex: tabsRouter.activeIndex,
              items: _routes
                  .map(
                    (route) => BottomNavigationBarItem(
                      label: "",
                      icon: SvgPicture.asset('assets/nav/${route.icon}.svg'),
                      activeIcon: SvgPicture.asset('assets/nav/${route.icon}-active.svg'),
                    ),
                  )
                  .toList()),
          body: SafeArea(child: Padding(padding: const EdgeInsets.only(bottom: 40), child: child)),
          extendBody: true,
        );
      },
    );
  }
}

List<_BottomNavItem> _routes = [
  _BottomNavItem(icon: 'sleep', route: const HomeRoute()),
  _BottomNavItem(icon: 'plans', route: const PlansRoute()),
  _BottomNavItem(icon: 'statistic', route: const StatisticRoute()),
  _BottomNavItem(icon: 'profile', route: const SettingsRoute()),
];

class _BottomNavItem {
  final String icon;
  final PageRouteInfo route;
  _BottomNavItem({
    required this.icon,
    required this.route,
  });
}
