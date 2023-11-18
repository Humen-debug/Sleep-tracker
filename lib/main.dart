import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sleep_tracker/logger/logger.dart';
import 'package:sleep_tracker/providers/auth/auth_provider.dart';
import 'package:sleep_tracker/providers/background/background_provider.dart';
import 'package:sleep_tracker/routers/app_router.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

/// This "Headless Task" is run when app is terminated.
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  var timeout = task.timeout;
  if (timeout) {
    AppLogger.I.i("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  AppLogger.I.i("[BackgroundFetch] Headless event received: $taskId");

  if (taskId == 'flutter_background_fetch') {
    BackgroundFetch.scheduleTask(TaskConfig(
      taskId: "com.transistorsoft.customtask",
      delay: 5000,
      periodic: true,
      forceAlarmManager: false,
      stopOnTerminate: false,
      enableHeadless: true,
    ));
  }
  BackgroundFetch.finish(taskId);
}

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const ProviderScope(child: MyApp()));
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
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
      await ref.read(backgroundProvider.notifier).init();
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
