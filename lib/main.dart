import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'config/env/app_env.dart';
import 'core/services/bloc_observer/bloc_observer.dart';
import 'core/services/push/firebase_push_service.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Environment first — DioConsumer reads AppEnv.baseUrl in its constructor.
  await AppEnv.load();

  // 2. Firebase (push). Never blocks startup: on failure the app runs on
  // polling alone.
  await FirebasePushService.bootstrap();

  // 3. Dependency injection, then the push listeners — before runApp so a
  // notification that launched the app is captured.
  await ServiceLocator.init();
  await pushService.init();

  // 4. System chrome.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light, // iOS
      statusBarIconBrightness: Brightness.dark, // Android
    ),
  );
  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  // 5. Bloc logging.
  Bloc.observer = AppBlocObserver();

  runApp(const App());
}
