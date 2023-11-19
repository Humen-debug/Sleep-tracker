import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sleep_tracker/logger/logger.dart';
import 'package:sleep_tracker/providers/auth/auth_provider.dart';
import 'package:sleep_tracker/utils/background/background_controller.dart';
import 'package:sleep_tracker/routers/app_router.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const ProviderScope(child: MyApp()));

  /// Must call [BackgroundFetch.registerHeadlessTask] in main with static/public function
  BackgroundFetch.registerHeadlessTask(BackgroundController.backgroundFetchHeadlessTask);
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _appRouter = AppRouter();

  Future<bool> _initialize(BuildContext context) async {
    try {
      await BackgroundController.init();
    } catch (e, s) {
      AppLogger.I.e('Background State init Error', error: e, stackTrace: s);
    }
    try {
      await ref.read(authStateProvider.notifier).init();
    } catch (e, s) {
      AppLogger.I.e('Authentication State init Error', error: e, stackTrace: s);

      rethrow;
    }
    return true;
  }

  @override
  void dispose() {
    ref.read(authStateProvider.notifier).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialize(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            FlutterNativeSplash.remove();
            return MaterialApp.router(
              title: 'Sleep Tracker',
              theme: themeData,
              themeMode: ThemeMode.dark,
              debugShowCheckedModeBanner: false,
              routerDelegate: _appRouter.delegate(),
              routeInformationParser: _appRouter.defaultRouteParser(),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
