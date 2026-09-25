import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ssm_driver/config/routes/app_routes.dart';
import 'package:ssm_driver/core/theme/app_colors.dart';
import 'package:ssm_driver/core/theme/app_theme.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/current_work_cubit.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/incoming_order_cubit.dart';
import 'package:ssm_driver/features/orders/presentation/cubit/offer_polling_cubit.dart';
import 'package:ssm_driver/features/orders/presentation/widgets/incoming_order_presenter.dart';
import 'package:ssm_driver/injection_container.dart';

import '../../helpers/fake_ringtone_service.dart';
import '../../helpers/key_localizations.dart';
import 'orders_test_fakes.dart';

/// [KeyLocalizations] echoes keys, so these are what the sheet renders.
const String _sheetTitle = 'order_offer_title';
const String _acceptLabel = 'order_accept_button';
const String _rejectLabel = 'order_reject_button';

/// Enough for the sheet to slide in or out.
const Duration _sheetAnimation = Duration(milliseconds: 500);

void main() {
  useKeyLocalizations();

  late FakeOrdersRepository repository;
  late FakeRingtoneService ringtone;
  late OfferPollingCubit polling;
  late CurrentWorkCubit currentWork;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    // AppOutlinedButton reads the context-free `colors`.
    ServiceLocator.injectAppColors(AppColors.light);
  });

  tearDownAll(() => ServiceLocator.instance.unregister<AppColors>());

  setUp(() {
    repository = FakeOrdersRepository();
    ringtone = FakeRingtoneService();
    polling = OfferPollingCubit(repository, interval: const Duration(hours: 1));
    currentWork = CurrentWorkCubit(repository);
  });

  tearDown(() {
    ServiceLocator.instance.unregister<IncomingOrderCubit>();
    currentWork.close();
  });

  /// The app shell in miniature: some screen, the trip route, and the
  /// presenter above the navigator exactly as `app.dart` places it.
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    // The countdown reads the test's fake clock, so pumping time expires it.
    ServiceLocator.instance.registerFactory<IncomingOrderCubit>(
      () => IncomingOrderCubit(
        repository,
        ringtone,
        now: tester.binding.clock.now,
      ),
    );

    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    final GoRouter router = GoRouter(
      navigatorKey: navigatorKey,
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, __) =>
              const Scaffold(body: Center(child: Text('some screen'))),
        ),
        GoRoute(
          path: '/order-trip',
          name: AppRoutes.orderTripName,
          builder: (_, __) => const Scaffold(body: Text('trip page')),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: <BlocProvider<StateStreamableSource<Object?>>>[
          BlocProvider<OfferPollingCubit>.value(value: polling),
          BlocProvider<CurrentWorkCubit>.value(value: currentWork),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp.router(
            theme: appTheme,
            routerConfig: router,
            builder: (_, Widget? child) => IncomingOrderPresenter(
              navigatorKey: navigatorKey,
              child: child!,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// Runs a sheet transition to the end. The cubit's answer lands a frame
  /// after the tap, and the route animation only starts ticking on the
  /// frame after the push/pop — hence the extra pumps.
  Future<void> finishSheetAnimation(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(_sheetAnimation);
  }

  /// Polling finds [sampleOffer] and the sheet slides in.
  Future<void> receiveOffer(WidgetTester tester) async {
    polling.start();
    await tester.pump();
    await finishSheetAnimation(tester);
  }

  /// Unmounts everything, closing the sheet's cubit, so no countdown or
  /// polling timer outlives the test.
  Future<void> teardownApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await polling.close();
  }

  testWidgets('a found offer shows the sheet over the current screen', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await receiveOffer(tester);

    expect(find.text(_sheetTitle), findsOneWidget);
    expect(find.text('some screen'), findsOneWidget);
    await teardownApp(tester);
  });

  testWidgets('a found offer starts the ringtone', (WidgetTester tester) async {
    await pumpApp(tester);

    await receiveOffer(tester);

    expect(ringtone.isRinging, isTrue);
    await teardownApp(tester);
  });

  testWidgets('accepting closes the sheet and opens the trip', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await receiveOffer(tester);

    await tester.tap(find.text(_acceptLabel));
    await finishSheetAnimation(tester);

    // Gone, not just hidden under the trip page.
    expect(find.text(_sheetTitle, skipOffstage: false), findsNothing);
    expect(find.text('trip page'), findsOneWidget);
    expect(ringtone.isRinging, isFalse);
    await teardownApp(tester);
  });

  testWidgets('rejecting closes the sheet', (WidgetTester tester) async {
    await pumpApp(tester);
    await receiveOffer(tester);

    await tester.tap(find.text(_rejectLabel));
    await finishSheetAnimation(tester);

    expect(find.text(_sheetTitle), findsNothing);
    expect(ringtone.isRinging, isFalse);
    await teardownApp(tester);
  });

  testWidgets('the sheet closes itself when the offer expires', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await receiveOffer(tester);

    await tester.pump(Duration(seconds: sampleOffer.remainingSeconds));
    await finishSheetAnimation(tester);

    expect(find.text(_sheetTitle), findsNothing);
    expect(find.text('order_offer_expired'), findsOneWidget);
    expect(ringtone.isRinging, isFalse);
    await teardownApp(tester);
  });

  testWidgets('system back does not dismiss the offer', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await receiveOffer(tester);

    await tester.binding.handlePopRoute();
    await finishSheetAnimation(tester);

    expect(find.text(_sheetTitle), findsOneWidget);
    await teardownApp(tester);
  });
}
