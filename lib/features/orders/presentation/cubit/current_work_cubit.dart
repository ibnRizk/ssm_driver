import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/current_work.dart';
import '../../domain/entities/work_transition.dart';
import '../../domain/repositories/orders_repository.dart';
import 'current_work_state.dart';

/// Holds the Driver's active order — the single source of truth for it.
///
/// Provided app-wide (owned by `app.dart`, which resets it on sign-out), so the Orders tab and the whole
/// delivery flow share one instance: an order accepted or completed from the
/// Home tab shows up (or disappears) on the Orders tab too.
class CurrentWorkCubit extends Cubit<CurrentWorkState> {
  final OrdersRepository _repository;

  CurrentWorkCubit(this._repository) : super(const CurrentWorkInitial());

  /// By default the current content stays on screen until the new result
  /// arrives (pull-to-refresh). Pass `keepContent: false` when that content
  /// may be stale — a new session, or right after accepting an offer — so a
  /// loading state shows instead of a previous order or "no order".
  Future<void> loadCurrentWork({bool keepContent = true}) async {
    if (!keepContent ||
        (state is! CurrentWorkLoaded && state is! CurrentWorkEmpty)) {
      emit(const CurrentWorkLoading());
    }
    final result = await _repository.getCurrentWork();
    if (isClosed) return;
    result.fold(
      (Failure f) =>
          emit(CurrentWorkError(f.message ?? Strings.somethingWentWrong)),
      (CurrentWork? work) => emit(
        work == null ? const CurrentWorkEmpty() : CurrentWorkLoaded(work),
      ),
    );
  }

  /// Drops the signed-out Driver's order from memory (logout / 401).
  void reset() => emit(const CurrentWorkInitial());

  /// Applies a lifecycle command's server answer without another round
  /// trip. A delivered order leaves the Driver with no active work; anything
  /// that doesn't match the loaded order is re-read instead of guessed.
  Future<void> applyTransition(WorkTransition transition) async {
    final CurrentWorkState current = state;
    if (transition.status == WorkStatus.delivered) {
      emit(const CurrentWorkEmpty());
    } else if (transition.status != null &&
        current is CurrentWorkLoaded &&
        current.work.orderId == transition.orderId) {
      emit(
        CurrentWorkLoaded(
          current.work.withStatus(transition.status, transition.statusVersion),
        ),
      );
    } else {
      await loadCurrentWork();
    }
  }
}
