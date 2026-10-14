import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/push/push_hint.dart';
import '../../injection_container.dart';
import 'app_routes.dart';

/// Where opening a push lands: a shell tab, plus a parcel to open on top.
typedef PushDestination = ({String tabName, int? parcelId});

/// An offer isn't a route — `IncomingOrderPresenter` shows it over any
/// screen once the hint's refetch finds it — so its tap opens Home, where
/// the online switch lives. A push about nothing known stays put.
PushDestination? pushDestinationOf(PushHint hint) => switch (hint.target) {
  PushTarget.offer => (tabName: AppRoutes.homeName, parcelId: null),
  PushTarget.order => (tabName: AppRoutes.ordersName, parcelId: null),
  PushTarget.parcel => (tabName: AppRoutes.parcelsName, parcelId: hint.id),
  // The Parcels tab opens on its house-to-house segment, which re-reads
  // its offers and jobs on the same push.
  PushTarget.c2cParcel => (tabName: AppRoutes.parcelsName, parcelId: null),
  PushTarget.unknown => null,
};

/// Routes opened notifications. Lives in the bottom-nav shell, which only
/// exists for an approved, signed-in Driver — so a tap that launched the
/// app waits out the splash and session check, and one arriving while
/// signed out is never routed into someone else's session.
class PushTapRouter extends StatefulWidget {
  final Widget child;

  const PushTapRouter({super.key, required this.child});

  @override
  State<PushTapRouter> createState() => _PushTapRouterState();
}

class _PushTapRouterState extends State<PushTapRouter> {
  StreamSubscription<void>? _tapSubscription;

  @override
  void initState() {
    super.initState();
    _tapSubscription = pushService.tapped.listen((_) => _routePendingTap());
    // A tap from before the shell existed (cold start, or during login).
    WidgetsBinding.instance.addPostFrameCallback((_) => _routePendingTap());
  }

  @override
  void dispose() {
    _tapSubscription?.cancel();
    super.dispose();
  }

  void _routePendingTap() {
    if (!mounted) return;
    final PushHint? hint = pushService.takePendingTap();
    if (hint == null) return;
    final PushDestination? destination = pushDestinationOf(hint);
    if (destination == null) return;

    final GoRouter router = GoRouter.of(context);
    router.goNamed(destination.tabName);
    final int? parcelId = destination.parcelId;
    if (parcelId != null) {
      router.pushNamed<void>(
        AppRoutes.parcelDetailsName,
        pathParameters: <String, String>{'id': '$parcelId'},
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
