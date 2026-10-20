import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ssm_driver/config/routes/app_routes.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/push/push_hint.dart';
import 'package:ssm_driver/core/theme/app_colors.dart';
import 'package:ssm_driver/core/theme/app_theme.dart';
import 'package:ssm_driver/features/c2c_parcels/data/models/c2c_parcel_model.dart';
import 'package:ssm_driver/features/c2c_parcels/domain/entities/c2c_parcel.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_action_cubit.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_location_cubit.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_offer_alert_cubit.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/cubit/c2c_offer_watch_cubit.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/widgets/c2c_offer_sheet.dart';
import 'package:ssm_driver/features/c2c_parcels/presentation/widgets/c2c_shell_presenter.dart';
import 'package:ssm_driver/injection_container.dart';

import '../../helpers/c2c_fixtures.dart';
import '../../helpers/fake_location_service.dart';
import '../../helpers/fake_ringtone_service.dart';
import '../../helpers/key_localizations.dart';
import 'c2c_test_fakes.dart';

/// [KeyLocalizations] echoes keys, so these are what the sheet renders.
const String _sheetTitle = 'c2c_new_offer_title';
const String _acceptLabel = 'c2c_action_accept';
const String _laterLabel = 'parcel_new_assigned_later';

/// Enough for the sheet to slide in or out.
const Duration _sheetAnimation = Duration(milliseconds: 600);

/// An offer as the offers feed sends it, with coarse areas.
C2cParcel _offer(int id) => C2cParcelModel.fromJson(<String, dynamic>{
  ...c2cItemJson(id: id, status: 'driver_assigned'),
  'pickup': <String, dynamic>{'area': 'Talkha'},
  'dropoff': <String, dynamic>{'area': 'Mansoura'},
}, coarse: true);

void main() {
  useKeyLocalizations();

  late FakeC2cRepository repository;
  late FakeRingtoneService ringtone;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    // AppOutlinedButton reads the context-free `colors`.
    ServiceLocator.injectAppColors(AppColors.light);
  });

  tearDownAll(() => ServiceLocator.instance.unregister<AppColors>());

  setUp(() {
    repository = FakeC2cRepository();
    ringtone = FakeRingtoneService();
    ServiceLocator.instance
      ..registerFactory<C2cActionCubit>(() => C2cActionCubit(repository))
      ..registerFactory<C2cOfferAlertCubit>(
        () => C2cOfferAlertCubit(ringtone),
      );
  });

  tearDown(
    () => ServiceLocator.instance
      ..unregister<C2cActionCubit>()
      ..unregister<C2cOfferAlertCubit>(),
  );

  void usePhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  /// The cubit's answer lands a frame after the tap, and the route animation
  /// only starts ticking on the frame after the push/pop.
  Future<void> finishSheetAnimation(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(_sheetAnimation);
  }

  group('C2cOfferSheet', () {
    /// What the sheet returned; `null` until it closes.
    late Future<C2cOfferSheetResult?>? result;

    Future<void> openSheet(
      WidgetTester tester,
      C2cParcel offer, {
      int moreCount = 0,
    }) async {
      usePhoneSize(tester);
      result = null;
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            theme: appTheme,
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) => TextButton(
                  onPressed: () => result = showC2cOfferSheet(
                    context: context,
                    offer: offer,
                    moreCount: moreCount,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await finishSheetAnimation(tester);
    }

    testWidgets('shows the reference, both areas and the parcel', (
      WidgetTester tester,
    ) async {
      await openSheet(tester, _offer(7));

      expect(find.text(_sheetTitle), findsOneWidget);
      expect(find.text('C2C-0007'), findsOneWidget);
      expect(find.text('Talkha'), findsOneWidget);
      expect(find.text('Mansoura'), findsOneWidget);
      expect(find.text('Document'), findsOneWidget);
      expect(find.text('Signed contract'), findsOneWidget);
    });

    testWidgets('accepting sends the accept for this offer', (
      WidgetTester tester,
    ) async {
      await openSheet(tester, _offer(7));

      await tester.tap(find.text(_acceptLabel));
      await finishSheetAnimation(tester);

      expect(repository.actions.single.id, 7);
      expect(repository.actions.single.action, C2cAction.accept);
    });

    testWidgets('a taken accept closes the sheet with the accepted offer', (
      WidgetTester tester,
    ) async {
      await openSheet(tester, _offer(7));

      await tester.tap(find.text(_acceptLabel));
      await finishSheetAnimation(tester);

      expect(find.text(_sheetTitle), findsNothing);
      final C2cOfferSheetResult? answer = await result;
      expect(answer, isA<C2cOfferAccepted>());
      expect((answer! as C2cOfferAccepted).parcelId, 7);
    });

    testWidgets('a network failure keeps the sheet open with the error', (
      WidgetTester tester,
    ) async {
      repository.actionResult = const Left<Failure, C2cParcel?>(
        NetworkFailure(message: 'No connection'),
      );
      await openSheet(tester, _offer(7));

      await tester.tap(find.text(_acceptLabel));
      await finishSheetAnimation(tester);

      expect(find.text(_sheetTitle), findsOneWidget);
      expect(find.text('No connection'), findsOneWidget);
    });

    testWidgets('a refused accept closes the sheet with the reason', (
      WidgetTester tester,
    ) async {
      repository.actionResult = const Left<Failure, C2cParcel?>(
        ServerFailure(message: 'Offer taken'),
      );
      await openSheet(tester, _offer(7));

      await tester.tap(find.text(_acceptLabel));
      await finishSheetAnimation(tester);

      expect(find.text(_sheetTitle), findsNothing);
      expect(find.text('Offer taken'), findsOneWidget);
      expect(await result, isNull);
    });

    testWidgets('"Later" closes the sheet without answering', (
      WidgetTester tester,
    ) async {
      await openSheet(tester, _offer(7));

      await tester.tap(find.text(_laterLabel));
      await finishSheetAnimation(tester);

      expect(find.text(_sheetTitle), findsNothing);
      expect(repository.actions, isEmpty);
      expect(await result, isNull);
    });

    testWidgets('the sheet rings while the offer waits', (
      WidgetTester tester,
    ) async {
      await openSheet(tester, _offer(7));

      expect(ringtone.isRinging, isTrue);
    });

    testWidgets('tapping accept silences it at once', (
      WidgetTester tester,
    ) async {
      await openSheet(tester, _offer(7));

      await tester.tap(find.text(_acceptLabel));

      expect(ringtone.isRinging, isFalse);
      await finishSheetAnimation(tester);
    });

    testWidgets('closing the sheet silences it', (WidgetTester tester) async {
      await openSheet(tester, _offer(7));

      await tester.tap(find.text(_laterLabel));
      await finishSheetAnimation(tester);

      expect(ringtone.isRinging, isFalse);
    });

    testWidgets('the sheet closes itself when the offer expires', (
      WidgetTester tester,
    ) async {
      final C2cParcel offer = C2cParcelModel.fromJson(<String, dynamic>{
        ...c2cItemJson(id: 7, status: 'driver_assigned'),
        'expires_at': DateTime.now()
            .add(const Duration(seconds: 30))
            .toIso8601String(),
      }, coarse: true);
      await openSheet(tester, offer);

      await tester.pump(const Duration(seconds: 31));
      await finishSheetAnimation(tester);

      expect(find.text(_sheetTitle), findsNothing);
      expect(find.text('order_offer_expired'), findsOneWidget);
      expect(ringtone.isRinging, isFalse);
      expect(repository.actions, isEmpty);
    });

    testWidgets('more offers at once link to all of them', (
      WidgetTester tester,
    ) async {
      await openSheet(tester, _offer(7), moreCount: 2);

      await tester.tap(find.text('c2c_offer_more'));
      await finishSheetAnimation(tester);

      expect(await result, isA<C2cOfferViewAll>());
    });
  });

  group('C2cShellPresenter', () {
    late StreamController<PushHint> arrivals;

    setUp(() {
      arrivals = StreamController<PushHint>.broadcast();
      ServiceLocator.instance
        ..registerFactory<C2cOfferWatchCubit>(
          () => C2cOfferWatchCubit(
            repository,
            arrivals: arrivals.stream,
            pollInterval: const Duration(hours: 1),
          ),
        )
        ..registerFactory<C2cLocationCubit>(
          () => C2cLocationCubit(
            repository,
            FakeLocationService(),
            interval: const Duration(hours: 1),
          ),
        );
    });

    tearDown(() async {
      ServiceLocator.instance
        ..unregister<C2cOfferWatchCubit>()
        ..unregister<C2cLocationCubit>();
      await arrivals.close();
    });

    Future<void> pumpShell(WidgetTester tester) async {
      usePhoneSize(tester);
      final GoRouter router = GoRouter(
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, __) => const C2cShellPresenter(
              child: Scaffold(body: Center(child: Text('some tab'))),
            ),
          ),
          GoRoute(
            path: '/c2c-job/:id',
            name: AppRoutes.c2cJobName,
            builder: (_, GoRouterState state) =>
                Scaffold(body: Text('job ${state.pathParameters['id']}')),
          ),
        ],
      );
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) =>
              MaterialApp.router(theme: appTheme, routerConfig: router),
        ),
      );
      // The watch's first read only records what's already waiting.
      await tester.pump();
    }

    /// A C2C push finds [offer] and the sheet slides in.
    Future<void> receiveOffer(WidgetTester tester, C2cParcel offer) async {
      repository.offersResult = Right<Failure, List<C2cParcel>>(<C2cParcel>[
        offer,
      ]);
      arrivals.add(const PushHint(PushTarget.c2cParcel));
      await tester.pump();
      await finishSheetAnimation(tester);
    }

    testWidgets('a new offer shows the sheet over the current tab', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester);

      await receiveOffer(tester, _offer(7));

      expect(find.text(_sheetTitle), findsOneWidget);
      expect(find.text('some tab'), findsOneWidget);
    });

    testWidgets('accepting opens the job directly', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester);
      await receiveOffer(tester, _offer(7));

      await tester.tap(find.text(_acceptLabel));
      await finishSheetAnimation(tester);

      expect(find.text(_sheetTitle, skipOffstage: false), findsNothing);
      expect(find.text('job 7'), findsOneWidget);
    });
  });
}
