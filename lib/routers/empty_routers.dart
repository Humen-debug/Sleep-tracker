import 'package:auto_route/auto_route.dart';

/// [StatisticRouterPage] render an empty page for holding nested route pages in statistic.
@RoutePage(name: 'StatisticRouter')
class StatisticRouterPage extends AutoRouter {
  const StatisticRouterPage({super.key});
}

/// [SettingsRouterPage] render an empty page for holding nested route pages in settings.
@RoutePage(name: 'SettingsRouter')
class SettingsRouterPage extends AutoRouter {
  const SettingsRouterPage({super.key});
}
