import 'package:flutter_bloc/flutter_bloc.dart';

import 'incoming_order_state.dart';

/// Screen-scoped cubit for [IncomingOrderScreen] — provided at the route.
///
/// No domain/data layer yet: there's no dispatch API to call, so
/// [accept]/[reject] just simulate the request. Replace the delay with a
/// real use case once the endpoint exists, the same way `HomeCubit`'s doc
/// comment shows.
class IncomingOrderCubit extends Cubit<IncomingOrderState> {
  IncomingOrderCubit() : super(const IncomingOrderIdle());

  Future<void> accept(String orderId) async {
    try {
      emit(const IncomingOrderAccepting());
      // TODO: Replace with the real accept-order use case once it exists.
      await Future<void>.delayed(const Duration(milliseconds: 900));
      emit(const IncomingOrderAccepted());
    } catch (e) {
      emit(IncomingOrderError(message: e.toString()));
    }
  }

  Future<void> reject(String orderId) async {
    try {
      emit(const IncomingOrderRejecting());
      // TODO: Replace with the real reject-order use case once it exists.
      await Future<void>.delayed(const Duration(milliseconds: 900));
      emit(const IncomingOrderRejected());
    } catch (e) {
      emit(IncomingOrderError(message: e.toString()));
    }
  }
}
