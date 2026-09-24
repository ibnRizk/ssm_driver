import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ssm_driver/core/theme/app_theme.dart';
import 'package:ssm_driver/core/theme/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/env/app_env.dart';
import 'config/locale/app_localizations_setup.dart';
import 'config/locale/locale_cubit.dart';
import 'config/routes/app_routes.dart';

import 'core/theme/app_colors.dart';
import 'features/auth/presentation/cubit/session_cubit.dart';
import 'features/auth/presentation/cubit/session_state.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/orders/presentation/cubit/current_work_cubit.dart';
import 'injection_container.dart';

/// Set this to your Figma frame size. Every `.w/.h/.sp/.r` is relative to it.
const Size kDesignSize = Size(390, 844);

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  StreamSubscription<void>? _unauthorizedSub;

  // App-wide cubits holding the signed-in Driver's data. Owned here (not
  // created by a provider) so both sign-out paths below can clear them.
  final HomeCubit _homeCubit = ServiceLocator.instance<HomeCubit>();
  final CurrentWorkCubit _currentWorkCubit =
      ServiceLocator.instance<CurrentWorkCubit>();

  @override
  void initState() {
    super.initState();
    // A 401 on any token-bearing request (token replaced by a newer login or
    // revoked) lands here: clear the session and return to login.
    _unauthorizedSub = eventBus.unauthorizedStream.listen((
      _,
    ) async {
      _clearDriverData();
      await secureStorage.clearAll();
      AppRoutes.router.go(AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _unauthorizedSub?.cancel();
    _homeCubit.close();
    _currentWorkCubit.close();
    super.dispose();
  }

  /// Drops the previous Driver's stats and order from memory on sign-out,
  /// so nothing of theirs can surface in the next session.
  void _clearDriverData() {
    _homeCubit.reset();
    _currentWorkCubit.reset();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        BlocProvider<ThemeCubit>(
          create: (_) => ServiceLocator.instance<ThemeCubit>(),
        ),
        BlocProvider<LocaleCubit>(
          create: (_) => ServiceLocator.instance<LocaleCubit>(),
        ),
        BlocProvider<SessionCubit>(
          create: (_) => ServiceLocator.instance<SessionCubit>(),
        ),
        BlocProvider<HomeCubit>.value(value: _homeCubit),
        BlocProvider<CurrentWorkCubit>.value(value: _currentWorkCubit),
      ],
      // Explicit logout (and a dead session found at startup) both end in
      // SessionUnauthenticated.
      child: BlocListener<SessionCubit, SessionState>(
        listenWhen: (_, SessionState current) =>
            current is SessionUnauthenticated,
        listener: (_, __) => _clearDriverData(),
        child: ScreenUtilInit(
          designSize: kDesignSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) {
            return BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (_, ThemeMode theme) {
                return BlocBuilder<LocaleCubit, Locale?>(
                  builder: (_, Locale? locale) {
                    return MaterialApp.router(
                      title: AppEnv.appName,
                      debugShowCheckedModeBanner: false,
                      theme: appTheme,
                      darkTheme: appThemeDark,
                      themeMode: theme,
                      locale: locale,
                      supportedLocales: AppLocalizationsSetup.supportedLocales,
                      localizationsDelegates:
                          AppLocalizationsSetup.localizationsDelegates,
                      localeResolutionCallback:
                          AppLocalizationsSetup.localeResolutionCallback,
                      routerConfig: AppRoutes.router,
                      builder: (BuildContext ctx, Widget? child) {
                        // Keeps the context-free `colors` getter in sync with the
                        // active theme, replacing the side effect the source had
                        // inside AppColors.lerp().
                        ServiceLocator.injectAppColors(
                          Theme.of(ctx).extension<AppColors>()!,
                        );
                        return child ?? const SizedBox.shrink();
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
