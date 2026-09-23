import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ssm_driver/config/routes/app_routes.dart';
import 'package:ssm_driver/core/theme/app_theme.dart';
import 'package:ssm_driver/features/orders/presentation/widgets/flow_back_button.dart';

/// Minimal router: an Orders page, a store page, and a trip page with the
/// back button — enough to check where "back" lands.
GoRouter _router(String initialLocation) => GoRouter(
  initialLocation: initialLocation,
  routes: <RouteBase>[
    GoRoute(
      path: '/orders',
      name: AppRoutes.ordersName,
      builder: (_, __) => const Text('orders page'),
    ),
    GoRoute(path: '/store', builder: (_, __) => const Text('store page')),
    GoRoute(
      path: '/trip',
      builder: (_, __) => const Scaffold(body: FlowBackButton()),
    ),
  ],
);

Future<GoRouter> _pump(WidgetTester tester, String initialLocation) async {
  final GoRouter router = _router(initialLocation);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) =>
          MaterialApp.router(theme: appTheme, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('back pops to the screen that opened it', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pump(tester, '/orders');
    router.push('/trip');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FlowBackButton));
    await tester.pumpAndSettle();

    expect(find.text('orders page'), findsOneWidget);
    expect(find.text('store page'), findsNothing);
  });

  testWidgets('with nothing to pop, back falls back to the Orders tab', (
    WidgetTester tester,
  ) async {
    await _pump(tester, '/trip');

    await tester.tap(find.byType(FlowBackButton));
    await tester.pumpAndSettle();

    expect(find.text('orders page'), findsOneWidget);
  });
}
