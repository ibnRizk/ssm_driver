import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/active_offer.dart';
import '../cubit/incoming_order_cubit.dart';
import '../cubit/offer_polling_cubit.dart';
import '../cubit/offer_polling_state.dart';
import 'incoming_order_sheet.dart';

/// App-wide: when [OfferPollingCubit] finds a new offer, shows
/// [IncomingOrderSheet] over whatever screen is open.
///
/// Sits in `MaterialApp.builder` — above the navigator — so it pushes the
/// sheet through [navigatorKey] rather than its own context.
class IncomingOrderPresenter extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const IncomingOrderPresenter({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  @override
  State<IncomingOrderPresenter> createState() => _IncomingOrderPresenterState();
}

class _IncomingOrderPresenterState extends State<IncomingOrderPresenter> {
  ModalBottomSheetRoute<void>? _route;
  IncomingOrderCubit? _cubit;
  int? _assignmentId;

  void _present(ActiveOffer offer) {
    final NavigatorState? navigator = widget.navigatorKey.currentState;
    if (navigator == null) return;

    final ModalBottomSheetRoute<void>? open = _route;
    if (open != null && open.isActive) {
      if (offer.assignmentId == _assignmentId) return;
      // A newer offer replaces the one on screen. Its cubit is closed here,
      // before the new one starts, so the old ringtone's stop can't land
      // after the new one's play.
      navigator.removeRoute(open);
      _cubit?.close();
    }

    final IncomingOrderCubit cubit =
        ServiceLocator.instance<IncomingOrderCubit>()..start(offer);
    final ModalBottomSheetRoute<void> route = ModalBottomSheetRoute<void>(
      isScrollControlled: true,
      // Only the buttons answer the offer; see IncomingOrderSheet.
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<IncomingOrderCubit>(
        // Closed with the sheet, however it goes away (answered, expired,
        // replaced, or swept off by a sign-out) — which stops the countdown
        // and the ringtone.
        create: (_) => cubit,
        child: const IncomingOrderSheet(),
      ),
    );
    _route = route;
    _cubit = cubit;
    _assignmentId = offer.assignmentId;
    navigator.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OfferPollingCubit, OfferPollingState>(
      listener: (_, OfferPollingState state) {
        if (state is OfferPollingFound) _present(state.offer);
      },
      child: widget.child,
    );
  }
}
